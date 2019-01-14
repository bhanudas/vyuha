// vy_ScheduleItem
// Interface to Scheduled Item

public class vy_ScheduleItem implements vy_ProcessorItem, vy_ExceptionParent {

    private vy_Formation formation;
    private vy_Coordinator coordinator;
    
    public vy_ScheduleItem ( vy_Formation formation, vy_Coordinator coordinator ) {
        this.formation = formation;
        this.coordinator = coordinator;
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
}
