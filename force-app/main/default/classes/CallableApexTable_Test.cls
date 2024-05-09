@istest
public with sharing class CallableApexTable_Test {

 @testSetup
    static void setup() {
  
	

        } 
 
    @istest
    public static void testgetLineItemsAsListSObjectApexTable(){

		WorkOrder WO = createWorkOrder();

        
        disco__Form_Template__c template = new disco__Form_Template__c(disco__Status__c='In Use', Name = 'Test');
        

		disco__Form_Template__c template2 = new disco__Form_Template__c(disco__Status__c='In Use', Name = 'Test2');
        insert new List<disco__Form_Template__c>{template, template2}; 
        

		disco__Form__c form = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form2 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
       

		disco__Form__c form3 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form4 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);

		disco__Form__c form5 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form6 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
       

		disco__Form__c form7 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
       

     	disco__Form__c form8 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form9 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);

		disco__Form__c form10 = new disco__Form__c(disco__Form_Template__c=template2.Id, Service_Order__c = WO.Id);
        
		insert new List<disco__Form__c>{form, form2, form3, form4, form5, form6, form7, form8, form9};

		insert form10;
      

        disco__Section__c section = new disco__Section__c(disco__Form_Template__c=template.Id, Name = '"Test & Test"');
        insert section;
        
        disco__Question__c question = new disco__Question__c(disco__Label__c='<p class="ql-align-center">Use depth gauge, Part Number 3164438 to measure protrusion in the clamped state.</p><strong><span class="ql-cursor"></span>*Refer to QSOL for Specifications</strong> & Test',disco__Section__c=section.Id,disco__Form_Template__c=template2.Id, disco__Order__c = 1);
       

		disco__Question__c question2 = new disco__Question__c(disco__Label__c='<p class="ql-align-center">Use depth gauge, Part Number 3164438 to measure protrusion in the clamped state.</p>',disco__Section__c=section.Id,disco__Form_Template__c=template2.Id, disco__Order__c = 2);
        

		disco__Question__c question3 = new disco__Question__c(disco__Label__c='Photos',disco__Section__c=section.Id,disco__Form_Template__c=template2.Id, disco__Image_Version_ID__c='0151b000000KcYWAA0',disco__Type__c = 'Image', disco__Order__c = 3);
        insert new List<disco__Question__c>{question, question2, question3}; 


        disco__Answer__c answer = new disco__Answer__c(disco__Form_Template__c = template2.Id ,disco__Form__c = form10.Id, disco__Question__c = question.Id, disco__Answer__c = '1 file(s)');


		disco__Answer__c answer2 = new disco__Answer__c(disco__Form_Template__c = template2.Id ,disco__Form__c = form10.Id, disco__Question__c = question2.Id, disco__Answer__c = '1 file(s)');
        

		disco__Answer__c answer3 = new disco__Answer__c(disco__Form_Template__c = template2.Id ,disco__Form__c = form10.Id, disco__Question__c = question3.Id, disco__Answer__c = '1 file(s)', disco__Text_Answer__c = 'test', disco__Long_Text_Answer__c = '[{"versionID":"0681K00000lrxEfQAI","externalFileID":"QwnRflwaQcZfUpVWnyfKO7","error":"","docTitle":"8_24_2021_5-44-20pm","docSize":"290 KB"},{"versionID":"0681K00000lrxJSQAY","externalFileID":"cQlVe2srXuHfNPAV5mbFWc","error":"","docTitle":"8_30_2021_12-49-40pm","docSize":"89 KB"}]');
		insert new List<disco__Answer__c>{answer, answer2, answer3}; 


		Test.startTest();

		
		

        List<disco__Answer__c> answerList = (List<disco__Answer__c>)new CallableApexTable().call('getLineItemsAsListSObject',new Map<String,Object>{'recordId'=>WO.Id, 'formNumber'=>'10'});
        
        system.assertEquals(3,answerList.size());

		Test.stopTest();

		
    }


@istest
    public static void testExtensionMalformedCallExceptionApexTable(){
        WorkOrder WO = createWorkOrder();
       

        try {

            List<disco__Answer__c> answerList = (List<disco__Answer__c>)new CallableApexTable().call('',new Map<String,Object>{'recordId'=>WO.Id, 'formNumber'=>'10'});

        }
        catch(CallableApexTable.ExtensionMalformedCallException e) {
            System.assert(true, 'expected');
        }
        catch(Exception e){
            System.assert(false, 'unexpected exception:' + e.getMessage());
        }
    }


 @istest
    public static void testgetLineItemsAsListSObjectFormName(){

		WorkOrder WO = createWorkOrder();

        
        disco__Form_Template__c template = new disco__Form_Template__c(disco__Status__c='In Use', Name = 'Test');
        

		disco__Form_Template__c template2 = new disco__Form_Template__c(disco__Status__c='In Use', Name = 'Test2');
        insert new List<disco__Form_Template__c>{template, template2}; 
        

		disco__Form__c form = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form2 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
       

		disco__Form__c form3 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form4 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);

		disco__Form__c form5 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form6 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
       

		disco__Form__c form7 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
       

     	disco__Form__c form8 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);
        

		disco__Form__c form9 = new disco__Form__c(disco__Form_Template__c=template.Id, Service_Order__c = WO.Id);

		disco__Form__c form10 = new disco__Form__c(disco__Form_Template__c=template2.Id, Service_Order__c = WO.Id);
        
		insert new List<disco__Form__c>{form, form2, form3, form4, form5, form6, form7, form8, form9};
      
  		insert form10;

		Test.startTest();

		
		

        List<disco__Form__c> formList = (List<disco__Form__c>)new CallableApexFormName().call('getLineItemsAsListSObject',new Map<String,Object>{'recordId'=>WO.Id, 'formNumber'=>'10'});
        
        system.assertEquals(1,formList.size());

        system.assertEquals('Test2',formList[0].disco__Form_Template_Name__c);

		Test.stopTest();

		
    }


@istest
    public static void testExtensionMalformedCallExceptionFormName(){
        WorkOrder WO = createWorkOrder();
       

        try {

            List<disco__Answer__c> answerList = (List<disco__Answer__c>)new CallableApexFormName().call('',new Map<String,Object>{'recordId'=>WO.Id, 'formNumber'=>'10'});

        }
        catch(CallableApexFormName.ExtensionMalformedCallException e) {
            System.assert(true, 'expected');
        }
        catch(Exception e){
            System.assert(false, 'unexpected exception:' + e.getMessage());
        }
    }


    public static WorkOrder createWorkOrder(){
        try {
            WorkOrder result = [SELECT id, Status, Subject FROM WorkOrder LIMIT 1];

        	if(result != null){
            	return result;
        	}
        }
        catch(Exception e) {}
        WorkOrder WO = new WorkOrder(Status = 'New', Subject = 'Testing');
		insert WO;
		return WO; 
        
		
	}
}