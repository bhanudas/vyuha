// Interface to Custom Metadata "Formation" information

global with sharing class vy_Formation {

    global String name;
    global String soqlStatement;
    global String flowInterviewName;
    global Boolean isValid;

    global vy_Formation () {
        this.soqlStatement = '';
        this.flowInterviewName = '';
        isValid = false;
        name = '';
        system.debug ('vy_Formation.constructor () ' + this );
    }

    global Boolean load ( String formationName ) {
        // read from CMT
        return true;
    }

    global string getName () {
        system.debug ('vy_Formation.getName () ' + this );
        return this.name;
    }

    global string getSoqlStatement () {
        return this.soqlStatement;
    }

    global Boolean isValid () {
        return this.isValid;
    }

    global Boolean executeFlow ( List < sObject > recordsToProcess ) {
        // convert records to list of ID
        List < String > idsToProcess = new List < String > ();

        for ( sObject sObj : recordsToProcess ) {
            idsToProcess.add ( (String) sObj.get ('id'));
        }

        // convert the IDs into a Map structure for input into flow
        Map < String, List < String >> inputMap = new Map < String, List < String >> ();
        inputMap.put ( 'inputIDs', idsToProcess );

        System.debug ( '==== FlowInterface.JobLogic.executeBatch == inputMap : ' + inputMap );
        System.debug ( '==== FlowInterface.JobLogic.executeBatch == Flow : ' + this.flowInterviewName );

        // TODO: error handling 
        // invoke the associated Flow
        Flow.Interview jobFlow = Flow.Interview.CreateInterview ( this.flowInterviewName, inputMap );
        jobFlow.start ();

        return true; // return false if execute fails
    }

}
