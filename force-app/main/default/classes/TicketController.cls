public with sharing class TicketController {
    @AuraEnabled(cacheable=true)
    public static List<Case> getCases() {
        return [SELECT Id, CaseNumber, Subject, Status FROM Case WHERE Status IN ('New', 'Working', 'Escalated','Closed')];
    }
   @AuraEnabled(cacheable=true)
    public static Map<String,Integer> getCaseCount() {
        Map<String,Integer> caseCount = new Map<String,Integer>();
        List<AggregateResult> results = [SELECT Status, COUNT(Id) caseCount FROM Case WHERE Status IN ('New', 'Working', 'Escalated','Closed') GROUP BY Status];
        for (AggregateResult ar : results) {
            caseCount.put((String)ar.get('Status'), (Integer)ar.get('caseCount'));
        }
        return caseCount;
    }
}