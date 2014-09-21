@isTest
private class PivotalTrackerSetupTests {
	@isTest static void shouldAutomaticallyCreateNewConfig() {
		PivotalTrackerSetup controller = new PivotalTrackerSetup();
		System.assert(controller.config != null);
		controller.config.API_Token__c = 'XXX';
		controller.save();
		System.assert(controller.config.Id != null);
	}
	
	@isTest static void shouldStartBatch() {
		PivotalTrackerSetup controller = new PivotalTrackerSetup();
		controller.sync();
		// TODO assert
	}
}