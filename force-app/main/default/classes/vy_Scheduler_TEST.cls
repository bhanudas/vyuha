@isTest

public class vy_Scheduler_TEST {

    @testSetup
    public static void testSetup () {
        vyuha_Formation__c formation = new vyuha_Formation__c ();
        formation.name                          = 'Test Formation';
        formation.Soql_Statement__c             = 'SELECT ID FROM USER LIMIT 1';
        formation.Flow_Interview_Name__c        = 'Vyuha_Contact_Test';
        formation.Flow_Input_Variable_Name__c   = 'ID';
        formation.batch_size__c                 = 200;
        formation.active__c                     = true;
        formation.status__c                     = 'Sleeping';
        insert formation;
 
        vyuha_Schedule_Item__c scheduleItem = new vyuha_Schedule_Item__c ();
        scheduleItem.Vyuha_Formation__c     = formation.id;
        scheduleItem.Frequency__c           = 'One Time';
        scheduleItem.One_Time_Datetime__c   = Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 );
        scheduleItem.Last_Successful_Run__c = null;
        scheduleItem.status__c              = 'Sleeping';
        insert scheduleItem;

        vyuha_Schedule_Item__c scheduleItem2 = new vyuha_Schedule_Item__c ();
        scheduleItem2.Vyuha_Formation__c     = formation.id;
        scheduleItem2.Frequency__c           = 'One Time';
        scheduleItem2.One_Time_Datetime__c   = Datetime.newInstance ( 2018, 10, 20, 14, 00, 00 );
        scheduleItem2.Last_Successful_Run__c = null;
        scheduleItem2.status__c              = 'Sleeping';
        insert scheduleItem2;
    }
    
    @isTest
    public static void getScheduleItemsToRun_OneTime () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 ));

        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();

        system.assertEquals ( 1, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_TooEarly () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 13, 00, 00 ));

        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();

        system.assertEquals ( 0, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_LateRun () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 14, 30, 00 ));

        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();

        system.assertEquals ( 1, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_ParentRunning () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 ));
        // update formation into Running state
        Vyuha_Formation__c formation = [ SELECT ID, Status__c FROM Vyuha_Formation__c ];
        formation.Status__c = 'Running';
        update formation;

        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();

        system.assertEquals ( 0, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_ParentInactive () {
        Map < String, Object > params = new Map < String, Object > ();
        params.put ( 'now', Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 ));
        // update formation into Running state
        Vyuha_Formation__c formation = [ SELECT ID, Active__c FROM Vyuha_Formation__c ];
        formation.Active__c = false;
        update formation;

        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();

        system.assertEquals ( 0, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_AlreadyRun () {
        Map < String, Object > params = new Map < String, Object > ();
        Datetime executionTime = Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 );
        params.put ( 'now', executionTime );
        // update scheduled item to mark a past run
        Vyuha_Schedule_Item__c schedule = [ SELECT Last_Successful_Run__c, ID FROM Vyuha_Schedule_Item__c WHERE One_Time_DateTime__c =: executionTime];
        schedule.Last_Successful_Run__c = executionTime.addDays(-1);
        update schedule;
        // set mock
        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();

        system.assertEquals ( 0, scheduleItems.size ());
    }

    @isTest
    public static void getScheduleItemsToRun_OneTime_AlreadyErrored () {
        Map < String, Object > params = new Map < String, Object > ();
        Datetime executionTime = Datetime.newInstance ( 2018, 09, 20, 14, 00, 00 );
        params.put ( 'now', executionTime );
        // update scheduled item for error in the past
        Vyuha_Schedule_Item__c schedule = [ SELECT Last_Error_Encountered__c, ID FROM Vyuha_Schedule_Item__c WHERE One_Time_DateTime__c =: executionTime];
        schedule.Last_Error_Encountered__c = executionTime.addDays(-1);
        update schedule;
        // set mock
        vy_TimeHelper mockTimeHelper = (vy_TimeHelper) Test.createStub ( vy_TimeHelper.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Scheduler scheduler = new vy_Scheduler ( mockTimeHelper );
        List < vy_ScheduleItem > scheduleItems = scheduler.getScheduleItemsToRun ();

        Test.stopTest ();
 
        system.assertEquals ( 0, scheduleItems.size ());
    }

}
