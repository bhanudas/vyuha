// Interface to Formation information

public class vy_Formation implements vy_ProcessorItem, vy_ExceptionParent {

    public String name;
    public String soqlStatement;
    public String flowInterviewName;
    public Boolean isValid;
    public Integer batchSize;
    public integer recordsProcessed;
    public String flowInputVariableName;

    private string notificationEmailAddresses;
    private integer errorCount;
    private string errorMessage;

    private vy_Coordinator coordinator;
    private vy_ScheduleItem scheduleItem;

    public vy_Formation ( vy_Coordinator coordinator ) {
        this.soqlStatement = '';
        this.flowInterviewName = '';
        this.isValid = false;
        this.name = '';
        this.errorCount = 0;
        this.errorMessage = '';
        this.recordsProcessed = 0;
        this.flowInputVariableName = '';
        this.notificationEmailAddresses = '';
        this.coordinator = coordinator;
    }

    public void load ( Id recordId ) {

        try {
            // read from CMT
            List < string > fields = new List < string > ();
            fields.add ( 'Id' );
            fields.add ( 'Flow_Interview_Name__c' );
            fields.add ( 'Active__c' );
            fields.add ( 'Batch_Size__c' );
            fields.add ( 'Soql_Statement__c' );
            fields.add ( 'Notification_Email_Addresses__c' );
            fields.add ( 'Flow_Input_Variable_Name__c' );

            // build soql statement
            string soql = 'SELECT ' + String.join ( fields, ',' );
            soql += ' FROM Vyuha_Formation__c WHERE Active__c = TRUE AND Id = \'' + recordId + '\'';

            List < sObject > formationRecords = Database.Query ( soql );

            if ( formationRecords.size () == 0 ) {
                throw new vy_Exception ( this, 'Formation with ID ' + recordId + ' not found' );
            } 

            // load values
            this.name                           = (string) formationRecords[0].get ( 'Id' );
            this.flowInterviewName              = (string) formationRecords[0].get ( 'Flow_Interview_Name__c' );
            this.batchSize                      = Integer.valueOf ( (decimal) formationRecords[0].get ( 'Batch_Size__c' ));
            this.soqlStatement                  = (string) formationRecords[0].get ( 'Soql_Statement__c' );
            this.notificationEmailAddresses     = (string) formationRecords[0].get ( 'Notification_Email__c' );
            this.flowInputVariableName          = (string) formationRecords[0].get ( 'Flow_Input_Variable_Name__c' );

            // TODO validate the formation
            this.isValid = true;
        } catch ( Exception e ) {
            throw new vy_Exception ( this, e );
        } 
        
    }

    public boolean isRunning () {
        return true;
    }

    public string getName () {
        return this.name;
    }

    public string getSoqlStatement () {
        return this.soqlStatement;
    }

    public boolean isValid () {
        return this.isValid;
    }

    public integer getBatchSize () {
        return this.batchSize;
    }

    public string getNotificationEmailAddresses () {
        return this.notificationEmailAddresses;
    }

    public void execute ( List < sObject > dataList ) {
        // iterate through records to process, passing into a Flow Interview
        try {
            for ( sObject sObj : dataList ) {
                String inputId = (String) sObj.get ( this.flowInputVariableName );
                // convert the IDs into a Map structure for input into flow
                Map < String, String > inputMap = new Map < String, String > ();
                inputMap.put ( 'inputID', inputId );
                vy_Coordinator.debugOutput ( 'vy_Formation::executeFlow', 'inputMap', inputMap );
                vy_Coordinator.debugOutput ( 'vy_Formation::executeFlow', 'Flow', this.flowInterviewName );
                // invoke the associated Flow
                Flow.Interview jobFlow = Flow.Interview.CreateInterview ( this.flowInterviewName, inputMap );
                jobFlow.start ();
                this.recordsProcessed++;
            }
        } catch ( Exception e ) {
            // handle
            throw new vy_Exception ( this, e );
        }
    }

    public void addError ( String stage, String message ) {
        this.errorCount++;
        this.errorMessage = this.errorMessage + '\n' + '(Formation: ' + this.name + ') Error #' + String.valueOf ( this.errorCount ) + ' ------\n' +'Stage: ' + stage + '\n' + 'Message: ' + message + '\n';
    }

    public void start () {
        try {
            ID batchJobId = Database.executeBatch ( new vy_Processor ( this ), this.batchSize );
        } catch ( Exception e ) {
            throw new vy_Exception ( this, e );
        }
    }

    public void start ( vy_ScheduleItem scheduleItem ) {
        this.scheduleItem = scheduleItem;
        this.start ();
    }

    public void complete () {
        // send email notifications
        coordinator.sendNotificationEmail ( this );

    }

    // logging
    public void writeLog ( vy_Processor processor ) {
        // implement
    }

    public void errorLog ( string errorClass, string errorMessage ) {
        // implement
    }

    // exception

    public string className () {
        return 'vy_Formation';
    }

   

}
