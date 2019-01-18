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
    
    public vy_ScheduleItem ( vy_Formation formation, vy_Coordinator coordinator ) {
        this.formation      = formation;
        this.coordinator    = coordinator;
    }

    public vy_ScheduleItem ( Vyuha_Schedule_Item__c siRecord ) {
        // turn the record into a actual si object
        this.isActive               = (boolean)     siRecord.get ( 'Active__c'                  );
        this.oneTimeDateTime        = (Datetime)    siRecord.get ( 'One_Time_DateTime__c'       );
        this.lastSuccessfulRun      = (Datetime)    siRecord.get ( 'Last_Successful_Run__c'     );
        this.lastErrorEncountered   = (Datetime)    siRecord.get ( 'Last_Error_Encountered__c'  );
        this.frequency              = (string)      siRecord.get ( 'Frequency__c'               );

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

    public boolean isRunnable ( Datetime executionDatetime ) {
        vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'executeDatetime', executionDatetime );
        vy_Coordinator.debugOutput ( 'vy_ScheduleItem::isRunnable', 'object values', this );
        // check for active
        if ( this.isActive == FALSE ) {
            return FALSE;
        }

        // check for onetime runnable
        if ( this.frequency == 'One Time' ) {
            if (((( this.lastSuccessfulRun != null ) && ( this.lastSuccessfulRun < this.oneTimeDateTime )) 
                    || ( this.lastSuccessfulRun == null ))
                    && ( this.oneTimeDateTime <= executionDateTime )) {
                return TRUE;
            } else {
                return FALSE;
            }
        } 

        // check for recurring runnable
        if ( this.frequency == 'Recurring' ) {
            return FALSE;
        }

        return FALSE;

    }

    public boolean isRunning () {
        return this.formation.isRunning ();
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
        soql += 'SELECT ' + String.join ( fields, ',' );
        soql += ' FROM vyuha_Schedule_Item__c';
        return soql;
    }
}
