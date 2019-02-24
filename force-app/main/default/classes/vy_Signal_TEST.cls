
@isTest
private class vy_Signal_TEST {


    @isTest
    static void basic_create_no_action () {
        vy_Signal sig = new vy_Signal ();
        sig.formationId = '123';
        sig.scheduleItemId = '123';
        sig.apexJobId = '123';
        sig.action = '';
        sig.status = 'SLEEPING';
        sig.message = 'Test';
        sig.initialize ();
        system.assertEquals ( true, sig.isValid ());
    }

    @isTest
    static void basic_create_no_status () {
        vy_Signal sig = new vy_Signal ();
        sig.formationId = '123';
        sig.scheduleItemId = '123';
        sig.apexJobId = '123';
        sig.action = 'START';
        sig.status = '';
        sig.message = 'Test';
        sig.initialize ();
        system.assertEquals ( true, sig.isValid ());
    }

    @isTest
    static void basic_create_action_error () {
        vy_Signal sig = new vy_Signal ();
        sig.formationId = '123';
        sig.scheduleItemId = '123';
        sig.apexJobId = '123';
        sig.action = 'CREATE-ERROR';
        sig.status = '';
        sig.message = 'Test';
        sig.initialize ();
        system.assertEquals ( false, sig.isValid ());
    }

    @isTest
    static void basic_create_status_error () {
        vy_Signal sig = new vy_Signal ();
        sig.formationId = '123';
        sig.scheduleItemId = '123';
        sig.apexJobId = '123';
        sig.action = '';
        sig.status = 'CREATE-ERROR';
        sig.message = 'Test';
        sig.initialize ();
        system.assertEquals ( false, sig.isValid ());
    }

    @isTest
    static void create_from_json () {
        string jsonStr = '{"formationId":"123","scheduleItemId":"123","apexJobId":"123","action":"START"}';
        vy_Signal sig = (vy_Signal) JSON.deserialize ( jsonStr, vy_Signal.class );
        sig.initialize ();
        system.assertEquals ( true, sig.isValid ());
    }

    @isTest
    static void basic_put () {
        vy_Signal sig = new vy_Signal ();
        sig.formationId = '123';
        sig.status = 'TEST';
        sig.initialize ();

        Test.startTest ();
        sig.put ();
        Test.stopTest ();        
    }

    @isTest
    static void create_processor_status () {

        // create formation
        vy_Formation formation = vy_TestDataFactory.createFormation ( 'testflow', 'id', true, 200, 'SELECT ID FROM Contact', 'test@test.com', null );
        ID formationId = formation.getId ();

        vy_Processor processor = new vy_Processor ( formation );

        Test.startTest ();
        vy_Signal.create ( processor, vy_Signal.Vyuha_Status.SLEEPING, 'going to sleep' );
        Test.stopTest ();

        // reload formation
        formation = new vy_Formation ( new vy_FlowInterface ());
        formation.load ( formationid );
        System.assertEquals ( 'SLEEPING', formation.getStatus ());

    }

    @isTest
    static void create_formation_status () {

        // create formation
        vy_Formation formation = vy_TestDataFactory.createFormation ( 'testflow', 'id', true, 200, 'SELECT ID FROM Contact', 'test@test.com', null );
        ID formationId = formation.getId ();

        Test.startTest ();
        vy_Signal.create ( formation, vy_Signal.Vyuha_Status.SLEEPING, 'going to sleep' );
        Test.stopTest ();

        // reload formation
        formation = new vy_Formation ( new vy_FlowInterface ());
        formation.load ( formationid );
        System.assertEquals ( 'SLEEPING', formation.getStatus ());

    }

    @isTest
    static void create_scheduleItem_status () {

        // create formation
        vy_Formation formation = vy_TestDataFactory.createFormation ( 'testflow', 'id', true, 200, 'SELECT ID FROM Contact', 'test@test.com', null );
        vy_ScheduleItem scheduleItem = vy_TestDataFactory.createScheduleItem ( formation, DateTime.now ().addDays (-1), 'One Time' );
        ID scheduleItemId = scheduleItem.getId ();

        Test.startTest ();
        vy_Signal.create ( scheduleItem, vy_Signal.Vyuha_Status.SLEEPING, 'going to sleep' );
        Test.stopTest ();

        // reload scheduleItem
        scheduleItem = new vy_ScheduleItem ( formation );
        scheduleItem.load ( scheduleItemId );
        System.assertEquals ( 'SLEEPING', scheduleItem.getStatus ());

    }

    @isTest
    static void action_start_formation () {
        vy_Formation formation = vy_TestDataFactory.createFormation ( 'testflow', 'id', true, 200, 'SELECT ID FROM Contact', 'test@test.com', null );
        ID formationId = formation.getId ();
        vy_MockService.Parameters params = new vy_MockService.Parameters ();
        params.put ( 'isValid', true );
        params.put ( 'isRunning', false );
        params.put ( 'isRunnable', true );
        params.put ( 'formation', formation );
        vy_Formation mockFormation = (vy_Formation) Test.createStub ( vy_Formation.class, new vy_MockService ( params ));

        Test.startTest ();
        vy_Signal sig = new vy_Signal ( mockFormation, vy_Signal.Vyuha_Status.STARTING, null );
        sig.vAction = vy_Signal.Vyuha_Action.START;
        sig.vStatus = null;  // override the status so it doesn't bug out
        sig.status = null;
        sig.initialize ();
        sig.process ();
        Test.stopTest ();

        // check that formation is starting
        // reload formation
        formation = new vy_Formation ( new vy_FlowInterface ());
        formation.load ( formationid );
        System.assertEquals ( 'STARTING', formation.getStatus ());

    }

}
