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
            System.assertEquals ( 'Vyuha', c.LastName );
        }
    }
}
