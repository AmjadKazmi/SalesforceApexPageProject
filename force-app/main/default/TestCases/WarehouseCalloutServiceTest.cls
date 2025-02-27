@IsTest
private class WarehouseCalloutServiceTest {
    /*
    * Test class to test the WarehouseCalloutService class, where we are testing the getEquipment method
    * to check if the equipment is fetched from the warehouse and inserted in the Product2 object.
    */
    @isTest static void testGetEquipment(){
        WarehouseCalloutServiceMock.responseBody= '[{"_id": "55d66226726b611100aaf341",'
            + '"replacement": false,'
            + '"quantity": 5,'
            + '"name": "Generator 1000 kW",'
            + '"maintenanceperiod": 365,'
            + '"lifespan": 120,'
            + '"cost": 5000,'
            + '"sku": "3456"}]';
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        UpdateEquipmentData.getDataFromEquipmentWarehouseAndUpdateInProduct('test');
        Test.stopTest();
        List<Product2> equipmentList = [SELECT Name FROM Product2 WHERE Name = 'Generator 1000 kW'];
        System.assertEquals(1, equipmentList.size());
        System.assertEquals('Generator 1000 kW', equipmentList[0].Name);
    }
    

    /**
     * Test class to test the WarehouseCalloutService class, where we are testing the getEquipment method
     * to check errro handling when the equipment is not fetched from the warehouse.
     */
    @isTest static void testGetEquimentError(){
        String errorResponse = '{"error": "Error occurred while fetching data from the warehouse."}';
        WarehouseCalloutServiceMock.responseBody = errorResponse;
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        UpdateEquipmentData.getDataFromEquipmentWarehouseAndUpdateInProduct('test');
        Test.stopTest();
        List<Product2> equipmentList = [SELECT Name FROM Product2 WHERE Name = 'Generator 1000 kW'];
        System.assertEquals(0, equipmentList.size());
    }

    @isTest static void testGetEquimentUpsertException(){
     WarehouseCalloutServiceMock.responseBody = '[{"_id": "55d66226726b611100aaf741",'
    + '"replacement": false,'
    + '"quantity": 5,'
    + '"name": "Generator 1000 kW",'
    + '"maintenanceperiod": 365,'
    + '"lifespan": 120,'
    + '"cost": 5000,'
    + '"sku": "100003"}]';
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        UpdateEquipmentData.getDataFromEquipmentWarehouseAndUpdateInProduct('test');
        Test.stopTest();
        List<Product2> equipmentList = [SELECT Name FROM Product2 WHERE Name = 'Generator 1000 kW'];
        System.assertEquals(0, equipmentList.size());
    }
     
    /**
     * Test class to test the WarehouseCalloutService class, where we are testing the Queueable method
     * to check if the Queueable job is enqueued.
     */
    @isTest
    static void testWarehouseCalloutServiceQueueable() {
      Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
      Test.startTest();
      Id jobId = System.enqueueJob(new WarehouseCalloutService());
      Test.stopTest();
      System.assertNotEquals(null, jobId, 'Queueable job should be enqueued');
    }
}