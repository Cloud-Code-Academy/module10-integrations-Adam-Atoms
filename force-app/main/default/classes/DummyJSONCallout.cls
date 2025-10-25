/*
 * DummyJSONCallout Class Description:
 * 
 * This class, DummyJSONCallout, facilitates HTTP callouts to an external system (presumably 'DummyJsonUser' in this context) 
 * to either fetch or send user information based on a given identifier. The class supports both GET (to fetch data) 
 * and POST (to send data) operations.
 * 
 * Overview of HTTP Callouts:
 * 
 * HTTP callouts are a way for Salesforce to communicate with external systems using HTTP protocols. Through HTTP callouts, 
 * you can invoke external web services, collect data from them, or send data for further processing. Apex provides 
 * classes that enable you to both send and receive HTTP data. The primary classes for this are `HttpRequest`, which 
 * represents the request you're sending, and `HttpResponse`, which represents the response you receive.
 * 
 * Best Practices:
 * 1. Handle Exceptions: Always handle exceptions that might be thrown, to ensure your code doesn't break unexpectedly.
 * 2. Named Credentials: Use Named Credentials to store endpoint URLs and authentication details securely.
 * 3. Test Callouts: Use mock classes and interfaces to test HTTP callouts without making actual callouts.
 * 
 * For more detailed information on HTTP callouts in Apex, refer to the official Salesforce documentation: 
 * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm
 */

public with sharing class DummyJSONCallout {

    /*
     * Question 1
     * Fetches user information from an external system via GET.
     * Replaces the @future getDummyJSONAsync method with a Queueable job.
     *
     * @param jsonIds A list of DummyJSON_Id__c external IDs to fetch.
     */
    public static void enqueueGetDummyJSONAsync(List<String> jsonIds) {
        if (!jsonIds.isEmpty()) {
            System.enqueueJob(new GetDummyJSONUserQueueable(jsonIds));
        }
    }

    /*
     * Question 3
     * Sends Contact information to an external system via POST.
     * Replaces the @future postDummyJsonAsync method with a Queueable job.
     *
     * @param contactIds The list of Salesforce Contact IDs to send.
     */
    public static void enqueuePostDummyJsonAsync(List<Id> contactIds) {
        if (!contactIds.isEmpty()) {
            System.enqueueJob(new PostDummyJSONUserQueueable(contactIds));
        }
    }

    /*
     * Question 2
     * Transforms a JSON response into a Salesforce Contact object.
     * (No change, helper method)
     *
     * @param jsonResponse The JSON string from the external system.
     * @return The Salesforce Contact object.
     */
    @TestVisible
    private static Contact createContactFromJson(String jsonResponse) {
        if (String.isBlank(jsonResponse)) {
            return null;
        }
        
        try {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            if (responseMap == null || responseMap.isEmpty()) {
                return null;
            }
            
            Contact cont = new Contact();
            cont.DummyJSON_Id__c = String.valueOf((Object) responseMap.get('id'));
            cont.FirstName = (String) responseMap.get('firstName');
            cont.LastName = (String) responseMap.get('lastName');
            cont.Email = (String) responseMap.get('email');
            cont.Phone = (String) responseMap.get('phone');
            
            String birthDateStr = (String) responseMap.get('birthDate');
            if (birthDateStr != null) {
                cont.Birthdate = Date.valueOf(birthDateStr);
            }
            
            Map<String, Object> addressMap = (Map<String, Object>) responseMap.get('address');
            if (addressMap != null) {
                cont.MailingStreet = (String) addressMap.get('address');
                cont.MailingCity = (String) addressMap.get('city');
                cont.MailingPostalCode = (String) addressMap.get('postalCode');
                cont.MailingState = (String) addressMap.get('state');
                cont.MailingCountry = (String) addressMap.get('country');
            }
            return cont;

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error deserializing JSON or creating contact: ' + e.getMessage());
            return null;
        }
    }

    /*
     * Question 4
     * Generates a JSON payload from a Salesforce Contact record.
     * (No change, helper method)
     *
     * @param contactId The Salesforce Contact ID.
     * @return The JSON payload string.
     */
    @TestVisible
    private static String generateDummyJsonUserPayload(String contactId) {
        Contact cont = [
            SELECT Id, FirstName, LastName, Email, Phone
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];

        Map<String, Object> payloadMap = new Map<String, Object>();
        payloadMap.put('id', cont.Id);
        payloadMap.put('firstName', cont.FirstName);
        payloadMap.put('lastName', cont.LastName);
        payloadMap.put('email', cont.Email);
        payloadMap.put('phone', cont.Phone);

        return JSON.serialize(payloadMap);
    }
}