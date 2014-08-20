global with sharing class PivotalTrackerSync implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
	public List<String> actions = new List<String>{
        'projects',
        'stories'
    };

    private Database.DMLOptions dmo;
    private PivotalTracker tracker;
    private Boolean storiesFinished = false;
    @TestVisible
    private Boolean didScheduleAdditionalBatch;

    private PivotalTracker.PivotalTrackerStoryResult currentStoryResult;
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
    	processScope(scope);
    	processUpsertResults(stories, Database.upsert(stories, Pivotal_Story__c.Story_Id__c, false));
    }

    global void finish(Database.BatchableContext BC) {
    	if (storiesFinished || actions.size() >= 50) {
            sendErrorEmail();
        } else {
            PivotalTrackerSync p = new PivotalTrackerSync(tracker);
            p.actions = actions.clone();
            // remove the sync actions not related to the time entries
            // because only stories can be continued
            while (p.actions.get(0) != 'stories') {
                p.actions.remove(0);
            }
            // double the number of time entries that we want to process for next time
            p.actions.addAll(actions);
            p.currentStoryResult = currentStoryResult;
            p.errors = errors;

            if (Test.isRunningTest()) {
                didScheduleAdditionalBatch = true;
            } else {
                // WARNING should only do batch size of 10 so we stay under 
                // the per transaction govorner for callouts
                Database.executeBatch(p, 10);
            }
        }
    }

    private void sendErrorEmail() {
    	// if we have errors, stop scheduling new ones
        if (!errors.isEmpty()) {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});
            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName('Pivotal Salesforce Sync');
            mail.setSubject('Pivotal Salesforce Sync Errors');
            String body = 'Errors: ';
            for (String e : errors) {
                body += '\n - ' + e;
            }
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            return;
        }
    }

    private void processScope(List<String> scope) {
    	projects.clear();
    	stories.clear();
    	for (String s : scope) {
    		if(s == 'projects'){

    		}
    		else{
    			if(currentStoryResult == NULL){
    				currentStoryResult = tracker.getStories();
    			}

    			for(PivotalTracker.PivotalTrackerStory p : currentStoryResult.stories){
    				stories.add(p.toSobject());
    			}

    			storiesFinished = stories.isEmpty();
    		}
    	}
    }

    private void processUpsertResults(List<SObject> sobjs, List<Database.UpsertResult> upsertResults) {
        for (Integer i=0; i<upsertResults.size(); i++) {
            if (!upsertResults[i].isSuccess()) {
                errors.add('' + sobjs[i] + ' => ' + upsertResults[i].getErrors());
            }
        }
    }
}