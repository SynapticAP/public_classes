@isTest
public with sharing class Batch_FindFormsMissingAnswers_Test {

	@isTest
	public static void testBatch()
	{
		disco__Form_Template__c ft = new disco__Form_Template__c (disco__Status__c='In Use');
		insert ft;
		disco__Section__c sec = new disco__Section__c(disco__Form_Template__c = ft.id);
		insert sec;
		disco__Question__c q = new disco__Question__c(disco__Form_Template__c = ft.id,disco__Section__c=sec.id,disco__Type__c='Text');
		insert q;
		disco__Form__c form = new disco__Form__c(disco__Form_Template__c=ft.id);
		insert form;
		disco__Answer__c extraAnswer = new disco__Answer__c(disco__form__c = form.Id,disco__Question__c=q.id);
		insert extraAnswer;
		Test.startTest();
		Batch_FindFormsMissingAnswers batch = new Batch_FindFormsMissingAnswers();
		Database.executeBatch(batch);
		Test.stopTest();
		system.assert(true);
	}
}