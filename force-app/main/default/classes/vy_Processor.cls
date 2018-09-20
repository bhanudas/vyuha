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
        System.debug ( 'vy_Processor - constructor ' + this);
    }

    global Database.QueryLocator start ( Database.BatchableContext batchContext ) {
        // set control variables
        this.status = JobStatus.QUERY;
        this.apexJobId = batchContext.getJobId ();
        coordinator.writeLogEntry ( this );

        // run query
        String soql = this.formation.getSoqlStatement ();
        System.debug ( 'vy_Processor - start () ' + soql );
		return Database.getQueryLocator ( soql );
        
	}

	global void execute ( Database.BatchableContext batchContext, List < sObject > listToProcess ) {
        // set control variables
        this.status = JobStatus.PROCESSING;
        coordinator.writeLogEntry ( this );

        // execute
        System.debug ( 'vy_Processor - execute () ');
        Boolean executeResult = this.formation.executeFlow ( listToProcess );
        if ( executeResult == false ) {
            // terminate
            this.status = JobStatus.ERROR;
            System.debug ( 'vy_Processor - execute () - TERMINATED');
        } else {
            // success
            System.debug ( 'vy_Processor - execute () - Iteration complete');
        }
        coordinator.writeLogEntry ( this );
	}

	global void finish ( Database.BatchableContext batchContext ) {

        // set status
        if ( this.status == JobStatus.ERROR ) {
            // an error has occurred
            // handle error notifications
        } else {
            this.status = JobStatus.COMPLETED;
        }
        
        coordinator.writeLogEntry ( this );
        System.debug ( 'vy_Processor - finish () ');
        
	}

    global JobStatus getStatus () {
        return this.status;
    }

    global ID getApexJobId () {
        return this.apexJobId;
    }

}

