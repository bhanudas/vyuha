// Class to be scheduled and runs a Schedule Item via Apex Job Scheduler
// This class should be scheduled to run at whatever interval necessary (hourly)
// Note: Scheduled jobs are set to the TZ of the user that started the job

public class vy_Scheduler implements System.Schedulable, vy_ExceptionParent {
    
    public vy_Scheduler ( ) {

    }

    public void execute ( System.SchedulableContext scheduleableContext ) {
        try {
            // check for any runnable items
            vy_Coordinator coordinator = new vy_Coordinator ();
            List < vy_ScheduleItem > scheduleItems = coordinator.getScheduleItemsToRun ( this );

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

}
