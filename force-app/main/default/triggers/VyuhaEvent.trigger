// primary listener for Vyuha event changes

trigger VyuhaEvent on Vyuha_Event__e ( after insert ) {

    // create Signals for each Event
    for ( Vyuha_Event__e event : trigger.new ) {
        vy_Signal signal = (vy_Signal) JSON.deserialize( event.Data__c, vy_Signal.class );
        signal.initialize ();
        if ( signal.isValid () == true ) {
            // execute the signal
        } else {
            // handle error
        }
    }
    
}