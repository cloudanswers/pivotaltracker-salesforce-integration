public with sharing class PivotalTrackerSyncScheduler implements Schedulable{
	public String apiToken;

	public void execute(SchedulableContext ctx){
		Type t = Type.forName('PivotalTrackerSync'); 
        Database.Batchable<String> batchClass = ((Database.Batchable<String>) t.newInstance());
        Database.executeBatch(batchClass,10);
	}
}