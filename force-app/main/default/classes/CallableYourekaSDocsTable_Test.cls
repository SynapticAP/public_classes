@istest
public with sharing class CallableYourekaSDocsTable_Test {

 @testSetup
	static void setup() {
		
		disco__Form_Template__c template = new disco__Form_Template__c(disco__Status__c='In Use', Name = 'Clinical Note V1');
		insert template;


		disco__Section__c section = new disco__Section__c(disco__Form_Template__c=template.Id, Name = 'Photos');
		disco__Section__c section2 = new disco__Section__c(disco__Form_Template__c=template.Id, Name = 'Page 2');
		disco__Section__c section3 = new disco__Section__c(disco__Form_Template__c=template.Id, Name = 'Surgical History');
		insert new List<disco__Section__c>{section,section2,section3};

		disco__Question__c question1 = new disco__Question__c(disco__Label__c='Photos',disco__Type__c='Attachment/Photo',disco__Section__c=section.Id,disco__Form_Template__c=template.Id, disco__Order__c = 1);
		disco__Question__c question2 = new disco__Question__c(disco__Label__c='Surgical History & Date', disco__Type__c='Date',disco__Section__c=section2.Id,disco__Form_Template__c=template.Id, disco__Order__c = 2);

		disco__Question__c question3 = new disco__Question__c(disco__Label__c='Reason for Surgery', disco__Type__c='Text',disco__Section__c=section3.Id,disco__Form_Template__c=template.Id, disco__Order__c = 3);
		insert new List<disco__Question__c>{question1,question2,question3};
		disco__Form__c form = new disco__Form__c(disco__Form_Template__c=template.Id);
		insert form; 

		disco__Answer__c answer1 = [Select Id from disco__Answer__c where disco__Question__c = :question1.Id];
		answer1.disco__Answer__c = '1 file(s)';
		answer1.disco__Long_Text_Answer__c = '[{"versionID":"0681K00000lrxEfQAI","externalFileID":"QwnRflwaQcZfUpVWnyfKO7","error":"","docTitle":"8_24_2021_5-44-20pm","docSize":"290 KB"},{"versionID":"0681K00000lrxJSQAY","externalFileID":"cQlVe2srXuHfNPAV5mbFWc","error":"","docTitle":"8_30_2021_12-49-40pm","docSize":"89 KB"}]';	
		
		disco__Answer__c answer2 = [Select Id from disco__Answer__c where disco__Question__c = :question2.Id];
		answer2.disco__Answer__c = '12/12/2012';
		answer2.disco__Date_Answer__c= Date.newInstance(2012,12,12);
		
		disco__Answer__c answer3 =  [Select Id from disco__Answer__c where disco__Question__c = :question3.Id];
		answer3.disco__Answer__c = '3<4 && 3<5';
		answer3.disco__Text_Answer__c = answer3.disco__Answer__c;
		update new List<disco__Answer__c>{answer1,answer2,answer3};

	} 
 
	@istest
	public static void testgetLineItemsAsListSObject(){
		disco__Form__c form = [Select Id From disco__Form__c limit 1];
		disco__Section__c section = [Select Id, Name From disco__Section__c limit 1];
	

		Test.startTest();
		List<disco__Answer__c> answerList = (List<disco__Answer__c>)new CallableYourekaSDocsTable().call('getLineItemsAsListSObject',new Map<String,Object>{'recordId'=>form.Id});
		Test.stopTest();
		system.assertEquals(3,answerList.size());
	}


	@istest
	public static void testExtensionMalformedCallException(){
		disco__Form__c form = [Select Id From disco__Form__c limit 1];
		try {

			List<disco__Answer__c> answerList = (List<disco__Answer__c>)new CallableYourekaSDocsTable().call('',new Map<String,Object>{'recordId'=>form.Id});

		}
		catch(CallableYourekaSDocsTable.ExtensionMalformedCallException e) {
			System.assert(true, 'expected');
		}
		catch(Exception e){
			System.assert(false, 'unexpected exception:' + e.getMessage());
		}
	}


	@istest
	public static void getAnswersAsList(){
		disco__Form__c form = [Select Id From disco__Form__c limit 1];
		disco__Section__c section = [Select Id, Name From disco__Section__c limit 1];
	
		Map<String,String> options = new Map<String,String>();
		options.put('returnAsTable','false');
		options.put('tableCSSName','');
		options.put('createTableTag','false');
		options.put('includeContentImages','true');
		options.put('includePhotosInline','true');
		options.put('contentImagesOnly','false');
		options.put('photosOnly','false');
		options.put('radioButtonsAsColumn','true');
		options.put('sectionName','');
		options.put('queryWhereClause','');
		options.put('formId',form.Id);

		Test.startTest();
		Object sbAnswerList = new CallableYourekaSDocsTable().call('getAnswers',options);
		try{
			List<disco__Answer__c> answerList = (List<disco__Answer__c>)sbAnswerList;
			System.assertEquals(3, answerList.size());
		}
		catch(Exception e)
		{
			System.assert(false,'with returnAsTable false, getAnswers should return a list of Answers');
		}
	}
	@istest
	public static void getAnswersAsTable(){
		disco__Form__c form = [Select Id From disco__Form__c limit 1];
		disco__Section__c section = [Select Id, Name From disco__Section__c limit 1];
	
		Map<String,String> options = new Map<String,String>();
		options.put('includeContentImages','true');
		options.put('includePhotosInline','true');
		options.put('contentImagesOnly','false');
		options.put('photosOnly','false');
		options.put('radioButtonsAsColumn','true');
		options.put('sectionName','');
		options.put('queryWhereClause','');
		options.put('formId',form.Id);
		options.put('returnAsTable','true');
		options.put('tableCSSName','myClass');
		options.put('createTableTag','true');
		options.put('hTMLName','html');
		Test.startTest();
		Object sbAnswerTable = new CallableYourekaSDocsTable().call('getAnswers',options);
		try{
			Map<String,String> answerMap = (Map<String,String>)sbAnswerTable;
			String answerTable = answerMap.get(options.get('hTMLName'));
			String exptectedTableStart = '<table class="'+options.get('tableCSSName')+'">';
			System.assertEquals(exptectedTableStart,answerTable.left(exptectedTableStart.length()),'html should start with \'<table>\'');
			System.assertEquals(6, answerTable.countMatches('<td>'),'3 labels, 3 answers');
		}
		catch(Exception e)
		{
			System.assert(false,'with returnAsTable true, getAnswers should return a Map<String,String>');
		}
		options.put('photosOnly','true');
		sbAnswerTable = new CallableYourekaSDocsTable().call('getAnswers',options);
		try{
			Map<String,String> answerMap = (Map<String,String>)sbAnswerTable;
			String answerTable = answerMap.get(options.get('hTMLName'));
			String exptectedTableStart = '<table class="'+options.get('tableCSSName')+'">';
			System.assertEquals(exptectedTableStart,answerTable.left(exptectedTableStart.length()),'html should start with \'<table>\'');
			System.assertEquals(2, answerTable.countMatches('<td>'),'1 labels, 1 photo answers');
		}
		catch(Exception e)
		{
			System.assert(false,'with returnAsTable true, getAnswers should return a Map<String,String>');
		}		
		Test.stopTest();
	}


}