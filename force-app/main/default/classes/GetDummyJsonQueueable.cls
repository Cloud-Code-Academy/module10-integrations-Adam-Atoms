public class GetDummyJSONQueueable implements Queueable, Database.AllowsCallouts {
    private List<String> dummyJsonIds;

    public GetDummyJSONUserQueueable(List<String> jsonIds) {
        this.dummyJsonIds = jsonIds;
    }

    public void execute(QueueableContext context) {
        List<Contact> contactsToUpdate = new List<Contact>();
        Http http = new Http();

        for (String dummyUserId : this.dummyJsonIds) {
            try {
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:DummyJsonUser/users/' + dummyUserId);
                request.setMethod('GET');
                HttpResponse response = http.send(request);

                if (response.getStatusCode() == 200) {
                    Contact cont = DummyJSONCallout.createContactFromJson(response.getBody());
                    if (cont != null) {
                        contactsToUpdate.add(cont);
                    }
                } else {
                    System.debug(LoggingLevel.ERROR, 'GET callout failed for ID ' + dummyUserId + '. Status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Exception during GET callout for ID ' + dummyUserId + ': ' + e.getMessage());
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            try {
                upsert contactsToUpdate DummyJSON_Id__c;
            } catch (DmlException e) {
                System.debug(LoggingLevel.ERROR, 'Error upserting contacts: ' + e.getMessage());
            }
        }
    }
}
