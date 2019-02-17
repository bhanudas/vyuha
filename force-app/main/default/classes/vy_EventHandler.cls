// Event Handler
// Interfaces with Signals and Processes 

public class vy_EventHandler {
    
    // primary processor for incoming Events

    public static void process ( List < Vyuha_Event__e > events ) {
        // create Signals for each Event
        for ( Vyuha_Event__e event : events ) {
            vy_Signal signal = (vy_Signal) JSON.deserialize( event.Data__c, vy_Signal.class );
            signal.initialize ();
            signal.process ();
        }
    }
}
