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
    public String apexJobId;
    public String action;
    public String status;
    public String message;
    public Boolean isValid;

    public Vyuha_Action vAction;
    public Vyuha_Status vStatus;
    public Signal_Type vType;

    public enum Vyuha_Action { START, STOP }
    public enum Vyuha_Status { SLEEP, STARTING, ITERATION, STOPPING, ERROR, INACTIVE }
    public enum Signal_Type { ACTION, STATUS }

    public vy_Signal() {

    }

    // takes public attributes and initializes the object
    // for use when instatiating via JSON serialize
    public void initialize () {
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
    public boolean put () {
        String jsonStr = JSON.serialize( this );
        Vyuha_Event__e event = new Vyuha_Event__e ();
        event.data__c = jsonStr;
        event.Apex_Job_ID__c = this.apexJobId;
        event.Formation_ID__c = this.formationId;
        event.Schedule_Item_ID__c = this.scheduleItemId;
        event.Status__c = this.status;
        Database.SaveResult sr = EventBus.publish ( event );
        if ( sr.isSuccess () == false ) {
            // handle exception
            throw new vy_Exception ( this, 'put failed' );
        } else {
            return true;
        }
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

    public string className () {
        return 'vy_Signal';
    }
}
