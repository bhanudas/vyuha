
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
}
