public with sharing class PivotalTrackerSyncScheduler implements Schedulable{
	public String apiToken;

	public void execute(SchedulableContext ctx){
		PivotalTracker tracker = new PivotalTracker(apiToken);
		PivotalTrackerSync p = new PivotalTrackerSync(tracker);
		Database.executeBatch(p, 10);
	}
}