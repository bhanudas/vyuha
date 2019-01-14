// vy_ScheduleItem
// Interface to Scheduled Item

public class vy_ScheduleItem {

    private vy_Formation formation;
    private vy_Coordinator coordinator;
    
    public vy_ScheduleItem ( vy_Formation formation, vy_Coordinator coordinator ) {

    }

    // isRunning
    // ----------------------
    // Indicates if the scheduler is running
    public boolean isRunning () {
        return true;
    }

    // start
    // -----
    // Initiates the scheduler
    public boolean start () {
        return true;
    }

    // stop
    // ----
    // Stops the scheduler - queries all active jobs and removes any future runs
    public boolean stop () {
        return true;
    }

    // respawn
    // -------
    // Used to create the next job for recurring items
    public boolean respawn () {
        //System.schedule('test', '0 47 18 * * ?', new vy_Processor (new vy_Formation (), new ));
        return true;
    }
}
