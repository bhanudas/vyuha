// primary listener for Vyuha event changes

trigger VyuhaEvent on Vyuha_Event__e ( after insert ) {

    vy_EventHandler.process ( trigger.new );
    
}