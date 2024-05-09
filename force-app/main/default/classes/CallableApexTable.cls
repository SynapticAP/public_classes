global class CallableApexTable implements Callable {
    public Object call(String action, Map<String,Object> args) {
        switch on action {
            when 'getLineItemsAsListSObject' {
				Integer formNumber = Integer.valueOf((String)args.get('formNumber'));
                return this.getLineItemsAsListSObject((String)args.get('recordId'), formNumber);
            }
            when else {
                throw new ExtensionMalformedCallException('Method not implemented');
            }
        }
    }
 
    public class ExtensionMalformedCallException extends Exception {}
    public List<disco__Answer__c> getLineItemsAsListSObject(String recordId, Integer formNumber) {
        
        String url1 = '/servlet/servlet.ImageServer?id&#61;';
        String url2 = '&#38;oid&#61;00D1b000000Dd2WEAS';
        Integer formOffset = formNumber - 1;
        List<Integer> lst = new List<Integer>();
        
        List<disco__Form__c> searchListTempName = [
        SELECT disco__Form_Template_Name__c
		FROM disco__Form__c
		WHERE Service_Order__r.Id =:recordId
        ORDER BY id
        LIMIT :formNumber
		OFFSET :formOffset ];
        
		String fname = 'null';      
        
        if(searchListTempName.Size() != 0){
            fname = String.valueOf(searchListTempName[0].disco__Form_Template_Name__c);
        }
        
        
         
        List<disco__Answer__c> searchList = [SELECT disco__Answer__c, disco__Form__r.Service_Order__r.Id, 
			 disco__Question__r.disco__Label__c, disco__Question__r.disco__Image_Version_ID__c, disco__Question__r.disco__Section__r.Name, 
             disco__Form__r.disco__Form_Template_Name__c, disco__Form__r.id, disco__Question__r.disco__Order__c
                                                 
		FROM disco__Answer__c 
		WHERE disco__Form__r.Service_Order__r.Id =:recordId
        AND disco__Form__r.disco__Form_Template_Name__c =:fname                                    
        ORDER BY disco__Form__r.id, disco__Question__r.disco__Order__c ASC
                                            ];

        
    /*    List<disco__Answer__c> filtered = new List<disco__Answer__c>();  */
        
        
        for (disco__Answer__c li : searchList) {
            if(li.disco__Question__r.disco__Section__r.Name != null && li.disco__Question__r.disco__Section__r.Name.contains('&')){
                      li.disco__Question__r.disco__Section__r.Name = li.disco__Question__r.disco__Section__r.Name.replace('&', 'and');
                    
                }
                   
                  if(li.disco__Question__r.disco__Label__c != null && li.disco__Question__r.disco__Label__c.contains('&')){
                      li.disco__Question__r.disco__Label__c = li.disco__Question__r.disco__Label__c.replace('&', 'and');
                    
                } 
            
            if(li.disco__Question__r.disco__Label__c != null && li.disco__Question__r.disco__Label__c.contains('</strong>') ){
                     
                    li.disco__Question__r.disco__Label__c = li.disco__Question__r.disco__Label__c.substringBetween('</span>','</strong>'); 
              
                } 
            
            if(li.disco__Question__r.disco__Label__c != null && li.disco__Question__r.disco__Label__c.contains('depth gauge')  ){
                 
                    li.disco__Question__r.disco__Label__c = li.disco__Question__r.disco__Label__c.substringBetween('>','</p>');
           
                }   
            
            if(String.valueOf(li.disco__Question__r.disco__Image_Version_ID__c) != null){
                String imgs;
         
                imgs+='lt#img class="diagrams" src=quot#' + url1 + String.valueOf(li.disco__Question__r.disco__Image_Version_ID__c) + url2 + 'quot# /gt#';
                
                  imgs = imgs.remove('null');

                li.disco__Question__r.disco__Label__c = imgs; 
             
                }
                
           /*   filtered.add(li);  */
                
                
            
            
                   
            }
        
        return searchList;           
    }    
}