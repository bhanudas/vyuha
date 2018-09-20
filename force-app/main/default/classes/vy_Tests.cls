@isTest

public class vy_Tests {

    private static vy_Formation createTestFormation () {
        vy_Formation formation = new vy_Formation ();
        formation.name = 'Test Formation';
        formation.soqlStatement = 'SELECT ID FROM USER LIMIT 1';
        formation.flowInterviewName = '';
        formation.batchSize = 200;
        formation.scheduledHours.add ( '22' );
        formation.scheduledHours.add ( '23' );

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
        
        System.debug ( 'Start Test ' );
        
        Test.startTest ();
        vy_CoordinatorFactory cf = new vy_CoordinatorFactory ();
        cf.execute ( null );

        Test.stopTest ();

        System.debug ( 'Stop Test - ' + cf );

        // query user to find title
        List < User > users = [ SELECT ID, Title FROM USER ];

        for ( User u : users ) {
            System.assertEquals ( 'Vyuha', u.title );
        }
    }
}
