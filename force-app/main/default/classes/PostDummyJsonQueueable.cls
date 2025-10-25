public class PostDummyJSONQueueable implements Queueable, Database.AllowsCallouts {
    private List<Id> contactIds;

    public PostDummyJSONUserQueueable(List<Id> ids) {
        this.contactIds = ids;
    }

    public void execute(QueueableContext context) {
        List<Contact> contactsToUpdate = new List<Contact>();
        Http http = new Http();

        for (Id contId : this.contactIds) {
            try {
                HttpRequest request = new HttpRequest();
                request.setEndpoint('callout:DummyJsonUser/users/add');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                
                String payload = DummyJSONCallout.generateDummyJsonUserPayload(contId);
                request.setBody(payload);

                HttpResponse response = http.send(request);

                if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                    contactsToUpdate.add(new Contact(Id = contId, DummyJSON_Last_Updated__c = Datetime.now()));
                } else {
                    System.debug(LoggingLevel.ERROR, 'POST callout failed for Contact ID ' + contId + '. Status code: ' + response.getStatusCode() + ', Body: ' + response.getBody());
                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Exception during POST callout for Contact ID ' + contId + ': ' + e.getMessage());
            }
        }

        if (!contactsToUpdate.isEmpty()) {
            try {
                update contactsToUpdate;
            } catch (DmlException e) {
                System.debug(LoggingLevel.ERROR, 'Error updating Contact records: ' + e.getMessage());
            }
        }
    }
}
