// Dispatcher
// Primary queueable class that chain executes a list of Vyuha events 
// We're doing this to manage the fact that up to 1000 events can be passed 
// into the Dispatcher

public class vy_Dispatcher implements Queueable {

    private vy_ProcessorItem item;
    private List < Vyuha_Event__e > events;
    private Vyuha_Event__e currentEvent;

    public vy_Dispatcher ( List < Vyuha_Event__e > events ) {
        this.events = events;
        if ( this.events.size () > 0 ) {
            // if we have an item on the list, pop the top
            this.currentEvent = this.events.remove ( 0 );
        }
    }

    public void execute(QueueableContext context) {

        // process the event
        vy_Coordinator coordinator = new vy_Coordinator ();
        coordinator.processEvent ( new vy_Event ( this.currentEvent ));

        // chain the next event
        System.enqueueJob( new vy_Dispatcher ( this.events ));

    }
}
