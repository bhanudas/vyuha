// Generic Processor Item interface

public interface vy_ProcessorItem {

    // init and validation
    void load ( Id recordId );
    boolean isValid ();
    boolean isRunning ();

    // processing methods
    void start ();
    string getSoqlStatement ();
    void execute ( List < sObject > dataList );
    void complete ();

    // logging and control
    void writeLog ( vy_Processor processor );
    void errorLog ( string errorClass, string errorMessage );

}
