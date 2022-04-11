global with sharing class vy_Processor implements Database.Batchable < sobject >, Database.Stateful {

    global enum JobStatus { SCHEDULED, INITIALIZED, QUERY, PROCESSING, COMPLETED, ERROR }

    private vy_Formation formation;
    private vy_Coordinator coordinator;
    private JobStatus status;
    private ID apexJobId;

    global vy_Processor ( vy_Formation formation, vy_Coordinator coordinator ) {
        // set control variables
        this.status = JobStatus.INITIALIZED;
        // initialize
        this.formation = formation;
        this.coordinator = coordinator;
        vy_Coordinator.debugOutput ( 'vy_Processor::constructor', '', this );
    }

    global Database.QueryLocator start ( Database.BatchableContext batchContext ) {
        // set control variables
        this.status = JobStatus.QUERY;
        this.apexJobId = batchContext.getJobId ();
        coordinator.writeLogEntry ( this, this.formation );
        if ( this.formation.isValid () == false ) {
            this.formation.addError ( 'Start', 'Warning, Formation is marked as invalid' );
        }
        try {
            // run query
            String soql = this.formation.getSoqlStatement ();
            vy_Coordinator.debugOutput ( 'vy_Processor::start', 'soql query', soql );
            return Database.getQueryLocator ( soql );
        } catch ( Exception e ) {
            this.formation.addError ( 'Start', e.getMessage ());
            return null;
        }
	}

	global void execute ( Database.BatchableContext batchContext, List < sObject > listToProcess ) {
        // set control variables
        this.status = JobStatus.PROCESSING;
        coordinator.writeLogEntry ( this, this.formation );

        // execute
        vy_Coordinator.debugOutput ( 'vy_Processor::execute', 'start', this );
        Boolean executeResult = this.formation.executeFlow ( listToProcess );
        if ( executeResult == false ) {
            // terminate
            this.status = JobStatus.ERROR;
            vy_Coordinator.debugOutput ( 'vy_Processor::execute', 'TERMINATED', this );
        } else {
            // success
            vy_Coordinator.debugOutput ( 'vy_Processor::execute', 'Iteration Complete', this );
        }
        coordinator.writeLogEntry ( this, this.formation );
	}

	global void finish ( Database.BatchableContext batchContext ) {

        // set status
        if ( this.status == JobStatus.ERROR ) {
            // an error has occurred
            // handle error notifications
            this.formation.addError ( 'Finish', 'Error Detected during processing');
        } else {
            this.status = JobStatus.COMPLETED;
        }
        
        coordinator.writeLogEntry ( this, this.formation );
        this.formation.complete ();
        vy_Coordinator.debugOutput ( 'vy_Processor::finish', '', this );

        // fetch and run next Formation - only run if not on demand
        if ( this.formation.isOnDemand == false ) {
            vy_Formation nextFormation = vy_Coordinator.getNextFormation ( this.formation );
            nextFormation.launch ();
        }
        
	}

    global JobStatus getStatus () {
        return this.status;
    }

    global ID getApexJobId () {
        return this.apexJobId;
    }

}

