@isTest
private class PivotalTrackerTests {
	@isTest
    static void itShouldInitialize() {
    	new PivotalTracker('test');
    	new PivotalTracker('test', 123);
    	new PivotalTracker('test', new List<Integer>{});
    	new PivotalTracker.PivotalTrackerStory();
    	new PivotalTracker.PivotalTrackerLabel();
    	new PivotalTracker.PivotalTrackerProject();
    	new PivotalTracker.PivotalTrackerStoryResult();
    	new PivotalTracker.PivotalTrackerEpic();
    }
    @isTest
    static void togglObjectsShouldMakeSobjects() {
    	(new PivotalTracker.PivotalTrackerStory()).toSObject();
    	(new PivotalTracker.PivotalTrackerProject()).toSObject();
    }
    @isTest
    static void getMethodsShouldWorkWithEmptyLists() {
    	PivotalTracker t = new PivotalTracker('test', 123);
    	t.getOverride = '[]';
    	System.assert(t.getProject().isEmpty());
    	System.assert(t.getLabels().isEmpty());
    	t.getOverride = '{"data":[]}';
    	t.getStories();
    }
}