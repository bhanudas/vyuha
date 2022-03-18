public with sharing class vy_OnDemandInvocable {

    public class Parameters {
        @InvocableVariable ( label='Flow API Name' description='API Name of flow to run in bulk automation system' required=true )
        public String flowApiName;
        @InvocableVariable ( label='Target Object API Name' description='SOQL statement = FROM Clause' required=true )
        public String targetObject;
        @InvocableVariable ( label='Filter (1) Field API Name' description='SOQL statement = WHERE Field' required=true )
        public String filterFieldApiName;
        @InvocableVariable ( label='Filter (1) Value' description='SOQL statement = WHERE Value' required=true )
        public String filterValue;
        @InvocableVariable ( label='On Demand Name' description='Name identifier for job/run' required=true )
        public String onDemandName;
        @InvocableVariable ( label='Batch Size' description='Number of records to run per batch' required=true )
        public Integer batchSize;
        @InvocableVariable ( label='Notification Email Address' description='Email Address for notifications' required=false )
        public string notificationEmail;
    }

    @InvocableMethod ( label='Vyuha On Demand' description='Invokes bulk flow system' category='Bulk Automation' )
    public static void invocableMethod ( List < Parameters > params ) {
        for ( Parameters p : params ) {
            String soqlStatement = 'SELECT Id FROM ' + p.targetObject;
            String whereClause = null;
            if (( String.isEmpty ( p.filterFieldApiName) == false ) && ( String.isEmpty( p.filterValue ) == false )) {
                whereClause = p.filterFieldApiName + '=\'' + p.filterValue + '\'';
                soqlStatement = soqlStatement + ' WHERE ' + whereClause;
            }
            vy_Formation formation = new vy_Formation ( p.onDemandName, p.flowApiName, soqlStatement, p.batchSize, p.notificationEmail );
            formation.launch ();
        }

    }
}
