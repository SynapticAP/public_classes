global class CallableYourekaSDocsTable implements Callable {
 public class ExtensionMalformedCallException extends Exception {}
  public Object call(String action, Map<String,Object> args) {
    switch on action {
      when 'getLineItemsAsListSObject' {
        return this.getLineItemsAsListSObject((String)args.get('recordId'));
      }
      when 'getAnswers'{
        SDocsTable.TableOptions options = new SDocsTable.TableOptions();
        options.returnAsTable = (String)args.get('returnAsTable')=='true';
        options.tableCSSName = (String)args.get('tableCSSName');
        options.createTableTag = (String)args.get('createTableTag')=='true';
        options.includeContentImages = (String)args.get('includeContentImages')=='true';
        options.includePhotosInline = (String)args.get('includePhotosInline')=='true';
        options.contentImagesOnly = (String)args.get('contentImagesOnly')=='true';
        options.photosOnly = (String)args.get('photosOnly')=='true';
        options.radioButtonsAsColumn = (String)args.get('radioButtonsAsColumn')=='true';
        options.sectionName = (String)args.get('sectionName');
        options.queryWhereClause = (String)args.get('queryWhereClause');
        options.formId = (String)args.get('formId');
				options.formLookupName = (String)args.get('formLookupName');
				options.recordId = (String)args.get('recordId');
				options.templateName = (String)args.get('templateName');
        options.hTMLName = (String)args.get('hTMLName');
        if (options.hTMLName==null || options.hTMLName=='')
          options.hTMLName = 'TABLE_HTML';
        options.skipSpaces = args.get('skipSpaces')=='true';
		options.linkedSectionAsTable = args.get('linkedSectionAsTable')=='true';
        system.debug('options='+options);
        Object result = this.getLineItems(options);
        return result;
      }
      when else {
        throw new ExtensionMalformedCallException('Method not implemented');
      }
    }
  }
 


  // structure on JSON in long_text_answer for photos
  public class DocInfo {
    public String versionID;
    public String docTitle;
    public String lastModifiedDate;
    public String docSize;    
    public String externalFileID;
    public String error;
  }


  public List<disco__Answer__c> queryAnswers(SDocsTable.TableOptions options){
		if (String.isBlank(options.formId))
		{
			String formQuery = 'Select Id From disco__Form__c where '+options.formLookupName +' = '+options.recordId+' and disco__Form_Template__r.Name = '+options.templateName
						+ ' limit 1 Order By Name DESC';			
			List<disco__Form__c> forms = Database.query(formQuery);
			if (forms.size()==0){
				throw new ENoFormFoundException('No form found for '+options.formLookupName+' for record id '+options.recordId+' and template '+options.templateName);
				//------------>
			}
			options.formId = forms[0].Id;

		}
    String query = 'SELECT disco__Answer__c, disco__Long_Text_Answer__c,disco__Date_Answer__c,disco__Date_Time_Answer__c, disco__E_Sig_Image_Link__c, disco__E_Sig_Image_Id__c,disco__Linked_Section_Order__c, '
              +'disco__Question__r.disco__DMY_Format__c,disco__Question__r.disco__Label__c, disco__Question__r.disco__Image_Version_ID__c, disco__Question__r.disco__Section__r.Name, disco__Linked_Section_Record_ID__c, '
              +'disco__Form__r.disco__Form_Template_Name__c, disco__Form__r.id, disco__Question__r.disco__Order__c, disco__Hidden_By_Dep__c, disco__Question__r.disco__Type__c,  '
			  +'disco__Question__r.disco__Section__r.disco__Type__c '
            +'FROM disco__Answer__c ';
    if (options.queryWhereClause != null && options.queryWhereClause != '')
      query += options.queryWhereClause;
    else 
    {
      query += 'WHERE disco__Form__r.Id = \''+options.formId +'\' AND disco__Hidden_By_Dep__c = FALSE ';
      if (options.sectionName != null && options.sectionName.trim()!='')
      {      
        system.debug('sectionName='+options.sectionName);
        query += 'and disco__Question__r.disco__Section__r.Name = \''+options.sectionName.replace('\'','`') +'\'';
      }
      if (options.contentImagesOnly==true)
        query += ' and disco__Question__r.disco__Type__c = \'Image\' ';
      else if (options.photosOnly==true)
        query += ' and disco__Question__r.disco__Type__c = \'Attachment/Photo\' ';
      if (options.skipSpaces==true)
        query += '  and disco__Question__r.disco__Type__c <> \'Space\' ';
      query += ' Order By disco__Question__r.disco__Section__r.disco__Order__c, disco__Linked_Section_Order__c, disco__Question__r.disco__Order__c ';   
    }
    system.debug('query='+query);
    return Database.query(query);
  }

  public List<disco__Answer__c> getLineItemsAsListSObject(String recordId) {
    
    String url = '/sfc/servlet.shepherd/version/download/';
                
    SDocsTable.TableOptions options = new SDocsTable.TableOptions();
    options.returnAsTable = false;
    options.formId = recordId;
    options.includeContentImages = true;
    options.includePhotosInline = false;


    List<disco__Answer__c> searchList = queryAnswers(options);
    List<disco__Answer__c> filtered = new List<disco__Answer__c>();
    String lsRecordId = '';


    for (disco__Answer__c ans : searchList) {

      if(ans.disco__Long_Text_Answer__c != null && ans.disco__Long_Text_Answer__c.contains('"versionID":"' )){
        String imgs; // html imgages string to be put back to answer
      
          List<DocInfo> docInfos = (List<DocInfo>)JSON.deserializeStrict(ans.disco__Long_Text_Answer__c, List<DocInfo>.class);
        for (DocInfo di : docInfos){
          imgs+='lt#img src=quot#' + url + di.versionID + 'quot# /gt#'; 
        }

        ans.disco__Answer__c = imgs;
        ans.disco__Question__r.disco__Label__c = 'lt#div class="middle" gt#' + ans.disco__Question__r.disco__Label__c + 'lt#div / gt#' ;       
      }      
      else if(ans.disco__E_Sig_Image_Id__c!= null){        
        ans.disco__Answer__c='lt#img src=quot#' +ans.disco__E_Sig_Image_Id__c + 'quot# /gt#';
      } 
      else if (ans.disco__Question__r.disco__Image_Version_ID__c != null)
      {
        ans.disco__Answer__c = 'lt#img src=quot#' + url + ans.disco__Question__r.disco__Image_Version_ID__c + 'quot# /gt#'; 
        ans.disco__Question__r.disco__Label__c = null;
        ans.disco__Question__r.disco__Image_Version_ID__c = null;
      }

  
      // only need non-null answers if label has no < and type isn't space
      if( ans.disco__Answer__c != null || ans.disco__Question__r.disco__Label__c.contains('<') || ans.disco__Question__r.disco__Type__c == 'Space' ){

        SDocsTable.handleSpecialCharacter(ans);
        filtered.add(ans);      
      }
    }  

    return filtered;       
  }  


  public Object getLineItems(SDocsTable.tableOptions options) // either list of line items or map to HTML
  {
    String urlImages = '/servlet/servlet.FileDownload?file=';
    String urlPhotos = '/sfc/servlet.shepherd/version/download/';
    List<disco__Answer__c> answers = queryAnswers(options);
    List<disco__Answer__c> filteredAnswers = new List<disco__Answer__c>();
    Set<Id> questionIds = new Set<Id>();
    for (disco__Answer__c ans : answers)
    {
      Boolean include =    (ans.disco__Question__r.disco__Type__c != 'Image' || options.includeContentImages== true);
      include = include && (ans.disco__Question__r.disco__Type__c == 'Image' || options.contentImagesOnly!=true);
      include = include && (ans.disco__Question__r.disco__Type__c == 'Attachment/Photo' || options.photosOnly !=true);
      include = include && (ans.disco__Question__r.disco__Type__c != 'Space' || options.skipSpaces  !=true);
      if (include)
      {
        if (options.includePhotosInline==true && ans.disco__Question__r.disco__Type__c == 'Attachment/Photo')
        {
          if ( ans.disco__Long_Text_Answer__c != null && ans.disco__Long_Text_Answer__c.contains('"versionID":"' ))
          {
            String imgs=''; // html imgages string to be put back to answer
        
            List<DocInfo> docInfos = (List<DocInfo>)JSON.deserializeStrict(ans.disco__Long_Text_Answer__c, List<DocInfo>.class);
            for (DocInfo di : docInfos){
              imgs+='<img src="' + urlPhotos + di.versionID + '">'; 
            }
            ans.disco__Answer__c = imgs;
          }
          else ans.disco__Answer__c=''; // empty photo
    
        }
        else if(ans.disco__E_Sig_Image_Id__c!= null){        
            ans.disco__Answer__c='<img src="' +urlPhotos+ans.disco__E_Sig_Image_Id__c + '">';
        } 
        else if (ans.disco__Question__r.disco__Image_Version_ID__c != null && options.includeContentImages==true)
        {
          ans.disco__Answer__c = '<img src="' + urlImages + ans.disco__Question__r.disco__Image_Version_ID__c + '">'; 
          ans.disco__Question__r.disco__Label__c = null;
          ans.disco__Question__r.disco__Image_Version_ID__c = null;
        }
        
        questionIds.add(ans.disco__Question__c);
        filteredAnswers.add(ans);      
      }

    }
    Integer maxQVs = 0;
    Map<Id,List<disco__Question_Value__c>>qId2QVs = new Map<Id,List<disco__Question_Value__c>>();
    for (disco__Question__c question : [Select Id,(Select disco__Label__c FROM disco__Question_Values__r ORDER BY disco__Order__c)
                  From disco__Question__c  Where id in :questionIds])
    {
      qId2QVs.put(question.Id, question.disco__Question_Values__r);
      if (question.disco__Question_Values__r != null && question.disco__Question_Values__r.size()>0)
          maxQVs = Math.max(maxQVs,question.disco__Question_Values__r.size());
    }
    
    if (options.returnAsTable==true)
    {
      String html = SDocsTable.yourekaAnswerTable(filteredAnswers,options,maxQVs,qId2QVs);
      system.debug('html');
      system.debug(html);
       Map<String,String> mergedTable = new Map<String,String>{options.hTMLName => html};      
      return mergedTable;
    }
    else 
      return filteredAnswers;
  }
}