@isTest

public class vy_Tests {

    @testSetup
    public static void testSetup () {
        vyuha_Formation__c formation = new vyuha_Formation__c ();
        formation.name = 'Test Formation';
        formation.Soql_Statement__c = 'SELECT ID FROM USER LIMIT 1';
        formation.Flow_Interview_Name__c = 'Vyuha_Contact_Test';
        formation.Flow_Input_Variable_Name__c = 'ID';
        formation.batch_size__c = 200;
        insert formation;

        vyuha_Schedule_Item__c scheduleItem = new vyuha_Schedule_Item__c ();
        scheduleItem.Vyuha_Formation__c = formation.id;
        scheduleItem.Frequency__c = 'One Time';
        scheduleItem.One_Time_Datetime__c = Datetime.Now ();
        scheduleItem.Preferred_Start_Time__c = '1:00 AM';
    }
/*
    @isTest
    public static void scheduleItem_core () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'soqlstatement', 'SELECT ID FROM USER LIMIT 1' );
        params.put ( 'batchSize', 200 );
        params.put ( 'executeFlowResult', true );

        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( params ));
        vy_ScheduleItem scheduleItem = new vy_ScheduleItem ( mockFormation, new vy_Coordinator ());

        system.assertEquals ( 200, scheduleItem.formation().getBatchSize ());
    }
    */
/*

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
*/
/*
     @isTest
    public static void run_integrated_test  () {
        
        vy_Signal.debugOutput ( 'vy_Tests::run_integrated_test', 'Start Test', null );

        // create 10 contacts
        integer testSize = 10;
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

        vy_Signal.debugOutput ( 'vy_Tests::run_integrated_test', 'Stop Test', cf );

        // query contacts
        testContacts = [ SELECT ID, LastName FROM Contact ];

        for ( Contact c : testContacts ) {
            System.assertEquals ( 'Vyuha', c.LastName );
        }
    }
*/
}
