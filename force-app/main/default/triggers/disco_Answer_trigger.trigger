trigger disco_Answer_trigger on disco__Answer__c (before update) {
	// prevent an answer from being moved from one form to another 
	for (Integer i = 0; i < Trigger.new.size(); i++)
		if (Trigger.old[i].disco__Form__c != null && Trigger.new[i].disco__Form__c != Trigger.old[i].disco__Form__c) 
			Trigger.new[i].disco__Form__c = Trigger.old[i].disco__Form__c;
			
}