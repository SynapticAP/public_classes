// Tested via CallableApexYourekaForm_Test
global with sharing class SDocsTable {

	global class TableOptions{
		global Boolean returnAsTable;
		global String formId; // not needed if query is passed, or if formfldname, objid,templatename are passed
		global String formLookupName;// to get form, use this lookup on the form object. Ignored if form id is passed
		global String recordId; // used to get form for a specific record. Ignored if form id is passed
		global String templateName; //used to get a form for a specific template. Ignored if form id is passed
		global String tableCSSName; // only applies is returnAsTable == true
		global Boolean createTableTag;// only applies is returnAsTable == true
//		global Boolean twoColumnForTwoColumnSections; no support yet
		global Boolean includeContentImages; // include free text, content images
		global Boolean includePhotosInline; // show actual images, not just '3 files'
		global Boolean contentImagesOnly; // only return contentImages
		global Boolean photosOnly; // return only photos
		global Boolean radioButtonsAsColumn; // show radio buttons as table columns
		global String sectionName; // if queryWhereClause is not specified, search for this section only
		global String queryWhereClause; // don't use built in query for section/form, pass custom where clause. Expected to include Order By 
		global String hTMLName; // name of html for SDocs
		global Boolean skipSpaces; // do not output spaces
		global Boolean linkedSectionAsTable; // show a linked table with the question labels as row headers and the answers for each as a rwo
	}



	public static String	handleSpecialCharacter(disco__Answer__c ans){
		if(ans.disco__Question__r.disco__Type__c == 'Space'){
			ans.disco__Question__r.disco__label__c = '&nbsp;';
			ans.disco__Answer__c = '';
		}
		
		else if(ans.disco__Answer__c != null 
				&& ans.disco__Question__r.disco__Type__c != 'Attachment/Photo'
				&& ans.disco__Question__r.disco__Type__c != 'Image'
				&& ans.disco__Question__r.disco__Type__c != 'E-Signature')
				{
			ans.disco__Answer__c = ans.disco__Answer__c.replaceAll('&', '&#38;');
			ans.disco__Answer__c = ans.disco__Answer__c.replaceAll('<', '&lt;');
			ans.disco__Answer__c = ans.disco__Answer__c.replaceAll('>', '&gt;');
		} 
		else if (ans.disco__Question__r.disco__Type__c == 'Date' && ans.disco__Date_Answer__c != null)
		{
			DateTime dt = DateTime.newInstance(ans.disco__Date_Answer__c,Time.newInstance(0,0,0,0));
			if (ans.disco__Question__r.disco__DMY_Format__c==true)
				ans.disco__Answer__c = dt.format('dd/MM/yyyy');
			else 
				ans.disco__Answer__c = dt.format('MM/dd/yyyy');			
		}
		else if (ans.disco__Question__r.disco__Type__c == 'Date/Time' && ans.disco__Date_Time_Answer__c != null)	
		{
			DateTime dt = ans.disco__Date_Time_Answer__c;
			if (ans.disco__Question__r.disco__DMY_Format__c==true)
				ans.disco__Answer__c = dt.format('dd/MM/yyyy HH:mm');
			else 
				ans.disco__Answer__c = dt.format('MM/dd/yyyy hh:mm aa');			
		}

		if(ans.disco__Question__r.disco__Section__r.Name != null){
			ans.disco__Question__r.disco__Section__r.Name = ans.disco__Question__r.disco__Section__r.Name.replaceAll('&', '&#38;');
		}

		String txt = ans.disco__Question__r.disco__Label__c;
		if (txt != null && ans.disco__Question__r.disco__Type__c != 'Free Text'){
			txt = txt.replaceAll('&;', '&#38;');
			txt = txt.replaceAll('<', '&lt;');
			txt = txt.replaceAll('>', '&gt;');			
			txt = txt.replaceAll('</disco__Question__r.disco__label__c>', '');
		}
		ans.disco__Question__r.disco__Label__c = txt;

		return ans.disco__Answer__c;

	}




	public class DataTableCell {
		public String value;
		private String cssName;
		public DataTableCell(String value) {
			this.value=value;
		}

		public Boolean isValuePopulated(){
			return this.value !=null;
		}

		public String toHtmlCell(){
			return '<td> '+(this.value ==null?'':this.value)+'</td>';
		}
	}


	public	class DataTableRow {
		public List<DataTableCell> cells;

		public DataTableRow() {
			cells = new List<DataTableCell>();
		}

		public void addCell(DataTableCell cell){
			cells.add(cell);
		}

		public List<Boolean> getColumnDataStatus(){
			List<Boolean> colStatus = new List<Boolean>();
			for(DataTableCell cell: this.cells ){
				colStatus.add(cell.isValuePopulated());
			}
			return colStatus;
		}

		public Boolean hasAnyData(){
			for(DataTableCell cell:cells)
				if (cell.isValuePopulated())
					return true; //----------->
			
			return false;
		}

		public String toRowHtml(){
			String htmlRow = '<tr>';
			for (DataTableCell cell : cells)
				htmlRow +=cell.toHtmlCell();
			htmlRow +='</tr>';
			return htmlRow;
		}
	}	

	public	class DataTable {
		public String className;
		public List<DataTableRow> rows;
		String headerHTML;
		
		public DataTable(String className,String headerHTML) {
			this.headerHTML = headerHTML;
			this.rows= new List<DataTableRow>();
			this.className = className;
		}

		public void addRow(DataTableRow row){
			if(row.hasAnyData())			 //skip empty rows
				this.rows.add(row);			
		}


		public String toHtmlTable(String headerHTML, Boolean addTableTag){
			String html = addTableTag==true? '<table'+(className !=null && className !=''? ' class="'+className+'"' : '')+'>' : '';
			if (headerHTML!=null)
				html+= headerHTML;
			for(DataTableRow row : this.rows)
				html += row.toRowHtml();
			if (addTableTag==true)
				html+='</table>';
			return html;
		}
	}




	 public static String stripHTML(String ins){
				if (ins==null)
							return null; //--------->
				
				String result = ins;
				Integer startPos = result.indexOf('<');
				Integer endPos = result.indexOf('>');
				while (startPos > -1 && endPos > startPos)
				{
						result = result.left(startPos)+result.subString(endPos+1,result.length());
					startPos = result.indexOf('<');
					endPos = result.indexOf('>');
				}
				return result;
		}

	
	// creates a table for LS. Header row is labels, row(s) for each LS entry. returns HTML
	// input: answers for a single linked section ordered by linked section order  (grouping the answes for a single linked section) and question order
	private static String handleLinkedSectionAsTable(List<disco__Answer__c>lsAnswers,TableOptions options){
		if (lsAnswers==null || lsAnswers.size()==0)
			return '';

		String html='';
		List<String>headers = new List<String>();

		Decimal  thisLS = lsAnswers[0].disco__Linked_Section_Order__c;		
		Integer i =0;
		while (i<=lsAnswers.size() && lsAnswers[i].disco__Linked_Section_Order__c==thisLS) {
			headers.add(lsAnswers[i++].disco__Question__r.disco__Label__c);
		}
			

		String sectionName = lsAnswers[0].disco__Question__r.disco__Section__r.Name;
		String header = '<th colspan="'+String.valueOf(headers.size())+'" style="background-color:#cccccc;text-align:center" >'+sectionName+'</th>';
		DataTable lsTable = new DataTable (options.tableCSSName,header);
		DataTableRow row = new DataTableRow();
		for (String colHeader : headers)
			row.addCell(new DatatableCell(colHeader));
		lsTable.addRow(row);		
		row = new DataTableRow();
		for (disco__Answer__c ans : lsAnswers)
		{
			if (ans.disco__Linked_Section_Order__c != thisLS)
			{
				lsTable.addRow(row);
				row = new DataTableRow();
				thisLS = ans.disco__Linked_Section_Order__c;		
			}
			row.addCell(new DatatableCell(ans.disco__Answer__c));
		}
		lsTable.addRow(row);
		html = lsTable.toHtmlTable(header,options.createTableTag); 
		return html;	
	}

	// html table for answers in a single section. Header will be section name
	public static String yourekaAnswerTable(List<disco__Answer__c>answers, TableOptions options,Integer qvCols,Map<Id,List<disco__Question_Value__c>> qId2QVs ){
		if (answers == null || answers.size()==0)
			return '';
		DataTable table=null; 
		String header = null;
		String sectionName=null;
		String html='';
		List<disco__Answer__c> lsAnswers = new List<disco__Answer__c>();
		Integer cols = 2;
		if (options.radioButtonsAsColumn==true)
			cols = 2 + qvCols;

		for (disco__Answer__c ans : answers){
			if (options.skipSpaces==true &&ans.disco__Question__r.disco__Type__c=='Space' )
				continue; // skip them entirely

			handleSpecialCharacter(ans);
			String label = ans.disco__Question__r.disco__Label__c;
			if (ans.disco__Question__r.disco__Type__c == 'Free Text')
				label = stripHTML(label);
			if (sectionName != ans.disco__Question__r.disco__Section__r.Name) {// section break, start a new table
			    // handle LS table
				if (lsAnswers.size()>0){
					html += handleLinkedSectionAsTable(lsAnswers,options);
					lsAnswers.clear();
				}
				else if (table != null) // handle regular section table
					html += table.toHtmlTable(header,options.createTableTag)+'<br/>';
				sectionName = ans.disco__Question__r.disco__Section__r.Name;
				header = '<th colspan="'+cols+'" style="background-color:#cccccc;text-align:center" >'+sectionName+'</th>';
				table = new DataTable (options.tableCSSName,header);
			}
			if ( options.linkedSectionAsTable == true  
				&& (ans.disco__Question__r.disco__Section__r.disco__Type__c == 'Linked' || ans.disco__Question__r.disco__Section__r.disco__Type__c == 'Task') )
			{
				lsAnswers.add(ans);
			}
			else{
				DataTableRow row = new DataTableRow();
				row.addCell(new DatatableCell(label));
				String answerText = ans.disco__Answer__c;
				List<disco__Question_Value__c> qvs = qId2QVs.get(ans.disco__Question__c);
				if (options.radioButtonsAsColumn==true && qvs!= null && qvs.size()>0)
				{
					if (qvs != null && qvs.size()>0)
					{
						row.addCell(new DatatableCell('')); // leave normal answer col empty
						for (disco__Question_Value__c qv : qvs)
						{
							if (qv.disco__Label__c == ans.disco__Answer__c)
								row.addCell(new DatatableCell(answerText));
							else 
								row.addCell(new DatatableCell(''));
						}
					}
					for (Integer i=qvs.size();i<qvcols;i++)
						row.addCell(new DatatableCell(''));
				}
				else 
					row.addCell(new DatatableCell(answerText));

				table.addRow(row);
			}
		}
		// handle any final (or only) LS table
		if (lsAnswers.size()>0){
			html += handleLinkedSectionAsTable(lsAnswers,options);
			lsAnswers.clear();
		}
		else if (table != null) // handle final (or only) regular table
			html += table.toHtmlTable(header,options.createTableTag); 

		return html;
	}






}