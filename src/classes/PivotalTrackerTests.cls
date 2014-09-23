@isTest
private class PivotalTrackerTests {
	@isTest
    static void itShouldInitialize() {
    	new PivotalTracker('test');
    	new PivotalTracker.PivotalTrackerStory();
    	new PivotalTracker.PivotalTrackerLabel();
    	new PivotalTracker.PivotalTrackerProject();
    	new PivotalTracker.PivotalTrackerStoryResult();
    	new PivotalTracker.PivotalTrackerEpic();
        new PivotalTracker.PivotalTrackerMembership();
        new PivotalTracker.PivotalTrackerPerson();
    }
    @isTest
    static void togglObjectsShouldMakeSobjects() {
    	(new PivotalTracker.PivotalTrackerStory()).toSObject();
    	(new PivotalTracker.PivotalTrackerProject()).toSObject();
    }
    @isTest
    static void getMethodsShouldWorkWithEmptyLists() {
    	PivotalTracker t = new PivotalTracker('test');
    	t.getOverride = '[]';
    	System.assert(t.getProjects().isEmpty());
    	System.assert(t.getLabels(1).isEmpty());
    	System.assert(t.getStories(1).stories.isEmpty());
    }
}