// Coordinator
// Container for Batchable control

global with sharing class vy_Coordinator implements Database.Batchable < sobject >, Database.Stateful {

    private vy_Formation formation;

    global vy_Coordinator ( vy_Formation formation ) {
        this.formation = formation;
    }

    global Database.QueryLocator start ( Database.BatchableContext batchContext ) {

		return null;
	}

	global void execute ( Database.BatchableContext batchContext, List < sObject > listToProcess ) {

        vy_WorkFactory workFactory = new vy_WorkFactory ( this.formation, listToProcess );
        workFactory.execute ();

	}

	global void finish ( Database.BatchableContext batchContext ) {


	}
}
