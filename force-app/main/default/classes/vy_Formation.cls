// Interface to Custom Metadata "Formation" information

global with sharing class vy_Formation {

    global String name;
    global String soqlStatement;
    global String flowInterviewName;
    global Boolean isValid;
    global Integer batchSize;

    global vy_Formation () {
        this.soqlStatement = '';
        this.flowInterviewName = '';
        isValid = false;
        name = '';
        system.debug ('vy_Formation.constructor () ' + this );
    }

    global boolean load ( String formationName ) {
        // read from CMT
        Set < string > fields = new Set < string > ();
        fields.add ( 'DeveloperName' );
        fields.add ( 'Flow_Name__c' );
        fields.add ( 'Active__c' );
        fields.add ( 'Batch_Size__c' );
        fields.add ( 'Soql_Statement__c' );

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
        // convert records to list of ID
        List < String > idsToProcess = new List < String > ();

        for ( sObject sObj : recordsToProcess ) {
            idsToProcess.add ( (String) sObj.get ('id'));
        }

        // convert the IDs into a Map structure for input into flow
        Map < String, List < String >> inputMap = new Map < String, List < String >> ();
        inputMap.put ( 'inputIDs', idsToProcess );

        System.debug ( '==== FlowInterface.JobLogic.executeBatch == inputMap : ' + inputMap );
        System.debug ( '==== FlowInterface.JobLogic.executeBatch == Flow : ' + this.flowInterviewName );

        // TODO: error handling 
        // invoke the associated Flow
        Flow.Interview jobFlow = Flow.Interview.CreateInterview ( this.flowInterviewName, inputMap );
        jobFlow.start ();

        return true; // return false if execute fails
    }

}
