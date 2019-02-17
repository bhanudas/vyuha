// Event Handler

public class vy_EventHandler {
    
    // primary processor for incoming Events

    public static void process ( List < Vyuha_Event__e > events ) {
        // create Signals for each Event
        for ( Vyuha_Event__e event : events ) {
            vy_Signal signal = (vy_Signal) JSON.deserialize( event.Data__c, vy_Signal.class );
            signal.initialize ();
            if ( signal.isValid ()) {
                // load appropriate processorItem
                vy_ProcessorItem processorItem;
                if ( signal.scheduleItemId != null ) {
                    // load schedule Item
                    vy_ScheduleItem scheduleItem = new vy_ScheduleItem ( new vy_TimeHelper ());
                    scheduleItem.load ( signal.scheduleItemId );
                    processorItem = (vy_ProcessorItem) scheduleItem;
                } else if ( signal.formationId != null ) {
                    // load a formation
                    vy_Formation formation = new vy_Formation ();
                    formation.load ( signal.formationId );
                    processorItem = (vy_ProcessorItem) formation;
                }

                // process actions
                if ( signal.vType == vy_Signal.Signal_Type.ACTION ) {
                    vy_EventHandler.processActions ( signal, processorItem );
                } else if ( signal.vType == vy_Signal.Signal_Type.STATUS ) {
                    vy_EventHandler.processStatus ( signal, processorItem );
                }
                
            } else {
                // handle invalid signal
            }
            
        }
    }

    private static void processActions ( vy_Signal signal, vy_ProcessorItem processorItem ) {
        if ( signal.vAction == vy_Signal.Vyuha_Action.START ) {
            // check validity and start if possible
            if ( processorItem.isValid () == false ) {
                // handle invalid item
            } else if ( processorItem.isRunning () == true ) {
                // handle already running
            } else if ( processorItem.isRunnable () != true ) {
                // handle not runnable
            } else { 
                // start
                processorItem.start ();
            }
        }
        if ( signal.vAction == vy_Signal.Vyuha_Action.STOP ) {
            // attempt to stop
        }
    }

    private static void processStatus ( vy_Signal signal, vy_ProcessorItem processorItem ) {
        processorItem.setStatus ( signal.vStatus );
    }
}
