public with sharing class PivotalTrackerSyncScheduler implements Schedulable{
	public void execute(SchedulableContext ctx){
		PivotalTrackerSync.sync();
	}
}