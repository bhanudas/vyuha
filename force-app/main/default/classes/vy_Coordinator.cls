// Coordinator
// Container for control and monitoring

public class vy_Coordinator implements vy_ExceptionParent {

    // base constructor for general Coordinator use

    public vy_Coordinator ( ) {

    }

    public List < vy_ScheduleItem > getScheduleItemsToRun ( vy_Scheduler scheduler ) {

        List < vy_ScheduleItem > scheduleItems = new List < vy_ScheduleItem > ();
        try {
            // use the scheduler to determine the time to check
            Datetime currentDateTime = scheduler.now ();

            // query the database for active, non running items
            List < Vyuha_Schedule_Item__c > sObjectItems = new List < Vyuha_Schedule_Item__c > ();
            string query = vy_ScheduleItem.baseSelectQuery ();
            vy_Coordinator.debugOutput ('vy_Coordinator::getScheduleItemsToRun', 'soql query', query );
            sObjectItems = Database.query ( query );
            vy_Coordinator.debugOutput ('vy_Coordinator::getScheduleItemsToRun', 'returned items', sObjectItems );
            // get recurrings

            // transform into SI Objects
            for ( Vyuha_Schedule_Item__c si : sObjectItems ) {
                vy_ScheduleItem sItem = new vy_ScheduleItem ( si, currentDateTime );
                scheduleItems.add ( sItem );
            }

            // remove all items are are not runnable
            
            for ( integer idx = scheduleItems.size () - 1; idx >= 0; idx-- ) {
                if ( scheduleItems [ idx ].isRunnable () == FALSE ) {
                    scheduleItems.remove ( idx );
                }
            }
        } catch ( vy_Exception e ) {
            // if vy_exception found, return empty list
            return new List < vy_ScheduleItem > ();
        } catch ( exception e ) {
            // generic exception catch
            throw new vy_Exception ((vy_ExceptionParent) this, e );
        }
        
        // return items that are runnable
        return scheduleItems;
    }

    public void writeLog ( vy_Processor processor ) {

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

    public static string getJobStatus ( ID apexJobId ) {
        List < vyuha_log__c > vlList = fetchLogEntry ( apexJobId );

        if ( vlList.size () != 0 ) {
            return vlList[0].status__c;
        } else {
            return null;
        }
    }

    public static void debugOutput ( String classInfo, String Message, Object data ) {
        System.debug ( '=== ' + classInfo + ' - ' + message + ' [ ' + data + ' ] ');
    }


    public void sendNotificationEmail ( vy_Formation formation ) {

        string[] toaddress;
        if ( formation.getNotificationEmailAddresses () != null ) {
            toaddress = ( formation.getNotificationEmailAddresses ()).split('[;,\n)]');
        } else {
            return;
        }

        string dateString = System.now().format('EEEE, MMMM d, yyyy hh:mm a');

        string body = '';
        /*
        body += 'Job Complete for ' + this.name + ' - ' + dateString + '\n\n';
        body += 'Total Records Processed ' + this.recordsProcessed + '\n';
        body += 'Total Errors: ' + this.errorCount + '\n';
        if ( this.errorCount > 0 ) {
            body += '==== Errors ===== \n' + this.errorMessage;
        }
*/
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toaddress);
        mail.setsubject( 'Salesforce Automated Formation Job Processing Report ' + dateString );
        mail.setPlainTextBody(body);
        
        // send the email.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

		}

        public string className () {
            return 'vy_Coordinator';
        }
}
