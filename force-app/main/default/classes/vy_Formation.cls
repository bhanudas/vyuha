// Interface to Custom Metadata "Formation" information

global with sharing class vy_Formation {

    global String name;
    global String soqlStatement;
    global String flowInterviewName;
    global Boolean isValid;
    global Boolean isOnDemand;
    global Integer batchSize;
    global integer recordsProcessed;

    private string notificationEmailAddresses;
    private integer errorCount;
    private string errorMessage;

    global vy_Formation () {
        this.soqlStatement = '';
        this.flowInterviewName = '';
        this.isValid = false;
        this.name = '';
        this.errorCount = 0;
        this.errorMessage = '';
        this.recordsProcessed = 0;
        this.isOnDemand = false;
    }

    // on demand initialization
    global vy_Formation ( String jobName, String flowInterviewName, String soqlStatement, Integer batchSize, String notificationEmailAddresses ) {
        this.isOnDemand = true;
        this.name = jobName;
        this.flowInterviewName = flowInterviewName;
        this.soqlStatement = soqlStatement;
        this.batchSize = batchSize;
        this.notificationEmailAddresses = notificationEmailAddresses;
        this.errorCount = 0;
        this.errorMessage = '';
        this.recordsProcessed = 0;
    }

    global boolean load ( String formationName ) {
        // read from CMT
        Set < string > fields = new Set < string > ();
        fields.add ( 'DeveloperName' );
        fields.add ( 'Flow_Name__c' );
        fields.add ( 'Active__c' );
        fields.add ( 'Batch_Size__c' );
        fields.add ( 'Soql_Statement__c' );
        fields.add ( 'Notification_Email__c' );

        // build soql statement
        string soql = 'SELECT ';
        for ( string fieldName : fields ) {
            soql = soql + fieldName + ',';
        }
        soql = soql.left ( soql.length () - 1 );
        soql = soql + ' FROM Vyuha_Formation__mdt WHERE Active__c = TRUE AND DeveloperName = \'' + formationName + '\'';

        if ( Test.isRunningTest() ) {
            // add the Test clause here
            soql = soql + ' AND Is_Test__c = TRUE';
        } else {
            soql = soql + ' AND Is_Test__c = FALSE';
        }

        List < vyuha_formation__mdt > formationRecords = Database.Query ( soql );

        if ( formationRecords.size () == 0 ) {
            return false;
        } 

        // load values
        this.name = (string) formationRecords[0].get ( 'DeveloperName' );
        this.flowInterviewName = (string) formationRecords[0].get ( 'Flow_Name__c' );
        this.batchSize = Integer.valueOf ( (decimal) formationRecords[0].get ( 'Batch_Size__c' ));
        this.soqlStatement = (string) formationRecords[0].get ( 'Soql_Statement__c' );
        this.notificationEmailAddresses = (string) formationRecords[0].get ( 'Notification_Email__c' );
        this.isValid = true;

        return true;
    }

    // launches a formation as a batch job
    global string launch () {
        if ( this.isValid ) {
            vy_Processor processor = new vy_Processor ( this, new vy_Coordinator ());
            return Database.executeBatch ( processor, this.batchSize );
        } else {
            // formation is not valid - do nothing
            return null;
        }
    }

    global string getName () {
        return this.name;
    }

    global string getSoqlStatement () {
        return this.soqlStatement;
    }

    global boolean isValid () {
        return this.isValid;
    }

    global integer getBatchSize () {
        return this.batchSize;
    }

    global Boolean executeFlow ( List < sObject > recordsToProcess ) {
        // iterate through records to process, passing into a Flow Interview
        for ( sObject sObj : recordsToProcess ) {
            String inputId = (String) sObj.get ('id');
            // convert the IDs into a Map structure for input into flow
            Map < String, String > inputMap = new Map < String, String > ();
            inputMap.put ( 'inputID', inputId );
            vy_Coordinator.debugOutput ( 'vy_Formation::executeFlow', 'inputMap', inputMap );
            vy_Coordinator.debugOutput ( 'vy_Formation::executeFlow', 'Flow', this.flowInterviewName );

            // TODO: error handling 
            // invoke the associated Flow
            Flow.Interview jobFlow = Flow.Interview.CreateInterview ( this.flowInterviewName, inputMap );
            jobFlow.start ();
        }

        return true; // return false if execute fails
    }

    global void addError ( String stage, String message ) {
        this.errorCount++;
        this.errorMessage = this.errorMessage + '\n' + '(Formation: ' + this.name + ') Error #' + String.valueOf ( this.errorCount ) + ' ------\n' +'Stage: ' + stage + '\n' + 'Message: ' + message + '\n';
    }

    global void complete () {
        // send email notifications
        sendNotificationEmail ();

    }

    private void sendNotificationEmail ( ) {

        string[] toaddress;
        if ( this.notificationEmailAddresses != null ) {
            toaddress = ( this.notificationEmailAddresses ).split('[;,\n)]');
        } else {
            return;
        }

        string dateString = System.now().format('EEEE, MMMM d, yyyy hh:mm a');

        string body = 'Job Complete for ' + this.name + ' - ' + dateString + '\n\n';
        body += 'Total Records Processed ' + this.recordsProcessed + '\n';
        body += 'Total Errors: ' + this.errorCount + '\n';
        if ( this.errorCount > 0 ) {
            body += '==== Errors ===== \n' + this.errorMessage;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toaddress);
        mail.setsubject( 'Salesforce Automated Job Processing Report ' + dateString );
        mail.setPlainTextBody(body);
        
        // send the email.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}

}
