<<<<<<< HEAD
//is this okay???

=======
>>>>>>> 564414b22ecbf89208a703bbee08d299a1774579
public with sharing class ContactTriggerHelper {

    public static void checkIds(List<Contact> contacts) {
        List<String> dummyJsonIds = new List<String>();
        for (Contact cont : contacts) {
            if (cont.DummyJSON_Id__c == null) {
                cont.DummyJSON_Id__c = String.valueOf(Integer.valueOf((math.random() * 100)));
            }
            if (Integer.valueOf(cont.DummyJSON_Id__c) <= 100) {
                dummyJsonIds.add(cont.DummyJSON_Id__c);
            }
        }
        if (!dummyJsonIds.isEmpty()) {
            DummyJSONCallout.getDummyJSONAsync(dummyJsonIds);
        }
    }


    public static void syncUpdate(List<Contact> contacts ) {
        List<Id> contactIds = new List<Id>();
        for (Contact cont : contacts) {
            if (Integer.valueOf(cont.DummyJSON_Id__c) > 100) {
                contactIds.add(cont.Id);
            }
        }
        if(!contactIds.isEmpty()) {
            DummyJSONCallout.postDummyJsonAsync(contactIds);
        }
    }
}