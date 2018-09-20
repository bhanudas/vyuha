global with sharing class vy_CoordinatorFactory implements Schedulable {

    vy_Formation formation;

    global vy_CoordinatorFactory ( ) {
        this.formation = new vy_Formation ();
    }

    // injeected Formation for Test use
    global vy_CoordinatorFactory ( vy_Formation formation ) {
        this.formation = formation;
    }

    // method to start off formations
    global void execute ( SchedulableContext sc ) {
        
        vy_Coordinator coordinator = new vy_Coordinator ();

        // create a list of all available formation Job Names

        Set < string > formationNames = new Set < string > ();
        for ( vy_Formation formation : this.formation.getActiveFormations () ) {
            formationNames.addAll ( formation.getJobNames ());
            
        }

        // check to see if we have Jobs scheduled for these names
        List < CronTrigger > jobs = [ SELECT Id, CronJobDetail.Id, CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.JobType = '7' ];

        for ( CronTrigger job : jobs ) {
            if 
        }


        // schedule missing jobs
        coordinator.scheduleFormation ( formation );

    }

}
