// Interface to Custom Metadata "Formation" information

global with sharing class vy_Formation {

    global String name;
    global String soqlStatement;
    global String flowInterviewName;
    global Boolean isValid;
    global Integer batchSize;
    global Set < string > scheduledHours;

    global vy_Formation () {
        this.soqlStatement = '';
        this.flowInterviewName = '';
        isValid = false;
        name = '';
        this.scheduledHours = new Set < string > ();
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
        for ( integer i = 1; i <= 23; i++ ) {
            fields.add ( 'Hour_' + String.valueOf ( i ) + '__c' );
        }

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
        for ( integer i = 1; i <= 23; i++ ) {
            if ( (boolean) formationRecords[0].get ( 'Hour_' + String.valueOf ( i ) + '__c' )) {
                this.scheduledHours.add ( String.valueOf ( i ));
            }
        }
        return true;
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

    global Set < string > getScheduledHours () {
        return this.scheduledHours;
    }

    // checks formation definition against current time and determines next Run Time
    global DateTime getNextRunDateTime () {
        return null;
    }

    global List < vy_Formation > getActiveFormations () {

        List < vy_Formation > returnList = new List < vy_Formation > ();

        // get list of all actives
        List < vyuha_formation__mdt > formationRecords = Database.Query ( 'SELECT DeveloperName FROM vyuha_formation__mdt WHERE Active__c = TRUE' );
        for ( vyuha_formation__mdt formationRecord : formationRecords ) {
            vy_Formation newFormation = new vy_Formation ();
            newFormation.load ( (string) formationRecord.get ( 'DeveloperName' ));
            returnList.add ( newFormation );
        }
        return returnList;
    }

    global vy_Formation getNextFormation () {

        List < Vyuha_Formation__mdt > formations;

        if ( Test.isRunningTest() ) {
            formations = [ SELECT DeveloperName FROM Vyuha_Formation_mdt WHERE Is_Test__c = TRUE ORDER BY Order__c ];
        } else {
            formations = [ SELECT DeveloperName FROM Vyuha_Formation_mdt WHERE Active__c = TRUE AND Is_Test__c = FALSE ORDER BY Order__c ];
        }

        if ( formations.size () == 0 ) {
            // no formations to run, return null
            return null;
        }

        string nextFormationName = '';

        if ( this.name == null ) {
            // this is an empty Formation, just return the first record
            nextFormationName = formations[0].DeveloperName;
        } else {
            boolean foundCurrent = false;
            for ( Vyuha_Formation__mdt formation : formations ) {
                if ( foundCurrent ) {
                    nextFormationName = formation.DeveloperName;
                    break;
                }
                if ( formation.DeveloperName == this.name ) {
                    foundCurrent = true;
                }
            }
        }

        if ( nextFormationName == '' ) {
            // we were at the last one already - nothing left, return null
            return null;
        }

        // load the formation and return
        vy_Formation returnFormation = new vy_Formation ();
        returnFormation.load ( nextFormationName );
        return returnFormation;
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

    global Date getScheduledDate () {
        // default to today
        return Date.today ();
    }

}
