// Generic Processor Item interface

public interface vy_ProcessorItem {

    // init and validation
    void load ( Id recordId );
    boolean isValid ();
    boolean isRunning ();
    boolean isRunnable ();

    // processing methods
    void start ();
    string getSoqlStatement ();
    void execute ( List < sObject > dataList );
    void complete ();

    // status methods
    void setStatus ( vy_Signal.Vyuha_Status status );
    string getStatus ();
    
    // data access methods
    string getId ();
    string getType ();
}
