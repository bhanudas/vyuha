// Coordinator
// Container for control and monitoring

global with sharing class vy_Coordinator {

    // base constructor for general Coordinator use
    global vy_Coordinator () {
        
    }

    global void writeLogEntry ( vy_Processor processor ) {

        // check to see if Job ID already exists
        List < vyuha_log__c > vlList = fetchLogEntry ( processor.getApexJobId ());
        
        ID existingVl;

        if ( vlList.size () != 0 ) {
            existingVl = vlList[0].id;
        }

        vyuha_log__c vl = new vyuha_log__c ();
        vl.Apex_Job_ID__c = processor.getApexJobId ();
        vl.Status__c = processor.getStatus ().name ();
        vl.id = existingVl;

        upsert vl;

    }

    private static List < vyuha_log__c > fetchLogEntry ( ID apexJobId ) {
        return new List < vyuha_log__c > ([ SELECT ID, Status__c FROM vyuha_log__c WHERE Apex_Job_ID__c = : apexJobId FOR UPDATE ]);
    }

    global static string getJobStatus ( ID apexJobId ) {
        List < vyuha_log__c > vlList = fetchLogEntry ( apexJobId );

        if ( vlList.size () != 0 ) {
            return vlList[0].status__c;
        } else {
            return null;
        }
    }
/*
    global static vy_Formation getNextFormation ( vy_Formation currentFormation ) {

        List < Vyuha_Formation__mdt > formations;
        vy_Formation returnFormation = new vy_Formation ();

        if ( Test.isRunningTest() ) {
            formations = [ SELECT DeveloperName FROM Vyuha_Formation__mdt WHERE Is_Test__c = TRUE ORDER BY Order__c ];
        } else {
            formations = [ SELECT DeveloperName FROM Vyuha_Formation__mdt WHERE Active__c = TRUE AND Is_Test__c = FALSE ORDER BY Order__c ];
        }

        string nextFormationName = '';
        
        boolean foundCurrent = false;
        for ( Vyuha_Formation__mdt formation : formations ) {
            nextFormationName = formation.DeveloperName;
            if ( foundCurrent ) {
                break;
            }
            if ( formation.DeveloperName == currentFormation.getName () ) {
                foundCurrent = true;
                nextFormationName = '';
            }
        }

        vy_Coordinator.debugOutput ( 'vy_Coordinator::getNextFormation','Next Found', nextFormationName );
        // load the formation and return
        returnFormation.load ( nextFormationName );
        return returnFormation;

    }
*/
    global static void debugOutput ( String classInfo, String Message, Object data ) {
        System.debug ( '=== ' + classInfo + ' - ' + message + ' [ ' + data + ' ] ');
    }

}
