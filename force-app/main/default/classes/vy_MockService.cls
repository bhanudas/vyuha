
global class vy_MockService implements System.StubProvider {

    private Map < String, Object > params;

    global vy_MockService ( Map < String, Object > params ) {
        this.params = params;
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
        }

        return null;
    }

    // vy_Formation Stubs
    private String vy_Formation_getSoqlStatement () {
        return (String) params.get ('soqlStatement');
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


}
