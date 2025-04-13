public with sharing class NewRequestService {
    
    private static final Integer QUERY_LIMIT = 200;  // Maximum number of records to return
    private static final String LIKE_WILDCARD = '%{0}%'; // Wildcard for LIKE operator
    
   /**
    * List of supported objects to search for in the lookup
    * This list should contain the API names of the objects that you want to allow for lookup searches.
    * For example: 'Contact', 'Account', 'Vehicle__c'
    * You can add or remove objects from this list as needed.
    * Make sure to include the API names of the objects you want to support in the lookup functionality.
    * Note: The API names are case-sensitive, so ensure that they match the actual API names of the objects in your Salesforce org.
    */
    private static final List<String> SUPPORTED_OBJECTS = new List<String>{
        'Contact', 'Account', 'Vehicle__c'
    };

    @AuraEnabled(cacheable=true)
    public static Map<String, List<SelectOption>> fetchLookupOptions() {
        Map<String, List<SelectOption>> result = new Map<String, List<SelectOption>>();

        for (String objectName : SUPPORTED_OBJECTS) {
            result.put(objectName.toLowerCase(), getSelectList(fetchSObjects(objectName, null)));
        }

        return result;
    }

    /**
     * Searches for records in the specified object based on the search key.
     * @param objectLabel The API name of the object to search in (e.g., 'Contact', 'Account', 'Vehicle__c').
     * @param searchKey The search key to filter the records by.
     * @return A list of SelectOption objects containing the Id and Name of the matching records.
     */
    @AuraEnabled(cacheable=true)
    public static List<SelectOption> searchByObjectLabel(String objectLabel, String searchKey) {
        if (!SUPPORTED_OBJECTS.contains(objectLabel)) {
            throw new AuraHandledException('Unsupported object label: ' + objectLabel);
        }
        return searchGeneric(objectLabel, searchKey);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts() {
        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE Replacement_Part__c = True ORDER BY Name];
        return products;
    }
     

    /**
     * Searches for records in the specified object based on the search key.
     * @param objectName The API name of the object to search in (e.g., 'Contact', 'Account', 'Vehicle__c').
     * @param searchKey The search key to filter the records by.
     * @return A list of SelectOption objects containing the Id and Name of the matching records.
     */
    private static List<SelectOption> searchGeneric(String objectName, String searchKey) {
        return getSelectList(fetchSObjects(objectName, searchKey));
    }
    /**
     * Fetches SObjects based on the provided object name and search key.
     * @param objectName The API name of the object to fetch records from (e.g., 'Contact', 'Account', 'Vehicle__c').
     * @param searchKey The search key to filter the records by.
     * @return A list of SObjects matching the search criteria.
     */
    private static List<SObject> fetchSObjects(String objectName, String searchKey) {
        String soql;

        if (String.isNotBlank(searchKey)) {
            String key = '%' + searchKey + '%';
            soql = 'SELECT Id, Name FROM ' + objectName + ' WHERE Name LIKE :key ORDER BY Name LIMIT ' + QUERY_LIMIT;
            return Database.query(soql);
        } else {
            soql = 'SELECT Id, Name FROM ' + objectName + ' ORDER BY Name LIMIT ' + QUERY_LIMIT;
            return Database.query(soql);
        }
    }
    
    /**
     * Converts a list of SObjects to a list of SelectOption objects.
     * @param records The list of SObjects to convert.
     * @return A list of SelectOption objects containing the Id and Name of the SObjects.
     */
    private static List<SelectOption> getSelectList(List<SObject> records) {
        List<SelectOption> options = new List<SelectOption>();
        for (SObject rec : records) {
            options.add(new SelectOption((String)rec.get('Id'), (String)rec.get('Name')));
        }
        return options;
    }
     




    /**
     * Represents a selectable option in the lookup component. 
     * This class is used to create a list of options for the lookup component.
     */
    public class SelectOption {
        @AuraEnabled public String label;
        @AuraEnabled public String value;

        public SelectOption(String id, String name) {
            this.label = name;
            this.value = id;
        }
    }
}
