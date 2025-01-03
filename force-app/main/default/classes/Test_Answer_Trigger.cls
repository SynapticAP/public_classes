@istest
public with sharing class Test_Answer_Trigger {
	// test to make sure that an answer does not get moved from one form to another
	public static testmethod void test_form_restore()
	{
		disco__Form_Template__c ft = new disco__Form_Template__c(name='test template',disco__Status__c='In Use');
		insert ft;
		disco__Section__c sec = new disco__Section__c(disco__Form_Template__c = ft.Id,name='section');
		insert sec;
		disco__Question__c q1 = new disco__Question__c(disco__Form_Template__c=ft.id,disco__Section__c=sec.Id,disco__Label__c='question',
								disco__Type__c='Text');
		disco__Question__c q2 = new disco__Question__c(disco__Form_Template__c=ft.id,disco__Section__c=sec.Id,disco__Label__c='question2',
								disco__Type__c='Text');
		insert new List<disco__Question__c>{q1,q2};
		disco__Form__c form1 = new disco__Form__c(disco__Form_Template__c=ft.Id);
		disco__Form__c form2 = new disco__Form__c(disco__Form_Template__c=ft.Id);
		insert new List<disco__Form__c>{form1,form2};
		Test.startTest();
		disco__Answer__c ansQ1F1 = [Select Id,disco__Form__c 
									From disco__Answer__c
									Where disco__Form__c = :form1.Id and disco__Question__c = :q1.Id];
		ansQ1F1.disco__Form__c = form2.Id;
		update ansQ1F1;
		ansQ1F1 = [Select Id,disco__Form__c 
									From disco__Answer__c
									Where id = :ansQ1F1.Id];
		System.assertEquals(ansQ1F1.disco__Form__c,form1.Id,'change of form should be restored by trigger');
		ansQ1F1.disco__Text_Answer__c = 'test';
		update ansQ1F1;
		ansQ1F1 = [Select Id,disco__Form__c ,disco__Text_Answer__c
									From disco__Answer__c
									Where id = :ansQ1F1.Id];
		System.assertEquals('test',ansQ1F1.disco__Text_Answer__c,'regular update goes through');
		System.assertEquals(ansQ1F1.disco__Form__c,form1.Id,'form not affected');

		Test.stopTest();
	}
}