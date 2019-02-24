// Flow interface - injectable class for executing a flow

public class vy_FlowInterface {

    String idFieldName;
    String interviewName;
    List < sObject > data;
    Integer recordsProcessed;

    public vy_FlowInterface() {

    }

    public void initialize ( String idFieldName, String interviewName ) {

        this.idFieldName = idFieldName;
        this.interviewName = interviewName;

    }

    public void setData ( List < sObject > data ) {

        this.data = data;

    }

    // returns number of records processed
    public integer execute () {
        this.recordsProcessed = 0;
        for ( sObject sObj : this.data ) {
            String inputId = (String) sObj.get ( this.idFieldName );
            // convert the IDs into a Map structure for input into flow
            Map < String, String > inputMap = new Map < String, String > ();
            inputMap.put ( 'inputID', inputId );
            vy_Signal.debugOutput ( 'vy_Formation::executeFlow', 'inputMap', inputMap );
            vy_Signal.debugOutput ( 'vy_Formation::executeFlow', 'Flow', this.interviewName );
            // invoke the associated Flow
            Flow.Interview jobFlow = Flow.Interview.CreateInterview ( this.interviewName, inputMap );
            jobFlow.start ();
            this.recordsProcessed++;
        }
        return this.recordsProcessed;
    }
}
