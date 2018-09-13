@isTest

public class vy_Tests {
    @isTest
    public static void processor_basic () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'formationName', 'test' );
        params.put ( 'soqlStatement', 'SELECT ID FROM User' );
        params.put ( 'executeFlowResult', true );
        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( params ));
        vy_Processor processor = new vy_Processor ( mockFormation, new vy_Coordinator ());
        System.debug ( 'Start Test - ' + processor );
        test.startTest();
        ID apexJobID = Database.executeBatch( processor );
        test.stopTest ();
        System.debug ( 'Stop Test - ' + processor );
        System.assertEquals( 'COMPLETED', vy_Coordinator.getJobStatus ( apexJobID ));
    }

    public static void processor_terminate () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'formationName', 'test' );
        params.put ( 'soqlStatement', 'SELECT ID FROM User' );
        params.put ( 'executeFlowResult', false );
        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( params ));
        vy_Processor processor = new vy_Processor ( mockFormation, new vy_Coordinator ());
        System.debug ( 'Start Test - ' + processor );
        test.startTest();
        ID apexJobID = Database.executeBatch( processor );
        test.stopTest ();
        System.debug ( 'Stop Test - ' + processor );
        System.assertEquals( 'ERROR', vy_Coordinator.getJobStatus ( apexJobID ));
    }
}
