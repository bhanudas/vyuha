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

    // specialized log entry for a Scheduled job
    global void writeLogEntryScheduled ( string jobId ) {
        // check to see if Job ID already exists
        List < vyuha_log__c > vlList = fetchLogEntry ( jobId );
        
        ID existingVl;

        if ( vlList.size () != 0 ) {
            existingVl = vlList[0].id;
        }

        vyuha_log__c vl = new vyuha_log__c ();
        vl.Apex_Job_ID__c = jobId;
        vl.Status__c = vy_Processor.JobStatus.SCHEDULED.name ();
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

    global static vy_Formation getNextFormation ( vy_Formation currentFormation ) {

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

        if ( currentFormation.getName () == null ) {
            // this is an empty Formation, just return the first record
            nextFormationName = formations[0].DeveloperName;
        } else {
            boolean foundCurrent = false;
            for ( Vyuha_Formation__mdt formation : formations ) {
                if ( foundCurrent ) {
                    nextFormationName = formation.DeveloperName;
                    break;
                }
                if ( formation.DeveloperName == currentFormation.getName () ) {
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

}
