@isTest

public class vy_Tests {

    private static vy_Formation createTestFormation () {
        vy_Formation formation = new vy_Formation ();
        formation.name = 'Test Formation';
        formation.soqlStatement = 'SELECT ID FROM USER LIMIT 1';
        formation.flowInterviewName = '';
        formation.batchSize = 200;
        return formation;
    }

    @isTest
    public static void processor_basic () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'executeFlowResult', true );

        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( createTestFormation (), params ));
        vy_Processor processor = new vy_Processor ( mockFormation, new vy_Coordinator ());

        System.debug ( 'Start Test - ' + processor );
        test.startTest();
        ID apexJobID = Database.executeBatch( processor );
        test.stopTest ();
        System.debug ( 'Stop Test - ' + processor );
        System.assertEquals( 'COMPLETED', vy_Coordinator.getJobStatus ( apexJobID ));
    }

    @isTest
    public static void processor_invalid () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'executeFlowResult', true );
        params.put ( 'isValid', false );

        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( createTestFormation (), params ));
        vy_Processor processor = new vy_Processor ( mockFormation, new vy_Coordinator ());

        System.debug ( 'Start Test - ' + processor );
        test.startTest();
        ID apexJobID = Database.executeBatch( processor );
        test.stopTest ();
        System.debug ( 'Stop Test - ' + processor );
        System.assertEquals( 'COMPLETED', vy_Coordinator.getJobStatus ( apexJobID ));
    }

    @isTest
    public static void processor_terminate () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'executeFlowResult', false );
        
        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( createTestFormation (), params ));
        vy_Processor processor = new vy_Processor ( mockFormation, new vy_Coordinator ());
        System.debug ( 'Start Test - ' + processor );
        test.startTest();
        ID apexJobID = Database.executeBatch( processor );
        test.stopTest ();
        System.debug ( 'Stop Test - ' + processor );
        System.assertEquals( 'ERROR', vy_Coordinator.getJobStatus ( apexJobID ));
    }


     @isTest
    public static void run_integrated_test  () {
        
        vy_Coordinator.debugOutput ( 'vy_Tests::run_integrated_test', 'Start Test', null );

        // create 50 contacts
        integer testSize = 50;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }

        insert testContacts;
        
        Test.startTest ();
        vy_CoordinatorFactory cf = new vy_CoordinatorFactory ();
        cf.execute ( null );

        Test.stopTest ();

        vy_Coordinator.debugOutput ( 'vy_Tests::run_integrated_test', 'Stop Test', cf );

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            //System.assertEquals ( 'Vyuha', c.LastName );
        }
    }

    @isTest
    static void onDemandBasic () {
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'Vyuha_On_Demand_Test';
        String soqlStatement = 'SELECT Id FROM Contact';
        Integer batchSize = 25;

        Test.startTest ();
        vy_Formation formation = new vy_Formation ( jobName, flowInterviewName, soqlStatement, batchSize, null );
        formation.launch ();
        Test.stopTest ();

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'Vyuha', c.LastName );
        }

    }

    @isTest
    static void errorLogTest () {
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'fail-name';
        String soqlStatement = 'SELECT Id FROM Contact';
        Integer batchSize = 25;

        Test.startTest ();
        vy_Formation formation = new vy_Formation ( jobName, flowInterviewName, soqlStatement, batchSize, null );
        formation.launch ();
        Test.stopTest ();

        List < Vyuha_Log__c > logs = [ SELECT Id, Apex_Job_Id__c, Flow_Interview_Name__c, Formation_Name__c, Status__c, Message__c, Message_Long__c FROM Vyuha_Log__c ];
        System.debug ( 'logs ===> ' + logs );
    }

    @isTest
    static void onDemandInvocableSingleClause () {
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.firstName = 'test';
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'Vyuha_On_Demand_Test';
        String targetObject = 'Contact';
        String fieldName = 'LastName';
        String fieldValue = 'oldvalue';
        Integer batchSize = 25;

        Test.startTest ();
        vy_OnDemandInvocable.Parameters params = new vy_OnDemandInvocable.Parameters ();
        params.flowApiName = flowInterviewName;
        params.targetObject = targetObject;
        params.filterFieldApiName1 = fieldName;
        params.filterValue1 = fieldValue;
        params.onDemandName = jobName;
        params.batchSize = batchSize;
        params.notificationEmail = null;
        List < vy_OnDemandInvocable.Parameters > paramList = new List < vy_OnDemandInvocable.Parameters > ();
        paramList.add ( params );
        vy_OnDemandInvocable.invocableMethod ( paramList );
        Test.stopTest ();

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'Vyuha', c.LastName );
        }

    }

    @isTest
    static void onDemandInvocableDualClause () {
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.firstName = 'test';
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'Vyuha_On_Demand_Test';
        String targetObject = 'Contact';
        String fieldName1 = 'LastName';
        String fieldValue1 = 'oldvalue';
        String fieldName2 = 'FirstName';
        string fieldValue2 = 'test';
        Integer batchSize = 25;

        Test.startTest ();
        vy_OnDemandInvocable.Parameters params = new vy_OnDemandInvocable.Parameters ();
        params.flowApiName = flowInterviewName;
        params.targetObject = targetObject;
        params.filterFieldApiName1 = fieldName1;
        params.filterValue1 = fieldValue1;
        params.filterFieldApiName2 = fieldName2;
        params.filterValue2 = fieldValue2;
        params.onDemandName = jobName;
        params.batchSize = batchSize;
        params.notificationEmail = null;
        List < vy_OnDemandInvocable.Parameters > paramList = new List < vy_OnDemandInvocable.Parameters > ();
        paramList.add ( params );
        vy_OnDemandInvocable.invocableMethod ( paramList );
        Test.stopTest ();

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'Vyuha', c.LastName );
        }

    }

    @isTest
    static void onDemandInvocableTripleClause () {
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.firstName = 'test';
            c.lastName = 'oldValue';
            c.email = 'test@test.com';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'Vyuha_On_Demand_Test';
        String targetObject = 'Contact';
        String fieldName1 = 'LastName';
        String fieldValue1 = 'oldvalue';
        String fieldName2 = 'FirstName';
        String fieldValue2 = 'test';
        String fieldName3 = 'Email';
        String fieldValue3 = 'test@test.com';
        Integer batchSize = 25;

        Test.startTest ();
        vy_OnDemandInvocable.Parameters params = new vy_OnDemandInvocable.Parameters ();
        params.flowApiName = flowInterviewName;
        params.targetObject = targetObject;
        params.filterFieldApiName1 = fieldName1;
        params.filterValue1 = fieldValue1;
        params.filterFieldApiName2 = fieldName2;
        params.filterValue2 = fieldValue2;
        params.filterFieldApiName3 = fieldName3;
        params.filterValue3 = fieldValue3;
        params.onDemandName = jobName;
        params.batchSize = batchSize;
        params.notificationEmail = null;
        List < vy_OnDemandInvocable.Parameters > paramList = new List < vy_OnDemandInvocable.Parameters > ();
        paramList.add ( params );
        vy_OnDemandInvocable.invocableMethod ( paramList );
        Test.stopTest ();

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'Vyuha', c.LastName );
        }

    }

    @isTest
    static void onDemandInvocableDualClause2 () {
        // Test to make sure that the second filter does actually filter out
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.firstName = 'test';
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'Vyuha_On_Demand_Test';
        String targetObject = 'Contact';
        String fieldName1 = 'LastName';
        String fieldValue1 = 'oldvalue';
        String fieldName2 = 'FirstName';
        string fieldValue2 = 'nomatch';
        Integer batchSize = 25;

        Test.startTest ();
        vy_OnDemandInvocable.Parameters params = new vy_OnDemandInvocable.Parameters ();
        params.flowApiName = flowInterviewName;
        params.targetObject = targetObject;
        params.filterFieldApiName1 = fieldName1;
        params.filterValue1 = fieldValue1;
        params.filterFieldApiName2 = fieldName2;
        params.filterValue2 = fieldValue2;
        params.onDemandName = jobName;
        params.batchSize = batchSize;
        params.notificationEmail = null;
        List < vy_OnDemandInvocable.Parameters > paramList = new List < vy_OnDemandInvocable.Parameters > ();
        paramList.add ( params );
        vy_OnDemandInvocable.invocableMethod ( paramList );
        Test.stopTest ();

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'oldValue', c.LastName );
        }

    }

    @isTest
    static void onDemandInvocableNoWhere () {
        // Test to make sure that the second filter does actually filter out
        integer testSize = 10;
        List < Contact > testContacts = new List < Contact > ();
        for ( integer i = 0; i < testSize; i++ ) {
            Contact c = new Contact ();
            c.firstName = 'test';
            c.lastName = 'oldValue';
            testContacts.add ( c );
        }
        insert testContacts;

        String jobName = 'Test On Demand';
        String flowInterviewName = 'Vyuha_On_Demand_Test';
        String targetObject = 'Contact';
        Integer batchSize = 25;

        Test.startTest ();
        vy_OnDemandInvocable.Parameters params = new vy_OnDemandInvocable.Parameters ();
        params.flowApiName = flowInterviewName;
        params.targetObject = targetObject;
        params.onDemandName = jobName;
        params.batchSize = batchSize;
        params.notificationEmail = null;
        List < vy_OnDemandInvocable.Parameters > paramList = new List < vy_OnDemandInvocable.Parameters > ();
        paramList.add ( params );
        vy_OnDemandInvocable.invocableMethod ( paramList );
        Test.stopTest ();

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'Vyuha', c.LastName );
        }

    }
    
}

