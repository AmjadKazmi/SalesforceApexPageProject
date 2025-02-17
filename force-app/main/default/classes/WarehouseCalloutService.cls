public with sharing class WarehouseCalloutService implements Queueable {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    //calling method to callout the service and return json object ///

    public void execute(QueueableContext context) {
        UpdateEquipmentData.getDataFromEquipmentWarehouseAndUpdateInProduct(WAREHOUSE_URL);
    }
   
}