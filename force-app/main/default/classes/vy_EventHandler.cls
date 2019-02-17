// Event Handler
// Interfaces with Signals and Processes 

public class vy_EventHandler implements vy_ExceptionParent {
    
    // primary processor for incoming Events

    public static void process ( List < Vyuha_Event__e > events ) {
        // create Signals for each Event
        for ( Vyuha_Event__e event : events ) {
            vy_Signal signal = (vy_Signal) JSON.deserialize( event.Data__c, vy_Signal.class );
            signal.initialize ();
            signal.process ();
        }
    }

    public static void create ( vy_Signal signal ) {
        String jsonStr = JSON.serialize( signal );
        Vyuha_Event__e event = new Vyuha_Event__e ();
        event.data__c = jsonStr;
        event.Apex_Job_ID__c = signal.apexJobId;
        event.Formation_ID__c = signal.formationId;
        event.Schedule_Item_ID__c = signal.scheduleItemId;
        event.Status__c = signal.status;
        Database.SaveResult sr = EventBus.publish ( event );
        if ( sr.isSuccess () == false ) {
            // handle exception
            throw new vy_Exception ( new vy_EventHandler (), 'create event failed' );
        }
    }

    public string className () {
        return 'vy_EventHandler';
    }
}
