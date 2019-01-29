// primary listener for Vyuha event changes

trigger VyuhaEvent on Vyuha_Event__e ( after insert ) {

    // spawn the dispatcher
    System.enqueueJob( new vy_Dispatcher ( trigger.new ));
    
}