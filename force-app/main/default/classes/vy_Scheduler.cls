// Class to be scheduled and runs a Schedule Item via Apex Job Scheduler

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

            // reschedule job for next hour

        } catch ( Exception e ) {
            throw new vy_Exception ( this, e );
        }
        
    }

    public string className () {
        return 'vy_Scheduler';
    }

}
