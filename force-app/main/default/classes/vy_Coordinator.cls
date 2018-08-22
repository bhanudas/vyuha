// Coordinator
// Container for Batchable control

global with sharing class vy_Coordinator implements Database.Batchable < sobject >, Database.Stateful {

    global vy_Coordinator() {

    }

    global Database.QueryLocator start ( Database.BatchableContext batchContext ) {

		return null;
	}

	global void execute ( Database.BatchableContext batchContext, List < sObject > listToProcess ) {

	}

	global void finish ( Database.BatchableContext batchContext ) {


	}
}
