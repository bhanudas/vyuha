@isTest

public class vy_Coordinator_Test {

    @testSetup
    public static void testSetup () {
        vyuha_Formation__c formation = new vyuha_Formation__c ();
        formation.name                          = 'Test Formation';
        formation.Soql_Statement__c             = 'SELECT ID FROM USER LIMIT 1';
        formation.Flow_Interview_Name__c        = 'Vyuha_Contact_Test';
        formation.Flow_Input_Variable_Name__c   = 'ID';
        formation.batch_size__c                 = 200;
        formation.active__c                     = true;
        insert formation;

        vyuha_Schedule_Item__c scheduleItem = new vyuha_Schedule_Item__c ();
        scheduleItem.Vyuha_Formation__c     = formation.id;
        scheduleItem.Frequency__c           = 'One Time';
        scheduleItem.One_Time_Datetime__c   = Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 );
        scheduleItem.Last_Successful_Run__c = null;
        insert scheduleItem;
    }
    
    @isTest
    public static void getScheduleItemsToRun_OneTime () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 ));

        vy_Scheduler mockScheduler = (vy_Scheduler) Test.createStub ( vy_Scheduler.class, new vy_MockService ( params ));

        Test.startTest ();

        vy_Coordinator coordinator = new vy_Coordinator ();
        List < vy_ScheduleItem > scheduleItems = coordinator.getScheduleItemsToRun ( mockScheduler );

        Test.stopTest ();

        system.assertEquals ( 1, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_TooEarly () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 13, 00, 00 ));

        vy_Scheduler mockScheduler = (vy_Scheduler) Test.createStub ( vy_Scheduler.class, new vy_MockService ( params ));

        Test.startTest ();

        vy_Coordinator coordinator = new vy_Coordinator ();
        List < vy_ScheduleItem > scheduleItems = coordinator.getScheduleItemsToRun ( mockScheduler );

        Test.stopTest ();

        system.assertEquals ( 0, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_LateRun () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 14, 30, 00 ));

        vy_Scheduler mockScheduler = (vy_Scheduler) Test.createStub ( vy_Scheduler.class, new vy_MockService ( params ));

        Test.startTest ();

        vy_Coordinator coordinator = new vy_Coordinator ();
        List < vy_ScheduleItem > scheduleItems = coordinator.getScheduleItemsToRun ( mockScheduler );

        Test.stopTest ();

        system.assertEquals ( 1, scheduleItems.size ());
    }
}
