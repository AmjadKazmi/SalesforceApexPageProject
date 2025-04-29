public with sharing class InsertRecords {
    
    @AuraEnabled
    public static Case InsertCaseRecord(String caseDataJson) {

        if (String.isBlank(caseDataJson)) {
            throw new IllegalArgumentException('caseDataJson cannot be blank');
        }

        // Parse JSON into Map
        Map<String, Object> caseData = (Map<String, Object>) JSON.deserializeUntyped(caseDataJson);
        
        System.debug('Parsed caseData Map: ' + caseData);

        if (caseData == null || caseData.isEmpty()) {
            throw new IllegalArgumentException('caseData cannot be empty');
        }
        
   
        List<Map<String, Object>> PRODUCTS_ID_NAME = new List<Map<String, Object>>();
        Integer shortestCycle = 2147483647;
        if (caseData?.containsKey('fields') && ((List<Object>)caseData.get('fields')).size() > 0) {
            System.debug('inside the if condition');
            System.debug('caseData.get(fields): ' + caseData.get('fields'));
            try {
            for (Object productDetails : (List<Object>)caseData.get('fields')) {
                if (productDetails instanceof Map<String, Object>) {
                PRODUCTS_ID_NAME.add((Map<String, Object>)productDetails);
                }
            }
            for (Map<String, Object> productIDName : PRODUCTS_ID_NAME) {
                System.debug('ID: ' + productIDName.get('id') + 
                     ', PRODUCTID: ' + productIDName.get('productID') + 
                     ', PRODUCTDESCRIPTION: ' + productIDName.get('productDescription'));
                // Optional: Process each field here
            }
            } catch (Exception e) {
            System.debug('Error processing fields: ' + e.getMessage());
            }
                for (Map<String, Object> productIDName : PRODUCTS_ID_NAME) {
                    if (productIDName.get('productID') != null) {
                        Integer maintenanceCycleValue = Integer.valueOf([SELECT Maintenance_Cycle__c FROM Product2 WHERE 
                        Id = :String.valueOf(productIDName.get('productID'))].Maintenance_Cycle__c.toString());
                        maintenanceCycleValue =  maintenanceCycleValue!=0 ? maintenanceCycleValue : 365;
                        shortestCycle = Math.min(shortestCycle, maintenanceCycleValue);
                    }
                }
                    System.debug('Short Cycle'+shortestCycle);
        }else{
            shortestCycle = 365;
        }


             /** Creating Maintenance Request */
        Case caseRecord = new Case();
        caseRecord.Subject = (String) caseData.get('Subject');
        caseRecord.Status = (String) caseData.get('Status');
        caseRecord.Priority = (String) caseData.get('Priority');
        caseRecord.Origin = (String) caseData.get('CaseOrigin');
        caseRecord.Reason = (String) caseData.get('Reason');
        caseRecord.Type = (String) caseData.get('Type');
        caseRecord.AccountId = (String) caseData.get('Account');
        caseRecord.ContactId = (String) caseData.get('Contact');
        caseRecord.Vehicle__c = (String) caseData.get('Vehicle');
        caseRecord.Date_Reported__c = Date.today();
        caseRecord.Date_Due__c = Date.today().addDays(shortestCycle);


        insert caseRecord;

        List<Equipment_Maintenance_Item__c> lookupToMapCaseAndProductList = new List<Equipment_Maintenance_Item__c>();

        for (Map<String, Object> productIDName : PRODUCTS_ID_NAME) {
            if (productIDName.get('productID') != null) {
                Equipment_Maintenance_Item__c emi = new Equipment_Maintenance_Item__c();
                emi.Maintenance_Request__c = caseRecord.Id;
                emi.Equipment__c = (String) productIDName.get('productID');
                lookupToMapCaseAndProductList.add(emi);
            }
        }

        insert lookupToMapCaseAndProductList;
        System.debug('Inserted Equipment_Maintenance_Item__c records: ' + lookupToMapCaseAndProductList);


        
        caseRecord = [SELECT Id, CaseNumber FROM Case WHERE Id = :caseRecord.Id LIMIT 1];

        return caseRecord;
    }

}