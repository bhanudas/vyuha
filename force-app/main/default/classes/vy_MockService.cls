@isTest
global class vy_MockService implements System.StubProvider {

    private Map < String, Object > params;
    private vy_Formation formation;

    global vy_MockService ( vy_Formation formation, Map < String, Object > params ) {
        this.params = params;
        this.formation = formation;
    }

    global Object handleMethodCall ( Object stubbedObject, String stubbedMethodName, Type returnType, List < Type > listOfParamTypes, List < String > listOfParamNames, List < Object > listOfArgs ) {
        system.debug ( 'vy_MockService.handleMethodCall ( ' + stubbedMethodName + ') ' + stubbedObject ); 

        if ( stubbedObject instanceof vy_Formation ) {
            if ( stubbedMethodName == 'getSoqlStatement' ) {
                system.debug ( 'vy_MockService - vy_Formation - getSoqlStatement ' + params );
                return vy_Formation_getSoqlStatement ();
            }
            if ( stubbedMethodName == 'isValid' ) {
                system.debug ( 'vy_MockService - vy_Formation - isValid ' + params );
                return vy_Formation_getSoqlStatement ();
            }
            if ( stubbedMethodName == 'load' ) {
                system.debug ( 'vy_MockService - vy_Formation - load ' + params );
                return vy_Formation_load ();
            }
            if ( stubbedMethodName == 'executeFlow' ) {
                system.debug ( 'vy_MockService - vy_Formation - executeFlow ' + params );
                return vy_Formation_executeFlow ();
            }
            if ( stubbedMethodName == 'getScheduledHours' ) {
                system.debug ( 'vy_MockService - vy_Formation - getScheduledHours ' + params );
                return vy_Formation_getScheduledHours ();
            }
            if ( stubbedMethodName == 'getScheduledDate' ) {
                system.debug ( 'vy_MockService - vy_Formation - getScheduledDate ' + params );
                return vy_Formation_getScheduledDate ();
            }
            if ( stubbedMethodName == 'getBatchSize' ) {
                system.debug ( 'vy_MockService - vy_Formation - getBatchSize ' + params );
                return vy_Formation_getBatchSize ();
            }
            if ( stubbedMethodName == 'getActiveFormations' ) {
                system.debug ( 'vy_MockService - vy_Formation - getActiveFormations ' + params );
                return vy_Formation_getActiveFormations ();
            }
        }

        return null;
    }

    // vy_Formation Stubs
    private String vy_Formation_getSoqlStatement () {
        return formation.getSoqlStatement ();
    }

    private Boolean vy_Formation_isValid () {
        return (Boolean) params.get ('isValid');
    }

    private Boolean vy_Formation_load () {
        return (Boolean) params.get ('loadResult');
    }

    private Boolean vy_Formation_executeFlow () {
        return (Boolean) params.get ('executeFlowResult');
    }

    private Set < string > vy_Formation_getScheduledHours () {
        
        return this.formation.scheduledHours;
    }

    private Date vy_Formation_getScheduledDate () {
        // when stubbing the date, we need to push this out a year so scheduled jobs are after Now()
        return Date.today ().addYears ( 1 );
    }

    private integer vy_Formation_getBatchSize () {
        
        return this.formation.getBatchSize ();
    }

    private List < vy_Formation > vy_Formation_getActiveFormations () {
        
        List < vy_Formation > formations = new List < vy_Formation > ();
        formations.add ( this.formation );
        return formations;
    }


}
