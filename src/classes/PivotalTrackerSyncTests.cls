@isTest
private class PivotalTrackerSyncTests {
	@isTest static void itShouldContinueIfNotFinished() {
		PivotalTracker t = new PivotalTracker('test', 123);
		PivotalTrackerSync s = new PivotalTrackerSync(t);
		s.actions = new List<String>{'time_entries'};
		s.finish(null);
		System.assert(s.didScheduleAdditionalBatch);
	}

	@isTest static void itShouldNotContinueIfFinished() {
		PivotalTracker t = new PivotalTracker('test', 123);
		PivotalTrackerSync s = new PivotalTrackerSync(t);
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
		t.getOverride = '[{}]';
		PivotalTrackerSync s = new PivotalTrackerSync(t);
		s.execute(null, new List<String>{'time_entries'});
		s.finish(null);
	}
}