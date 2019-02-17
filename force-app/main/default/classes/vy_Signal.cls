// vy_Signal
// Represents a signaled message for the Vyuha system
// usage:
// 1. Quick create and queue
//      vy_Signal signal = new vy_Signal ( paramaterized constructor );
//      signal.put ();
// 2. JSON transform, validate and execute
//      vy_Signal signal = (vy_Signal) JSON.deserialize ( jsonStr, vy_Signal.class );
//      signal.initialize ();
//      

public class vy_Signal implements vy_ExceptionParent {

    public String formationId;
    public String scheduleItemId;
    public String id;
    public String processorType;
    public String apexJobId;
    public String action;
    public String status;
    public String message;
    public Boolean isValid;

    public Vyuha_Action vAction;
    public Vyuha_Status vStatus;
    public Signal_Type vType;

    private vy_ProcessorItem processorItem;

    public enum Vyuha_Action { START, STOP }
    public enum Vyuha_Status { SLEEPING, STARTING, ITERATION, STOPPING, ERROR, COMPLETE, INACTIVE }
    public enum Signal_Type { ACTION, STATUS }

    public vy_Signal () {

    }

    public vy_Signal ( vy_Processor processor, Vyuha_Status status, String message ) {
        this.processorItem = processor.getProcessorItem ();
        this.processorType = this.processorItem.getType ();
        this.id = this.processorItem.getId ();
        this.status = status.name ();
        this.apexJobId = processor.getApexJobId ();
        this.message = message;
    }

    public vy_Signal ( vy_Formation formation, Vyuha_Status status, String message ) {
        this.processorType = formation.getType ();
        this.id = formation.getId ();
        this.status = status.name ();
        this.message = message;
    }

    public static void create ( vy_Processor processor, Vyuha_Status status, String message ) {
        vy_Signal signal = new vy_Signal ( processor, status, message );
        signal.initialize ();
        if ( signal.isValid ()) {
            signal.put ();
        } else {
            throw new vy_Exception ( signal, 'Error in create from Processor' );
        }
    }

    public static void create ( vy_Formation formation, Vyuha_Status status, String message ) {
        vy_Signal signal = new vy_Signal ( formation, status, message );
        signal.initialize ();
        if ( signal.isValid ()) {
            signal.put ();
        } else {
            throw new vy_Exception ( signal, 'Error in create from Formation' );
        }
    }

    // takes public attributes and initializes the object
    // for use when instatiating via JSON serialize
    public void initialize () {
        // set correct id
        if ( this.processorType == 'FORMATION' ) {
            this.formationId = this.id;
        } else if ( this.processorType == 'SCHEDULEITEM' ) {
            this.scheduleItemId = this.id;
        }
        // check for formationId or scheduleItem null
        if ( this.formationId == '' ) {
            this.formationId = null;
        }
        if ( this.scheduleItemId == '' ) {
            this.scheduleItemId = null;
        }
        // set isValid to true
        this.isValid = true;

        // set the private Action and Status enums
        this.actionToEnum ();
        this.statusToEnum ();

        // determine the type of signal
        if ( this.vAction == null && this.vStatus != null ) {
            this.vType = Signal_Type.STATUS;
        } else if ( this.vAction != null && this.vStatus == null ) {
            this.vType = Signal_Type.ACTION;
        } else {
            // handle undeterminate signal
            this.isValid = false;
        }
    }

    public boolean isValid () {
        return this.isValid;
    }

    // writes a new signal to the Platform Event queue
    public void put () {
        vy_EventHandler.create ( this );
    }

    // converts local action as string into enum
    private void actionToEnum () {
        boolean foundMatch = false;

        // check if action is empty
        if (( this.action == null ) || ( this.action == '' )) {
            this.vAction = null;
            return;
        }

        for ( Vyuha_Action a : Vyuha_Action.values ()) {
            if ( a.name () == this.action ) {
                this.vAction = a;
                foundMatch = true;
            }
        }

        if ( foundMatch == false ) {
            this.isValid = false;
        }
    }

    // converts local status as string into enum
    private void statusToEnum () {
        boolean foundMatch = false;

        // check if status is empty
        if (( this.status == null ) || ( this.status == '' )) {
            this.vStatus = null;
            return;
        }

        for ( Vyuha_Status s : Vyuha_Status.values ()) {
            if ( s.name () == this.status ) {
                this.vStatus = s;
                foundMatch = true;
            }
        }

        if ( foundMatch == false ) {
            this.isValid = false;
        }
    }

    // --- processing actions and status updates
    public void process () {
        if ( this.isValid ) {
            // load appropriate processorItem
            if ( this.scheduleItemId != null ) {
                // load schedule Item
                vy_ScheduleItem scheduleItem = new vy_ScheduleItem ( new vy_TimeHelper ());
                scheduleItem.load ( this.scheduleItemId );
                this.processorItem = (vy_ProcessorItem) scheduleItem;
            } else if ( this.formationId != null ) {
                // load a formation
                vy_Formation formation = new vy_Formation ();
                formation.load ( this.formationId );
                this.processorItem = (vy_ProcessorItem) formation;
            }

            // process actions
            if ( this.vType == Signal_Type.ACTION ) {
                this.processActions ();
            } else if ( this.vType == Signal_Type.STATUS ) {
                this.processStatus ();
            }
            
        } else {
            // handle invalid signal
        }
    }

    private void processActions () {
        if ( this.vAction == Vyuha_Action.START ) {
            // check validity and start if possible
            if ( this.processorItem.isValid () == false ) {
                // handle invalid item
            } else if ( this.processorItem.isRunning () == true ) {
                // handle already running
            } else if ( this.processorItem.isRunnable () != true ) {
                // handle not runnable
            } else { 
                // start
                this.processorItem.start ();
            }
        }
        if ( this.vAction == Vyuha_Action.STOP ) {
            // attempt to stop
        }
    }

    private void processStatus () {
        this.processorItem.setStatus ( this.vStatus );
    }

    private void writeLog () {

        // check to see if Job ID already exists
        List < vyuha_log__c > vlList = fetchLogEntry ( this.apexJobId );
        
        ID existingVl;

        if ( vlList.size () != 0 ) {
            existingVl = vlList[0].id;
        }

        vyuha_log__c vl = new vyuha_log__c ();
        vl.Apex_Job_ID__c = this.apexJobId;
        vl.Status__c = this.status;
        vl.id = existingVl;
        vl.message__c = this.message;
        vl.Vyuha_Formation__c = this.formationId;
        vl.Vyuha_Schedule_Item__c = this.scheduleItemId;
        upsert vl;

    }

    private List < vyuha_log__c > fetchLogEntry ( ID apexJobId ) {
        return new List < vyuha_log__c > ([ SELECT ID, Status__c FROM vyuha_log__c WHERE Apex_Job_ID__c = : apexJobId FOR UPDATE ]);
    }

    public static void debugOutput ( String classInfo, String Message, Object data ) {
        System.debug ( '=== ' + classInfo + ' - ' + message + ' [ ' + data + ' ] ');
    }

    private void sendNotificationEmail ( ) {
        /*
        string[] toaddress;
        if ( formation.getNotificationEmailAddresses () != null ) {
            toaddress = ( formation.getNotificationEmailAddresses ()).split('[;,\n)]');
        } else {
            return;
        }

        string dateString = System.now().format('EEEE, MMMM d, yyyy hh:mm a');

        string body = '';
        
        body += 'Job Complete for ' + this.name + ' - ' + dateString + '\n\n';
        body += 'Total Records Processed ' + this.recordsProcessed + '\n';
        body += 'Total Errors: ' + this.errorCount + '\n';
        if ( this.errorCount > 0 ) {
            body += '==== Errors ===== \n' + this.errorMessage;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toaddress);
        mail.setsubject( 'Salesforce Automated Formation Job Processing Report ' + dateString );
        mail.setPlainTextBody(body);
        
        // send the email.
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        */
	}
    

    public string className () {
        return 'vy_Signal';
    }
}
