// Interface to the Scheduled job - acts as the head for hourly VY processing

global with sharing class vy_Schedulable implements Schedulable {

    private vy_Formation formation;
    
    global vy_Schedulable ( vy_Formation formation ) {
        this.formation = formation;
    }

    global void execute ( SchedulableContext sc ) {
        vy_Processor processor = new vy_Processor ( this.formation, new vy_Coordinator ());
        ID apexJobId = Database.executeBatch ( processor, this.formation.getBatchSize ());
    }
}
