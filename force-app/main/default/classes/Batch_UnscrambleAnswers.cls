// this class finds scrambled answers and tries to unscramble them by looking at the form mobile id or the answer number
// it is designed to be invoked from the developer console, logging out the results via system.debug
public with sharing class Batch_UnscrambleAnswers implements Database.Batchable<sObject>,Database.stateful {
    
    String successResults='';
    String failureResults='';
    List<disco__Answer__c> reportedAnswers = new List<disco__Answer__c>();
    Boolean updateAnswers;
    static final Integer plusminus = 100;

    public Batch_UnscrambleAnswers(Boolean doUpdate)
    {
        updateAnswers = doUpdate;
    }


    public Database.QueryLocator start(Database.BatchableContext BC) 
    {
        String query='Select Id, Name, disco__Form__c,disco__Form_Mobile_ID__c From disco__Answer__c Where Template_Mismatch__c = true ';
        return Database.getQueryLocator(query);
    }


    public void execute(Database.BatchableContext BC, List<sObject> scope) 
    {
        // first create a map for the ones that have mobile id
        List<disco__Answer__c>fixedAnswers = new List<disco__Answer__c>();
        Set<String> mobileIds = new Set<String>();
        for (disco__Answer__c ans : (List<disco__Answer__c>)scope)
            if (ans.disco__Form_Mobile_ID__c != null)
                mobileIds.add(ans.disco__Form_Mobile_ID__c);
        List<disco__Form__c> formsWMobileId = [Select Id, disco__Mobile_ID__c From disco__Form__c where disco__Mobile_ID__c in :mobileIds];
        Map<String,Id> mobileId2FormId = new Map<String,Id>();
        for (disco__Form__c form : formsWMobileId)
            mobileId2FormId.put(form.disco__Mobile_ID__c,form.Id);
        // now, try to fix the answers via the mobile id or answer number if there is no mobile id
        for (disco__Answer__c ans : (List<disco__Answer__c>)scope)
        {
            disco__Answer__c fixedAnswer = fixAnswer(ans,mobileId2FormId);
            if (fixedAnswer != null)
            {
                fixedAnswers.add(fixedAnswer);
                reportedAnswers.add(fixedAnswer);
            }
        }
            
        if (updateAnswers){
            update fixedAnswers;
        }
    }

    public static String  formatAnsNum(Integer num)
    {
        String result = String.valueOf(num);
        result = 'A-'+'0'.repeat(6-result.length()) +result;
        return result;
    }

    public  List<disco__Answer__c> findBeforeAndAfter(List<disco__Answer__c>answerList ,disco__Answer__c thisAnswer)
    {
        List<disco__Answer__c> result = new List<disco__Answer__c>();
        Integer myIndex = null;
        for (Integer i=0;i<answerList.size();i++)
            if (answerList[i].Id == thisAnswer.Id)
        {
            myIndex = i;
            break;
        }
        for (Integer i=myIndex-1;i>=0;i--)
        {
            if (thisAnswer.disco__Form__c != answerList[i].disco__Form__c)
            {
                result.add(answerList[i]);
                break;
            }
        }
        for (Integer i=myIndex+1;i<answerList.size();i++)
        {
            if (thisAnswer.disco__Form__c != answerList[i].disco__Form__c)
            {
                result.add(answerList[i]);
                break;
            }
        }
        return result;
    }

    public disco__Answer__c fixAnswer(disco__Answer__c ans,Map<String,Id> mobileId2FormId)
    {
        if (mobileId2FormId.get(ans.disco__Form_Mobile_ID__c)!=null)
        {
            //easy case, fix by mobile id
            ans.disco__Form__c = mobileId2FormId.get(ans.disco__Form_Mobile_ID__c);
            successResults+= ans.name+' ('+ans.Id+') fixed via mobile Id. Moved to '+ans.disco__Form__c+'\n';
            return ans;
        }
        else
        {
            disco__Answer__c resultAnswer = null;
            // could not find the answer via mobile id, try to find the answer before and after it. If the belong to a different form, this answer should be there too
            Integer ansNumber = Integer.valueOf(ans.name.removeStart('A-'));
            Set<String>answerRange = new Set<String>();
            for (Integer ansNameInRange=ansNumber-plusminus;ansNameInRange<ansnumber+plusminus;ansNameInRange++)
                answerRange.add(formatAnsNum(ansNameInRange));
            List<disco__Answer__c> beforeAndAfterWideNet = [Select Id,name,disco__Form__c From disco__Answer__c Where Name in :answerRange order by name];
            List<disco__Answer__c>beforeAndAfter = findBeforeAndAfter(beforeAndAfterWideNet,ans);
            if (beforeAndAfter.size() != 2)
                failureResults+= ans.name+' ('+ans.Id+') didn\'t find both before and after \n';
            else 
            {
                if (beforeAndAfter[0].disco__Form__c != beforeAndAfter[1].disco__Form__c) 
                    failureResults+= ans.name+' ('+ans.Id+') before and after didn\'t match ('+beforeAndAfter[0].disco__Form__c+' vs '+beforeAndAfter[1].disco__Form__c+')\n';
                else if (beforeAndAfter[0].disco__Form__c == ans.disco__Form__c)
                {
                    failureResults+= ans.name+' ('+ans.Id+') before and after are same as the one for this answer '+beforeAndAfter[0].disco__Form__c+' vs '+beforeAndAfter[1].disco__Form__c+')\n';
                }
                else
                {
                    String oldFormId = ans.disco__Form__c;
                    ans.disco__Form__c = beforeAndAfter[0].disco__Form__c;
                    successResults+= ans.name+' ('+ans.Id+') fixed via before and after. Moved to '+ans.disco__Form__c+' from form '+oldFormId+'\n';
                    resultAnswer = ans;                    
                }
            }
            return resultAnswer;
        }
    }

    // mandatory finish
    public  void finish(Database.BatchableContext BC) {
        
        system.debug('Successes:\n'+successResults);
        system.debug('Failures:\n'+failureResults);
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new List<String>();
		toAddresses.add(UserInfo.getUserEmail());
		mail.setToAddresses(toAddresses);
		mail.setSenderDisplayName('Youreka');
		mail.setSubject('Answer Unscramble');
		mail.setPlainTextBody('Successes:\n'+successResults+'\n\n\nFailures:\n'+failureResults);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail } );
    }


    public static void run(Boolean doUpdate)
    {
        Batch_UnscrambleAnswers me = new Batch_UnscrambleAnswers(doUpdate);
        Database.executeBatch(me, 50);
    }

}