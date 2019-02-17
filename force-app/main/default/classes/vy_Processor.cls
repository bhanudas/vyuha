// Processor
// Primary class that is Batchable, called from a ProcessorItem to run the batch

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
        vy_Signal.debugOutput ( 'vy_Processor::constructor', '', this );
    }

    public Database.QueryLocator start ( Database.BatchableContext batchContext ) {
        // set control variables
        this.status = JobStatus.QUERY;
        this.apexJobId = batchContext.getJobId ();
        vy_Signal.create ( this, vy_Signal.Vyuha_Status.STARTING, '' );
        if ( this.processorItem.isValid () == false ) {
            vy_Signal.create ( this, vy_Signal.Vyuha_Status.ERROR, 'Warning, Formation is marked as invalid' );
        }
        try {
            // run query
            String soql = this.processorItem.getSoqlStatement ();
            vy_Signal.debugOutput ( 'vy_Processor::start', 'soql query', soql );
            return Database.getQueryLocator( soql );
        } catch ( Exception e ) {
            vy_Signal.create ( this, vy_Signal.Vyuha_Status.ERROR, e.getMessage () );
            return null;
        }
	}

	public void execute ( Database.BatchableContext batchContext, List < sObject > listToProcess ) {
        // set control variables
        this.status = JobStatus.PROCESSING;
        vy_Signal.create ( this, vy_Signal.Vyuha_Status.ITERATION, '' );

        // execute
        vy_Signal.debugOutput ( 'vy_Processor::execute', 'start', this );
        try {
            this.processorItem.execute ( listToProcess );
            vy_Signal.debugOutput ( 'vy_Processor::execute', 'Iteration Complete', this );
        } catch ( Exception e ) {
            // handle
            this.status = JobStatus.ERROR;
            vy_Signal.debugOutput ( 'vy_Processor::execute', 'TERMINATED', this );
        }
        
	}

	public void finish ( Database.BatchableContext batchContext ) {

        // set status
        if ( this.status == JobStatus.ERROR ) {
            // an error has occurred
            // handle error notifications
            vy_Signal.create ( this, vy_Signal.Vyuha_Status.ERROR, 'Job completed with errors' );
        } else {
            this.status = JobStatus.COMPLETED;
        }
        
        vy_Signal.create ( this, vy_Signal.Vyuha_Status.COMPLETE, '' );
        this.processorItem.complete ();
        vy_Signal.debugOutput ( 'vy_Processor::finish', '', this );

	}

    public JobStatus getStatus () {
        return this.status;
    }

    public ID getApexJobId () {
        return this.apexJobId;
    }
    public vy_ProcessorItem getProcessorItem () {
        return this.processorItem;
    }

}

