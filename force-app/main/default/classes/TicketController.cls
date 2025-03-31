public with sharing class TicketController {

    /**
     * Get all cases
     * @return List<Case> - List of cases
     * @author Amjad Ali
     */
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {
        return [SELECT Id, CaseNumber, Subject,Status,CreatedDate FROM Case WHERE Status IN ('New', 'Working', 'Escalated','Closed')];
    }

    /**
     * Get case count by status
     * @return Map<String,Integer> - Map of case count by status
     * @author Amjad Ali
     */
   @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getCaseCount() {
        Map<String,Integer> caseCount = new Map<String,Integer>();
        List<AggregateResult> results = [SELECT Status, COUNT(Id) caseCount FROM Case WHERE Status IN ('New', 'Working', 'Escalated','Closed') GROUP BY Status];
        for (AggregateResult ar : results) {
            caseCount.put((String)ar.get('Status'), (Integer)ar.get('caseCount'));
        }
        return caseCount;
    }
    
    /**
     * Get product details for case
     * @param caseIds - List of case Ids
     * @return Map<String,List<String>> - Map of product details for case
     * @author Amjad Ali
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,List<String>> productDetailsForCaseID(List<String> caseIds) {
        List<Equipment_Maintenance_Item__c> itemList = [SELECT Maintenance_Request__r.Id, Equipment__r.Name, Equipment__r.Current_Inventory__c FROM 
        Equipment_Maintenance_Item__c WHERE Maintenance_Request__r.Id IN :caseIds];
        Map<String,List<String>> productDetails = new Map<String,List<String>>();
        for(Equipment_Maintenance_Item__c item : itemList) {
            if(!productDetails.containsKey(item.Maintenance_Request__r.Id)) {
                productDetails.put(item.Maintenance_Request__r.Id, new List<String>());
            }
            productDetails.get(item.Maintenance_Request__r.Id).add(item.Equipment__r.Name);
            productDetails.get(item.Maintenance_Request__r.Id).add(
                String.valueOf(item.Equipment__r.Current_Inventory__c != null ? item.Equipment__r.Current_Inventory__c : 0)
            );
        }
        return productDetails;
    }

}