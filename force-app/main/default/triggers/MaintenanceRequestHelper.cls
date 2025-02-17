public with sharing class MaintenanceRequestHelper {
   
  /**
   * Method to handle the close request and create another maintenance request 
   * after closing the request.
   * @param newRequests (case updated states)
   * @param oldRequests (case previous states) 
   * @author Amjad Ali
   */
   public static void processClosedRequests(List<Case> newRequests, Map<Id, Case> oldRequestMap) {
        List<Case> newMaintenanceRoutineRequests = new List<Case>();
        Set<Id> requestIds = new Set<Id>();
        Map<id,id> oldCaseToNew=new Map<id,id>(); //To map close Case ID to created Case ID

        for (Case req : newRequests) {
            Case oldReq = oldRequestMap.get(req.Id);
            
            if (oldReq != null && oldReq.Status != 'Closed' && req.Status == 'Closed' && 
                (req.Type == 'Repair' || req.Type == 'Routine Maintenance')) {
                
                requestIds.add(req.Id);
            }
        }

        if (requestIds.isEmpty()) {
            return;
        }
          
        /**
         * Fetching equiment details from Equipment_Maintenance_Item__c, which Joins an Equipment record 
         * with a Maintenance Request record, indicating the equipment needed for the maintenance request.
         */
         
        Map<Id, List<Equipment_Maintenance_Item__c>> requestToEquipmentMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        Map<Id, Integer> equipmentCycles = new Map<Id, Integer>();

        for (Equipment_Maintenance_Item__c emi : [
            SELECT Id, Maintenance_Request__c, Equipment__c 
            FROM Equipment_Maintenance_Item__c 
            WHERE Maintenance_Request__c IN :requestIds
        ]) {
            if (!requestToEquipmentMap.containsKey(emi.Maintenance_Request__c)) {
                requestToEquipmentMap.put(emi.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>());
            }
            requestToEquipmentMap.get(emi.Maintenance_Request__c).add(emi);
            equipmentCycles.put(emi.Equipment__c, null); // To fetch cycles in next query
        }

        // Fetch Maintenance Cycles
        for (Product2 eq : [
            SELECT Id, Maintenance_Cycle__c 
            FROM Product2 
            WHERE Id IN :equipmentCycles.keySet()
        ]) {
             if (eq.Maintenance_Cycle__c != null) {
                // Convert Decimal (Number) to Integer
                equipmentCycles.put(eq.Id, Integer.valueOf(eq.Maintenance_Cycle__c));
            }
        }

        // Create new Routine Maintenance Requests
        for (Case req : newRequests) {
            if (!requestToEquipmentMap.containsKey(req.Id)) continue;

            Integer shortestCycle = 2147483647;
            for (Equipment_Maintenance_Item__c emi : requestToEquipmentMap.get(req.Id)) {
                if (equipmentCycles.containsKey(emi.Equipment__c)) {
                    shortestCycle = Math.min(shortestCycle, equipmentCycles.get(emi.Equipment__c));
                }
            }

            if (shortestCycle == 2147483647 || shortestCycle == 0) {
                continue;
              }


            Date dueDate = Date.today().addDays(shortestCycle);

            Case newReq = new Case();
            newReq.Type = 'Routine Maintenance';
            newReq.Subject = 'Routine Checkup - ' + req.Subject;
            newReq.Date_Reported__c  = Date.today();
            newReq.Vehicle__c = req.Vehicle__c;
            newReq.Date_Due__c = dueDate;
            

            newMaintenanceRoutineRequests.add(newReq);
        }

        if (!newMaintenanceRoutineRequests.isEmpty()) {
            insert newMaintenanceRoutineRequests;
        }
        /**
         * Mapping old update case equiment to new created routine maintenance request
         * and creating new Equipment_Maintenance_Item__c records
         * here Equipment_Maintenance_Item__c is a junction object between Equipment and 
         * Maintenance Request
         */

        integer count=0;
        for(Case createdRoutineMaintenance: newMaintenanceRoutineRequests){
               oldCaseToNew.put(newRequests[count].Id,createdRoutineMaintenance.Id);
               count++;
        }
        List<Equipment_Maintenance_Item__c> newEquipmentMaintenanceItemsToMapOldProduct = 
        new List<Equipment_Maintenance_Item__c>();
        
        for(Id caseUpdatedId:oldCaseToNew.keySet()){
            Id createdRoutineMaintenanceId=oldCaseToNew.get(caseUpdatedId);
            if(requestToEquipmentMap.containsKey(caseUpdatedId)){
                for(Equipment_Maintenance_Item__c equipmentMaintenanceItem:requestToEquipmentMap.get(caseUpdatedId)){
                    Equipment_Maintenance_Item__c newEquipmentMaintenanceItem = new Equipment_Maintenance_Item__c();
                    newEquipmentMaintenanceItem.Equipment__c = equipmentMaintenanceItem.Equipment__c;
                    newEquipmentMaintenanceItem.Maintenance_Request__c = createdRoutineMaintenanceId;
                    newEquipmentMaintenanceItemsToMapOldProduct.add(newEquipmentMaintenanceItem);
                }
            }
        }
        if(newEquipmentMaintenanceItemsToMapOldProduct.size()>0){
            insert newEquipmentMaintenanceItemsToMapOldProduct;
        }

    }     
    
}