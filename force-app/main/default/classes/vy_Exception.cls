public class vy_Exception extends Exception {
    
    string className;
    Exception e;
    string msg;

    public vy_Exception ( vy_ExceptionParent parent, Exception e ) {
        // handle
        this.className = parent.className ();
        this.e = e;
        this.notify ();
    }

    public vy_Exception ( vy_ExceptionParent parent, string msg ) {
        // handle
        this.className = parent.className ();
        this.msg = msg;
        this.notify ();
    }

    private void notify () {
        vy_Coordinator.debugOutput ('vy_Exception', 'this', this );
    }

}
