public class UpdateEquipmentData{
    @future(callout=true)
    public static void getDataFromEquipmentWarehouse(String WAREHOUSE_URL ){
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(WAREHOUSE_URL);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            HttpResponse res = http.send(req);
            
            if (res.getStatusCode() == 200) {
                System.debug('Response Body: ' + res.getBody());
                String fixedJson = res.getBody().replace('"_id":', '"ExternalID":');
                List<EquipmentWrapper> equipmentList = (List<EquipmentWrapper>) JSON.deserialize(fixedJson, List<EquipmentWrapper>.class);
                System.debug(equipmentList);
            } else {
                System.debug('Error: Received status code ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }

    private static void upsertEquipment(List<EquipmentWrapper> equipmentList) {
        List<Product2> productsToUpsert = new List<Product2>();
        
        for (EquipmentWrapper equipment : equipmentList) {
            Product2 product = new Product2();
            product.Warehouse_SKU__c = equipment.ExternalID;
            product.Replacement_Part__c= true;
            product.Cost__c = equipment.cost;
            product.Current_Inventory__c= equipment.quantity;
            product.Name= equipment.name;
            product.Lifespan_Months__c= equipment.lifespan;
            product.Maintenance_Cycle__c= equipment.maintenancePeriod;
            product.StockKeepingUnit= equipment.sku;
            productsToUpsert.add(product);
        }
        
        try {
            upsert productsToUpsert Warehouse_SKU__c;
            System.debug('Upsert successful.');
        } catch (DmlException e) {
            System.debug('DmlException: ' + e.getMessage());
        }
    }

   
}