global with sharing class vy_CoordinatorFactory implements Schedulable {

    vy_Coordinator coordinator;

    global vy_CoordinatorFactory ( ) {
        this.coordinator = new vy_Coordinator ();
    }

    // method to start off formations
    global void execute ( SchedulableContext sc ) {
        
        vy_Formation formation = coordinator.getNextFormation ( new vy_Formation ());
        formation.launch ();

    }

}
