global with sharing class vy_CoordinatorFactory implements Schedulable {

    global vy_CoordinatorFactory ( ) {
        
    }

    // method to start off formations
    global void execute ( SchedulableContext sc ) {
        
        vy_Formation formation = vy_Coordinator.getNextFormation ( new vy_Formation ());
        formation.launch ();

    }

}
