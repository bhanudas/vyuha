// Event
// Represents APEX interface to Vyuha Event Platform Event (Vyuha_Event__c)

public class vy_Event implements vy_ExceptionParent {

    private Id formationId;
    private Id scheduleItemId;
    private string eventType;
    private string status;
    private string data;
    private EventData dataObj;

    public vy_Event ( Vyuha_Event__e peEvent ) {
        // transform peEvent into vy_Event

    }

    public vy_Event () {

    }

    // take current event properties, creates a PE and inserts
    public void enqueue () {

    }

    // auraenabled version
    @auraEnabled
    public static void auraEnqueue () {

    }

    // used for JSON representation of data for events
    public class EventData {
        string message;
    }

    // exceptionparent
    public string className () {
        return 'vy_Event';
    }
}
