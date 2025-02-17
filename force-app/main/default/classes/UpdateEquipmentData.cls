public class UpdateEquipmentData{
    /**
     * This method is used to get the data from the equipment warehouse and update the product object. 
     * Using Warehouse SKUs as the external ID to upsert the product object.
     * @param WAREHOUSE_URL - The URL of the equipment warehouse.
     * @author Amjad Ali
     * @Date 2025/02/18
     */
    @future(callout=true)
    public static void getDataFromEquipmentWarehouseAndUpdateInProduct(String WAREHOUSE_URL ){
        try {
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(WAREHOUSE_URL);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
            HttpResponse res = http.send(req);
            System.debug(res.getStatusCode());
            if (res.getStatusCode() == 200) {
                System.debug('Response Body: ' + res.getBody());
                String fixedJson = res.getBody().replace('"_id":', '"ExternalID":');
                List<EquipmentWrapper> equipmentList = (List<EquipmentWrapper>) JSON.deserialize(fixedJson, List<EquipmentWrapper>.class);
                System.debug(equipmentList);
                upsertEquipment(equipmentList);
            } else {
                System.debug('Error: Received status code ' + res.getStatusCode());
            }
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
    }
    
    /**
     * This method is used to upsert the equipment data in the product object.
     * @param equipmentList - The list of equipment data to be upserted.
     * @author Amjad Ali
     * @Date 2025/02/18
     */
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