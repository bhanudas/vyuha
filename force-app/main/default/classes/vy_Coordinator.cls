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

    // interface to setup the day's schedule based on a formation
    global void scheduleFormation ( vy_Formation formation ) {
        // build the schedule 
        Date today = formation.getScheduledDate ();
        String year = String.valueOf ( today.year () );
        String month = String.valueOf ( today.month () );
        String day = String.valueOf ( today.day () );

        for ( String hour : formation.getScheduledHours ()) {
            string scheduleCronExp = '0 0 ' + hour + ' ' + day + ' ' + month + ' ? ' + year;
            string scheduleLabel = 'VY-' + formation.getName () + '[' + hour + ']';
            
            System.debug ( 'scheduleFormation - cron label ' + scheduleLabel );
            System.debug ( 'scheduleFormation - formation ' + formation );
            System.debug ( 'scheduleFormation - cron exp ' + scheduleCronExp );
            
            string jobId = System.schedule ( scheduleLabel, scheduleCronExp, new vy_Schedulable ( formation ) ); 

            writeLogEntryScheduled ( jobId );
        }
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

}
