public class vy_Processor implements Database.Batchable < sobject >, Database.Stateful {

    public enum JobStatus { SCHEDULED, INITIALIZED, QUERY, PROCESSING, COMPLETED, ERROR }

    private vy_ProcessorItem processorItem;
    private JobStatus status;
    private ID apexJobId;

    public vy_Processor ( vy_processorItem processorItem ) {
        // set control variables
        this.status = JobStatus.INITIALIZED;
        // initialize
        this.processorItem = processorItem;
        vy_Coordinator.debugOutput ( 'vy_Processor::constructor', '', this );
    }

    public Database.QueryLocator start ( Database.BatchableContext batchContext ) {
        // set control variables
        this.status = JobStatus.QUERY;
        this.apexJobId = batchContext.getJobId ();
        this.processorItem.writeLog ( this );
        if ( this.processorItem.isValid () == false ) {
            this.processorItem.errorLog ( 'Start', 'Warning, Formation is marked as invalid' );
        }
        try {
            // run query
            String soql = this.processorItem.getSoqlStatement ();
            vy_Coordinator.debugOutput ( 'vy_Processor::start', 'soql query', soql );
            return Database.getQueryLocator( soql );
        } catch ( Exception e ) {
            this.processorItem.errorLog ( 'Start', e.getMessage ());
            return null;
        }
	}

	public void execute ( Database.BatchableContext batchContext, List < sObject > listToProcess ) {
        // set control variables
        this.status = JobStatus.PROCESSING;
        this.processorItem.writeLog ( this );

        // execute
        vy_Coordinator.debugOutput ( 'vy_Processor::execute', 'start', this );
        try {
            this.processorItem.execute ( listToProcess );
            vy_Coordinator.debugOutput ( 'vy_Processor::execute', 'Iteration Complete', this );
        } catch ( Exception e ) {
            // handle
            this.status = JobStatus.ERROR;
            vy_Coordinator.debugOutput ( 'vy_Processor::execute', 'TERMINATED', this );
        }
        
        this.processorItem.writeLog ( this );
	}

	public void finish ( Database.BatchableContext batchContext ) {

        // set status
        if ( this.status == JobStatus.ERROR ) {
            // an error has occurred
            // handle error notifications
            this.processorItem.errorLog ( 'Finish', 'Error Detected during processing');
        } else {
            this.status = JobStatus.COMPLETED;
        }
        
        this.processorItem.writeLog ( this );
        this.processorItem.complete ();
        vy_Coordinator.debugOutput ( 'vy_Processor::finish', '', this );

	}

    public JobStatus getStatus () {
        return this.status;
    }

    public ID getApexJobId () {
        return this.apexJobId;
    }

}

