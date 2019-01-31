// vy_ScheduleItem
// Interface to Scheduled Item

public class vy_ScheduleItem implements vy_ProcessorItem, vy_ExceptionParent {

    private vy_Formation    formation;
    private vy_Coordinator  coordinator;

    private boolean         isActive;
    private Datetime        oneTimeDateTime;
    private Datetime        lastSuccessfulRun;
    private Datetime        lastErrorEncountered;
    private string          frequency;
    private Id              id;
    private String          status;
    private String          formationStatus;
    private Boolean         isRunnable;
    
    public vy_ScheduleItem ( vy_Formation formation, vy_Coordinator coordinator ) {
        this.formation      = formation;
        this.coordinator    = coordinator;
    }

    public vy_ScheduleItem ( Vyuha_Schedule_Item__c siRecord, Datetime executionDateTime ) {
        // turn the record into a actual si object
        this.isActive               = (boolean)     siRecord.get ( 'Active__c'                  );
        this.oneTimeDateTime        = (Datetime)    siRecord.get ( 'One_Time_DateTime__c'       );
        this.lastSuccessfulRun      = (Datetime)    siRecord.get ( 'Last_Successful_Run__c'     );
        this.lastErrorEncountered   = (Datetime)    siRecord.get ( 'Last_Error_Encountered__c'  );
        this.frequency              = (string)      siRecord.get ( 'Frequency__c'               );
        this.id                     = (Id)          siRecord.get ( 'Id'                         );
        this.status                 = (string)      siRecord.get ( 'Status__c'                  );
        this.formationStatus        = (string)      siRecord.get ( 'Formation_Status__c'        );

        this.coordinator = new vy_Coordinator ();
        this.formation = new vy_Formation ();

        if ( executionDateTime != null ) {
            // have a executionDateTime to calculate issRunnable
            this.isRunnable = this.calculateRunnable ( executionDateTime );
        } else {
            this.isRunnable = null;
        }
    }

    public void load ( Id recordId ) {

        // query for schedule item
        vyuha_Schedule_Item__c scheduleItem;

        try {
            scheduleItem = [ SELECT ID, Vyuha_Formation__c FROM vyuha_Schedule_Item__c WHERE ID =: recordId ];
            this.formation.load ( scheduleItem.Vyuha_Formation__c );
        } catch ( Exception e ) {
            throw new vy_Exception ( this, e );
        }
    }

    public boolean isValid () {
        return this.formation.isValid ();
    }

    // note: when checking isRunnable, records are not immediately fetched, so make sure
    // to run in the same transaction as a Load or Constructed via record
    public boolean isRunnable () {
        return this.isRunnable;
    }

    private boolean calculateRunnable ( Datetime executionDatetime ) {
        vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'executeDatetime', executionDatetime );
        vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'object values', this );
        // check for active
        if ( this.isActive == false ) {
            vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'Caught isActive = false', false );
            return false;
        }

        // check for running
        if ( this.isRunning () == true ) {
            vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'Caught isRunning = true', false );
            return false;
        }

        // check for onetime runnable
        if ( this.frequency == 'One Time' ) {
            // check for date > execution date
            if ( this.oneTimeDateTime > executionDateTime ) {
                // scheduled to run in the future
                vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'one-time job scheduled to run in the future', false );
                return false;
            } else {
                 // date is in the past or now, check to make sure that it hasn't run
                if (( this.lastSuccessfulRun == null ) && ( this.lastErrorEncountered == null )) {
                    vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'one-time job found now or in the past, never run', true );
                    return true;
                } else {
                    vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'one-time job found now or in the past, already run once', false );
                    return false;
                }
            }
        } else if ( this.frequency == 'Recurring' ) {
            // check for running recurring
            vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'Recurring not implemented', false );
            return false;
        }

        // catch all
        vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'Catch all', false );
        throw new vy_Exception ((vy_ExceptionParent) this, 'calculateRunnable did not catch a condition' );
    
    }

    // note: when checking isRunning, records are not immediately fetched, so make sure
    // to run in the same transaction as a Load or Constructed via record

    public boolean isRunning () {
        if ( this.formationStatus == 'Running' ) {
            return true;
        } 
        return false;
    }

    public void start () {
        this.formation.start ( this );
    }

    public void complete () {
        this.formation.complete ();
    }

    public string getSoqlStatement () {
        return this.formation.getSoqlStatement ();
    }

    public void execute ( List < sObject > dataList ) {
        this.formation.execute ( dataList );
    }

    // logging

    public void writeLog ( vy_Processor processor ) {
        this.formation.writeLog ( processor );
    }

    public void errorLog ( string errorClass, string errorMessage ) {
        this.formation.errorLog ( errorClass, errorMessage );
    }

    // exception

    public string className () {
        return 'vy_ScheduleItem';
    }

    public static string baseSelectQuery () {
        string soql = '';
        List < string > fields = new List < string > ();
        fields.add ( 'ID' );
        fields.add ( 'Frequency__c' );
        fields.add ( 'Last_Successful_Run__c' );
        fields.add ( 'Last_Error_Encountered__c' );
        fields.add ( 'One_Time_Datetime__c' );
        fields.add ( 'Active__c' );
        fields.add ( 'Vyuha_Formation__c' );
        fields.add ( 'Status__c' );
        fields.add ( 'Formation_Status__c' );
        soql += 'SELECT ' + String.join ( fields, ',' );
        soql += ' FROM vyuha_Schedule_Item__c';
        return soql;
    }

}
