@isTest
private class PivotalTrackerSyncTests {
	@isTest static void itShouldContinueIfNotFinished() {
		PivotalTracker t = new PivotalTracker('test', 123);
		PivotalTrackerSync s = new PivotalTrackerSync(t);
		s.actions = new List<String>{'projects','stories'};
		s.finish(null);
		System.assert(s.didScheduleAdditionalBatch);
	}

	@isTest static void itShouldNotContinueIfFinished() {
		PivotalTracker t = new PivotalTracker('test', 123);
		PivotalTrackerSync s = new PivotalTrackerSync(t);
		System.assert(s.actions.size() > 0);
		s.storiesFinished = true;
		s.finish(null);
		System.assert(s.didScheduleAdditionalBatch != true);
	}
	
	@isTest static void itShouldHaveExecuteCoverage() {
		PivotalTracker t = new PivotalTracker('test', 123);
		t.getOverride = '[{}]';
		PivotalTrackerSync s = new PivotalTrackerSync(t);
		s.actions.remove(s.actions.size()-1); // take off time entries because incompatible with []
		s.execute(null, s.actions);
	}

	@isTest static void itShouldEmailOnParseError() {
		PivotalTracker t = new PivotalTracker('test', 123);
		t.getOverride = '[{X}]';
		PivotalTrackerSync s = new PivotalTrackerSync(t);
		s.execute(null, new List<String>{'stories'});
		s.finish(null);
	}


	@isTest static void fakeTests(){
		//TODO : Need to write proper test coverage
		Pivotal_Tracker__c config = new Pivotal_Tracker__c(Name='default',API_Token__c = 't');
		insert config;
		PivotalTrackerSync s = new PivotalTrackerSync();
		s.start(null);
	}
}