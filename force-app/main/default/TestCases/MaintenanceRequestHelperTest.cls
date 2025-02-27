@isTest
public with sharing class MaintenanceRequestHelperTest {

    // declaring global variables
    static Map<Id, Case> oldRequestMap;
    private static List<Equipment_Maintenance_Item__c> equipmentMaintenanceItems;
    private static List<Product2> listEquipments;
    

    @testSetup
    static void setup (){
        // initializing global variables
        listEquipments = new List<Product2>();
        equipmentMaintenanceItems = new List<Equipment_Maintenance_Item__c>();
        
        // creating data for product2 (equipment)
        for (Integer i=1; i<=5; i++) {
            Product2 testEquipment = new Product2(
                Name = 'Product ' + i,
                Warehouse_SKU__c = '55d66226726b611100aaf74' + i,
                Replacement_Part__c = true,
                Cost__c = 100.0,
                Current_Inventory__c = 10,
                Lifespan_Months__c = 12,
                Maintenance_Cycle__c = 30 * (Decimal)i,
                StockKeepingUnit = '100023' + i
            );
            listEquipments.add(testEquipment);
        }
        insert listEquipments;

        // creating maintenance request (case) data
        List<Case> MaintenanceRequests = new List<Case>();
        for( Integer i=1; i<=5; i++){
            Case MaintenanceRequest = new Case(
                Type = (Math.mod(i,2) == 0) ? 'Repair' : 'Routine Maintenance',
                Subject = 'Maintenance Request ' + i,
                Status = 'New'
            
            );
            MaintenanceRequests.add(MaintenanceRequest);
        }
        insert MaintenanceRequests;

        
        // creating equipment maintenance item data
        for(Case req : MaintenanceRequests){
            for(Product2 eq : listEquipments){
                Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(
                    Maintenance_Request__c = req.Id,
                    Equipment__c = eq.Id
                );
                equipmentMaintenanceItems.add(emi);
            }
        }
        insert equipmentMaintenanceItems;
        
}

static void setupOldRequestMap(){
    oldRequestMap = new Map<Id, Case>([SELECT Id, Status, Type FROM Case]);
    listEquipments = [SELECT Id, Maintenance_Cycle__c FROM Product2];
}

static void CreateDateforBulkTest(){
   // initializing global variables
        listEquipments = new List<Product2>();
        equipmentMaintenanceItems = new List<Equipment_Maintenance_Item__c>();
        
        // creating data for product2 (equipment)
        for (Integer i=1; i<=200; i++) {
            Product2 testEquipment = new Product2(
                Name = 'Bluk Product ' + i,
                Warehouse_SKU__c = '55d66226726b611100aaf75' + i,
                Replacement_Part__c = true,
                Cost__c = 100.0,
                Current_Inventory__c = 10,
                Lifespan_Months__c = 12,
                Maintenance_Cycle__c = (Decimal) (Math.mod(i,10)+1) * 30,
                StockKeepingUnit = '100024' + i
            );
            listEquipments.add(testEquipment);
        }
        insert listEquipments;

        // creating maintenance request (case) data
        List<Case> MaintenanceRequests = new List<Case>();
        for( Integer i=1; i<=5; i++){
            Case MaintenanceRequest = new Case(
                Type = (Math.mod(i,2) == 0) ? 'Repair' : 'Routine Maintenance',
                Subject = 'Bulk Maintenance Request ' + i,
                Status = 'New'
            
            );
            MaintenanceRequests.add(MaintenanceRequest);
        }
        insert MaintenanceRequests;

        
        // creating equipment maintenance item data
        for(Case req : MaintenanceRequests){
            for(Product2 eq : listEquipments){
                Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(
                    Maintenance_Request__c = req.Id,
                    Equipment__c = eq.Id
                );
                equipmentMaintenanceItems.add(emi);
            }
        }
        insert equipmentMaintenanceItems;
}

   @isTest
    static void test_processClosedRequestsPostive(){
    setupOldRequestMap();
    List<Case> UpdateCases = new List<Case>();
    for(Case req : oldRequestMap.values()){
        req.Status = 'Closed';
        UpdateCases.add(req);
    }
    update UpdateCases;

     
    Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(UpdateCases, oldRequestMap);
    Test.stopTest();
        // verifying routine maintenance requests is created
    List<Case> routineMaintenanceRequests = [SELECT Id FROM Case WHERE Type = 'Routine Maintenance' and Status = 'New'];
    System.assertEquals(oldRequestMap.size(), routineMaintenanceRequests.size());

        //Verify Equipment Mapping  
    List<Equipment_Maintenance_Item__c> equipmentMaintenanceItemsList = [SELECT Id, Maintenance_Request__c, Equipment__c FROM Equipment_Maintenance_Item__c];
    System.assertEquals(2*oldRequestMap.size() * listEquipments.size(), equipmentMaintenanceItemsList.size());

} 

    /**
     *  Negative Test: Ensure that new cases are NOT created if they are not closed.
     */
    @isTest
    static void testProcessClosedRequests_NegativeUsingStatus() {
        setupOldRequestMap();
        List<Case> updatedCases = new List<Case>();

        for (Case c : oldRequestMap.values()) {
            c.Status = 'Working'; 
            updatedCases.add(c);
        }

        Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(updatedCases, oldRequestMap);
        Test.stopTest();

    
        List<Case> newRequests = [SELECT Id FROM Case WHERE Type like 'Routine Checkup%'];
        System.assertEquals(0, newRequests.size(), 'No Routine Maintenance should be created');
    }

    /**
     * Negative Test: Ensure that new cases are NOT created if they are not of type 'Repair' and 'Routine Maintenance'.
     */
    @isTest
    static void testProcessClosedRequests_NegativeUsingType() {
        setupOldRequestMap();
        List<Case> updatedCases = new List<Case>();

        for (Case c : oldRequestMap.values()) {
            c.Type = 'Other'; 
            updatedCases.add(c);
        }

        Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(updatedCases, oldRequestMap);
        Test.stopTest();

        List<Case> newRequests = [SELECT Id FROM Case WHERE Type like 'Routine Checkup%'];
        System.assertEquals(0, newRequests.size(), 'No Routine Maintenance should be created');
    }

    /**
     * Edge Case: Ensure system handles cases with no equipment mapping.
     */
    @isTest
    static void testProcessClosedRequests_NoEquipment() {
        List<Case> cases = new List<Case>();

        for (Integer i = 1; i <= 5; i++) {
            Case c = new Case(
                Type = 'Repair',
                Status = 'Closed',
                Subject = 'Maintenance Request ' + i
            );
            cases.add(c);
        }
        insert cases;

        Map<Id, Case> caseMap = new Map<Id, Case>();
        for (Case c : cases) {
            caseMap.put(c.Id, c);
        }

        Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(cases, caseMap);
        Test.stopTest();

        List<Case> newRequests = [SELECT Id FROM Case WHERE Subject like 'Routine Checkup%'];
        System.assertEquals(0, newRequests.size(), 'No Routine Maintenance should be created without equipment');
    }

    @isTest
    static void shortCycleIsZero(){
  
       // initializing global variables
        listEquipments = new List<Product2>();
        equipmentMaintenanceItems = new List<Equipment_Maintenance_Item__c>();
        oldRequestMap = new Map<Id, Case>();
        
        // creating data for product2 (equipment)
        for (Integer i=1; i<=200; i++) {
            Product2 testEquipment = new Product2(
                Name = 'Bluk Product ' + i,
                Warehouse_SKU__c = '55d66226726b611100aaf75' + i,
                Replacement_Part__c = true,
                Cost__c = 100.0,
                Current_Inventory__c = 10,
                Lifespan_Months__c = 12,
                Maintenance_Cycle__c = (Math.mod(i,2) == 0) ? 0 : 2147483647, // 0 or max value
                StockKeepingUnit = '100024' + i
            );
            listEquipments.add(testEquipment);
        }
        insert listEquipments;

        // creating maintenance request (case) data
        List<Case> MaintenanceRequests = new List<Case>();
        for( Integer i=1; i<=5; i++){
            Case MaintenanceRequest = new Case(
                Type = (Math.mod(i,2) == 0) ? 'Repair' : 'Routine Maintenance',
                Subject = 'Bulk Maintenance Request ' + i,
                Status = 'New'
            
            );
            MaintenanceRequests.add(MaintenanceRequest);
        }
        insert MaintenanceRequests;

        for(Case req:MaintenanceRequests){
            oldRequestMap.put(req.Id, req);
        }

        
        // creating equipment maintenance item data
        for(Case req : MaintenanceRequests){
            for(Product2 eq : listEquipments){
                Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c(
                    Maintenance_Request__c = req.Id,
                    Equipment__c = eq.Id
                );
                equipmentMaintenanceItems.add(emi);
            }
        }
        insert equipmentMaintenanceItems;
        
        System.debug(oldRequestMap.size());
        List<Case> updatedCases = new List<Case>();
        for (Case c : oldRequestMap.values()) {
            c.Status = 'Closed'; 
            updatedCases.add(c);
        }
        update updatedCases;
        Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(updatedCases, oldRequestMap);
        Test.stopTest();
        List<Case> routineMaintenanceRequests = [SELECT Id FROM Case WHERE Subject like 'Routine Checkup%'];
        System.assertEquals(0, routineMaintenanceRequests.size());
    }
    
    /**
     * Bulk Test: Ensure that new cases are created for all closed cases.
     */
    @isTest
    static void testProcessClosedRequests_Bulk() {
        CreateDateforBulkTest();
        setupOldRequestMap();
        System.debug(oldRequestMap.size());
        List<Case> updatedCases = new List<Case>();
        for (Case c : oldRequestMap.values()) {
            c.Status = 'Closed'; 
            updatedCases.add(c);
        }
        update updatedCases;

        Test.startTest();
        MaintenanceRequestHelper.processClosedRequests(updatedCases, oldRequestMap);
        Test.stopTest();
        System.debug([SELECT count(id) FROM Case]);
        List<Case> newRequests = [SELECT Id FROM Case WHERE Subject like 'Routine Checkup%'];
        System.assertEquals(oldRequestMap.size(), newRequests.size(), 'Routine Maintenance should be created for all closed cases');
    }
}