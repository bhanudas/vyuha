// Class to be scheduled and runs a Schedule Item via Apex Job Scheduler
// This class should be scheduled to run at whatever interval necessary (hourly)
// Note: Scheduled jobs are set to the TZ of the user that started the job

public class vy_Scheduler implements System.Schedulable, vy_ExceptionParent {
    
    private vy_TimeHelper timeHelper;

    public vy_Scheduler ( vy_TimeHelper timeHelper ) {
        this.timeHelper = timeHelper;
    }

    public void execute ( System.SchedulableContext scheduleableContext ) {
        try {
            // check for any runnable items
            List < vy_ScheduleItem > scheduleItems = this.getScheduleItemsToRun ();

            // start runnable items
            for ( vy_ScheduleItem item : scheduleItems ) {
                item.start ();
            }

        } catch ( Exception e ) {
            throw new vy_Exception ( this, e );
        }
        
    }

    public string className () {
        return 'vy_Scheduler';
    }

    @testVisible
    private List < vy_ScheduleItem > getScheduleItemsToRun () {

        List < vy_ScheduleItem > scheduleItems = new List < vy_ScheduleItem > ();
        try {
            // use the scheduler to determine the time to check
            Datetime currentDateTime = this.timeHelper.now ();

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

}
