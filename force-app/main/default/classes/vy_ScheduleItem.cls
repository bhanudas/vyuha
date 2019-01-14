// vy_ScheduleItem
// Interface to Scheduled Item

public class vy_ScheduleItem implements vy_ProcessorItem, vy_ExceptionParent {

    private vy_Formation formation;
    private vy_Coordinator coordinator;
    
    public vy_ScheduleItem ( vy_Formation formation, vy_Coordinator coordinator ) {
        this.formation = formation;
        this.coordinator = coordinator;
    }

    public vy_ScheduleItem ( Vyuha_Schedule_Item__c siRecord ) {
        // turn the record into a actual si object
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
        fields.add ( 'Vyuha_Formation__r.Active__c' );
        fields.add ( 'Vyuha_Formation__c' );
        fields.add ( 'Vyuha_Formation__r.Name' );
        soql += 'SELECT ' + String.join ( fields, ',' );
        soql += ' FROM vyuha_Schedule_Item__c';
        return soql;
    }
}
