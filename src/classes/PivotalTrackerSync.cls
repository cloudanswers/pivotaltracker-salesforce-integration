global with sharing class PivotalTrackerSync {
	public List<String> actions = new List<String>{
        'projects',
        'stories'
    };

    private Database.DMLOptions dmo;
    private PivotalTracker tracker;
    private List<Pivotal_Project__c> projects = new List<Pivotal_Project__c>();
    private List<Pivotal_Story__c> stories = new List<Pivotal_Story__c>();
    public List<String> errors = new List<String>();

    global PivotalTrackerSync(PivotalTracker tracker) {
        dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = true;
        this.tracker = tracker;
    }

    global List<String> start(Database.BatchableContext BC) {
        while (actions.size() < 10) {
            actions.add(actions[actions.size()-1]);
        }
        return actions;
    }

    global void execute(Database.BatchableContext BC, List<String> scope) {


    }

    global void finish(Database.BatchableContext BC) {

    }

    private void sendErrorEmail() {

    }

    private void processScope(List<String> scope) {

    }

    private void processUpsertResults(){
    	
    }
}