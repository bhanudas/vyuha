// Test Data Factory

public class vy_TestDataFactory {
    
    public static vy_Formation createFormation ( String flowInterviewName, String flowInputVariableName, Boolean active, Integer batchSize, String soqlStatement, String notificationEmail, vy_FlowInterface flowInterface ) {
        Vyuha_Formation__c formation = new Vyuha_Formation__c ();
        formation.Flow_Interview_Name__c = flowInterviewName;
        formation.Flow_Input_Variable_Name__c = flowInputVariableName;
        formation.Active__c = active;
        formation.Batch_Size__c = batchSize;
        formation.Soql_Statement__c = soqlStatement;
        formation.Notification_Email__c = notificationEmail;
        insert formation;

        if ( flowInterface == null ) {
            flowInterface = new vy_FlowInterface ();
        }

        vy_Formation formationObj = new vy_Formation ( flowInterface );
        formationObj.load ( formation.id );
        return formationObj;
    }
}
