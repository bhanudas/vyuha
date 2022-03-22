public with sharing class vy_OnDemandInvocable {

    public class Parameters {
        @InvocableVariable ( label='Flow API Name' description='API Name of flow to run in bulk automation system' required=true )
        public String flowApiName;
        @InvocableVariable ( label='Target Object API Name' description='SOQL statement = FROM Clause' required=true )
        public String targetObject;
        @InvocableVariable ( label='Filter (1) Field API Name' description='SOQL statement = WHERE Field' required=false )
        public String filterFieldApiName1;
        @InvocableVariable ( label='Filter (1) Value' description='SOQL statement = WHERE Value' required=false )
        public String filterValue1;
        @InvocableVariable ( label='Filter (2) Field API Name' description='SOQL statement = WHERE Field' required=false )
        public String filterFieldApiName2;
        @InvocableVariable ( label='Filter (2) Value' description='SOQL statement = WHERE Value' required=false )
        public String filterValue2;
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
            String whereClause1 = null;
            String whereClause2 = null;
            if (( String.isEmpty ( p.filterFieldApiName1) == false ) && ( String.isEmpty( p.filterValue1 ) == false )) {
                whereClause1 = '(' + p.filterFieldApiName1 + '=\'' + p.filterValue1 + '\')';
            }
            if (( String.isEmpty ( p.filterFieldApiName2) == false ) && ( String.isEmpty( p.filterValue2 ) == false )) {
                whereClause2 = '(' + p.filterFieldApiName2 + '=\'' + p.filterValue2 + '\')';
            }
            // dual clauses
            if (( whereClause1 != null ) && ( whereClause2 != null )) {
                soqlStatement = soqlStatement + ' WHERE (' + whereClause1 + ' AND ' + whereClause2 + ')';
            } else if ( whereClause1 != null ) {
                soqlStatement = soqlStatement + ' WHERE ' + whereClause1;
            }
            vy_Formation formation = new vy_Formation ( p.onDemandName, p.flowApiName, soqlStatement, p.batchSize, p.notificationEmail );
            formation.launch ();
        }

    }
}
