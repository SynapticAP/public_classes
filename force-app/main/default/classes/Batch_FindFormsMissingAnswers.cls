public with sharing class Batch_FindFormsMissingAnswers implements Database.Batchable<sObject>,Database.stateful {

	public List<String> tooManyAnswers = new List<String>();
	public List<String> tooFewAnswers = new List<String>();


    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query='Select Id, Name,disco__Form_Template__c From disco__Form__c Where disco__Archived__c = false and disco__Needs_Answers_Created__c = false';
        return Database.getQueryLocator(query);
    }

    public static Set<ID>idsFromSObjects(List<SObject>sObjects,String fieldName)
    {
        Set<ID>result = new Set<ID>();
        for (SObject sObj : sObjects)
            if (sObj.get(fieldName)!=NULL)
                result.add((ID)sObj.get(fieldName));
        return result;
    }



    public void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        Set<Id> templateIds = idsFromSObjects(scope, 'disco__Form_Template__c');
        List<AggregateResult> stdSecQuestionsInTemplates = [Select disco__Form_Template__c,count(id) cnt 
                        From disco__Question__c 
                        Where disco__Section__r.disco__Type__c not in ('Linked','Task') and disco__Form_Template__c in :templateIds
                        Group By disco__Form_Template__c];
		// future work - check on linked section. Skip for now
        // List<AggregateResult> linkedSecQuestionsInTemplates = [Select disco__Form_Template__c,count(id) cnt 
        //              From disco__Question__c 
        //              Where disco__Section__r.disco__Type__c  in ('Linked','Task') and disco__Form_Template__c in :templateIds
        //              Group By disco__Form_Template__c];
        Map<Id,Integer> templateId2StdSecQCnt = new Map<Id,Integer>();
        // Map<Id,Integer> templateId2LinkedSecQCnt = new Map<Id,Integer>();
        for (AggregateResult agr : stdSecQuestionsInTemplates)
            templateId2StdSecQCnt.put((Id)agr.get('disco__Form_Template__c'),double.valueOf(agr.get('cnt')).intValue());
        // for (AggregateResult agr : linkedSecQuestionsInTemplates)
        //  templateId2LinkedSecQCnt.put((Id)agr.get('disco__Form_Template__c'),double.valueOf(agr.get('cnt')).intValue());
        for (disco__Form__c frm : (List<disco__Form__c>)scope)
        {
            Integer answerCount = [Select Count() From disco__Answer__c where disco__Form__c = :frm.id and disco__Linked_Section_Order__c=null];
			Integer questionCount = templateId2StdSecQCnt.get(frm.disco__Form_Template__c);
            if (answerCount != questionCount && answerCount>0)
				if (answerCount>questionCount)
					tooManyAnswers.add(frm.name+' Expected '+templateId2StdSecQCnt.get(frm.disco__Form_Template__c)+' questions, found '+answerCount);
				else
					tooFewAnswers.add(frm.name+' Expected '+templateId2StdSecQCnt.get(frm.disco__Form_Template__c)+' questions, found '+answerCount);
        }
    }   

    // mandatory finish, log out findings
    public  void finish(Database.BatchableContext BC) {
        system.debug('Findings:\n\n'
			+'Too few:\n'+String.join(tooFewAnswers,'\n')
			+'\n\nToo many:\n'+String.join(tooManyAnswers,'\n'));
    }


}