@isTest
public with sharing class Batch_UnscrambleAnswers_Test {

	@isTest
	public static void testBatch()
	{
		disco__Form_Template__c ft = new disco__Form_Template__c (disco__Status__c='In Use');
		insert ft;
		disco__Section__c sec = new disco__Section__c(disco__Form_Template__c = ft.id);
		insert sec;
		disco__Question__c qBefore = new disco__Question__c(disco__Form_Template__c = ft.id,disco__Section__c=sec.id,disco__Type__c='Text');
		insert qBefore;
		disco__Question__c middleQ = new disco__Question__c(disco__Form_Template__c = ft.id,disco__Section__c=sec.id,disco__Type__c='Text');
		insert middleQ;
		disco__Question__c qAfter = new disco__Question__c(disco__Form_Template__c = ft.id,disco__Section__c=sec.id,disco__Type__c='Text');
		insert qAfter;
		disco__Form__c form = new disco__Form__c(disco__Form_Template__c=ft.id);
		insert form;
	
		disco__Form_Template__c ft2 = new disco__Form_Template__c (disco__Status__c='In Use');
		insert ft2;
		disco__Section__c sec2 = new disco__Section__c(disco__Form_Template__c = ft2.id);
		insert sec2;
		disco__Question__c q2 = new disco__Question__c(disco__Form_Template__c = ft2.id,disco__Section__c=sec2.id,disco__Type__c='Text');
		insert q2;
		disco__Form__c form2 = new disco__Form__c(disco__Form_Template__c=ft2.id);
		insert form2;
		
		disco__Answer__c ans =[Select Id, disco__Form__c From disco__Answer__c where disco__Question__c = :middleQ.id ];
		ans.disco__Form__c = form2.id;
		update ans;
		Test.startTest();
		Batch_UnscrambleAnswers batch = new Batch_UnscrambleAnswers(true);
		Database.executeBatch(batch);
		Test.stopTest();
		ans = [Select Id, disco__Form__c From disco__Answer__c where disco__Question__c = :middleQ.id ];
		system.assertEquals(form.id,ans.disco__Form__c,'got moved back to original form');

	}
}