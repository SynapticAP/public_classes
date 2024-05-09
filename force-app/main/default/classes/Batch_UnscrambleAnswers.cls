public with sharing class Batch_UnscrambleAnswers implements Database.Batchable<sObject>,Database.stateful {
	
	String successResults='';
	String failureResults='';
	List<disco__Answer__c> fixedAnswers = new List<disco__Answer__c>();
	Boolean updateAnswers;

	public Batch_UnscrambleAnswers(Boolean doUpdate)
	{
		updateAnswers = doUpdate;
	}


	public Database.QueryLocator start(Database.BatchableContext BC) 
	{
		String query='Select Id, Name, disco__Form_Mobile_ID__c From disco__Answer__c Where Template_Mismatch__c = true';
		return Database.getQueryLocator(query);
	}


   	public void execute(Database.BatchableContext BC, List<sObject> scope) 
	{
		List<disco__Answer__c>fixedAnswers = new List<disco__Answer__c>();
		Set<String> mobileIds = new Set<String>();
		for (disco__Answer__c ans : (List<disco__Answer__c>)scope)
			if (ans.disco__Form_Mobile_ID__c != null)
				mobileIds.add(ans.disco__Form_Mobile_ID__c);
		List<disco__Form__c> formsWMobileId = [Select Id, disco__Mobile_ID__c From disco__Form__c where disco__Mobile_ID__c in :mobileIds];
		Map<String,Id> mobileId2FormId = new Map<String,Id>();
		for (disco__Form__c form : formsWMobileId)
			mobileId2FormId.put(form.disco__Mobile_ID__c,form.Id);
		for (disco__Answer__c ans : (List<disco__Answer__c>)scope)
			fixAnswer(ans,mobileId2FormId);
	}

	public static String  formatAnsNum(Integer num)
	{
		String result = String.valueOf(num);
		result = 'A-'+'0'.repeat(6-result.length()) +result;
		return result;
	}

	public void fixAnswer(disco__Answer__c ans,Map<String,Id> mobileId2FormId)
	{
		if (mobileId2FormId.get(ans.disco__Form_Mobile_ID__c)!=null)
		{
			ans.disco__Form__c = mobileId2FormId.get(ans.disco__Form_Mobile_ID__c);
			successResults+= ans.name+' ('+ans.Id+') fixed via mobile Id. Moved to '+ans.disco__Form__c+'\n';
			fixedAnswers.add(ans);
		}
		else
		{
			Integer ansNumber = Integer.valueOf(ans.name.removeStart('A-'));
			String priorAnsNum = formatAnsNum(ansNumber-1);
			String nextAnsNum  = formatAnsNum(ansNumber+1);
			List<String>beforeAndAfternum = new List<String>{priorAnsNum,nextAnsNum};
			system.debug('looking for '+beforeAndAfternum);
			List<disco__Answer__c> beforeAndAfter = [Select Id,disco__Form__c From disco__Answer__c Where Name in :beforeAndAfterNum];
			system.debug('found '+beforeAndAfter);
			if (beforeAndAfter.size() != 2)
				failureResults+= ans.name+' ('+ans.Id+') didn\'t find both before and after \n';
			else 
			{
				if (beforeAndAfter[0].disco__Form__c != beforeAndAfter[1].disco__Form__c  )	
					failureResults+= ans.name+' ('+ans.Id+') before and after didn\'t match ('+beforeAndAfter[0].disco__Form__c+' vs '+beforeAndAfter[1].disco__Form__c+')\n';
				else 
				{
					ans.disco__Form__c = beforeAndAfter[0].disco__Form__c;
					successResults+= ans.name+' ('+ans.Id+') fixed via before and after. Moved to '+ans.disco__Form__c+'\n';
					fixedAnswers.add(ans);
				}
			}
		}
	}

	// mandatory finish
	public  void finish(Database.BatchableContext BC) {
		if (updateAnswers)
			update fixedAnswers;
		system.debug('Successes:\n'+successResults);
		system.debug('Failures:\n'+failureResults);
	}


	public static void run(Boolean doUpdate)
	{
		Batch_UnscrambleAnswers me = new Batch_UnscrambleAnswers(doUpdate);
		Database.executeBatch(me, 50);
	}

}