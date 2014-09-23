global with sharing class PivotalTrackerSync implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
	public List<String> actions;
    public List<String> errors = new List<String>();

    private Database.DMLOptions dmo;
    private PivotalTracker tracker;
    @TestVisible
    private Boolean storiesFinished = false;
    @TestVisible
    private Boolean didScheduleAdditionalBatch;

    private PivotalTracker.PivotalTrackerStoryResult currentStoryResult;
    private List<Pivotal_Project__c> projects = new List<Pivotal_Project__c>();
    private List<Pivotal_Story__c> stories = new List<Pivotal_Story__c>();
    private Map<Integer,String> personMap = new Map<Integer,String>();



    global PivotalTrackerSync(){
        // currently only supporting one pivotaltracker token
        // but setting is list so we can handle more if we need in the future
        Pivotal_Tracker__c config = Pivotal_Tracker__c.getValues('default');
        if(config != NULL){
            this.tracker = new PivotalTracker(config.API_Token__c);
            init();
        } else{
            return;
        }
    }

    global PivotalTrackerSync(PivotalTracker tracker) {       
        this.tracker = tracker;
        init();
    }

    global List<String> start(Database.BatchableContext BC) {
        while (actions.size() < 10) {
            actions.add(actions[actions.size()-1]);
        }
        return actions;
    }

    global void execute(Database.BatchableContext BC, List<String> scope) {
    	try {
            processScope(scope);
        	processUpsertResults(stories, Database.upsert(stories, Pivotal_Story__c.Story_Id__c, false));
        	processUpsertResults(projects, Database.upsert(projects, Pivotal_Project__c.Project_Id__c, false));
        }
        catch (Exception e) {
            errors.add(e.getMessage() + ' => ' + e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {
    	if ((storiesFinished || actions.size() >= 50) && tracker.hasNext() == false) {
            sendErrorEmail();
        } 
        else {
            if(tracker.hasNext()){
            	tracker.next();
            	currentStoryResult = null;
            }

            PivotalTrackerSync p = new PivotalTrackerSync(tracker);
            p.actions = actions.clone();
            // remove the sync actions not related to the time entries
            // because only stories can be continued
            while (p.actions.get(0) != 'stories') {
                p.actions.remove(0);
            }
            //if its a new project fetch persons
            if(currentStoryResult == null){
                List<String> actionsNew = new List<String>{'persons'};
                actionsNew.addAll(p.actions);
                p.actions = actionsNew;
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

    public static void sync(){
        Pivotal_Tracker__c config = Pivotal_Tracker__c.getValues('default');
        if(config != NULL){
            Type t = Type.forName('PivotalTrackerSync'); 
            Database.Batchable<String> batchClass = ((Database.Batchable<String>) t.newInstance());
            Database.executeBatch(batchClass,10);
        }
    }

    private void init(){
    	dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = true;
        actions = new List<String>();
    	if(tracker.isSyncAll()){
    		actions.add('projects');
    	}
        actions.add('persons');
    	actions.add('stories');
    
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
            System.debug('XXXXXXX:'+errors);
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
    		if(s == 'persons'){
                for(PivotalTracker.PivotalTrackerMembership ptm : tracker.getProjectMemberships()){
                    personMap.put(ptm.person.id,ptm.person.name);
                }
            }
            else if(s == 'projects'){
    			List<Integer> projectids = new List<Integer>();
                //fetch all the projects
    			for(PivotalTracker.PivotalTrackerProject ptp : tracker.getProjects()){
    				Pivotal_Project__c pp = ptp.toSobject();
    				pp.setOptions(dmo);
    				projectids.add(Integer.valueOf(pp.Project_Id__c));
    				projects.add(pp);
    			}
    			tracker.projectIds = projectIds;
                //move pointer to first project
    			tracker.next();
    		}
    		else{
    			if(currentStoryResult == NULL){
    				currentStoryResult = tracker.getStories();
    			}
    			else{
    				currentStoryResult = currentStoryResult.next();
    			}

    			for(PivotalTracker.PivotalTrackerStory p : currentStoryResult.stories){
    				Pivotal_Story__c ps = p.toSobject();
                    ps.Owners__c = getOwners(p);
    				ps.setOptions(dmo);
    				stories.add(ps);
    			}

    			storiesFinished = stories.isEmpty();
    		}
    	}
    }

    private String getOwners(PivotalTracker.PivotalTrackerStory p){
        String s='';
        for(Integer i : p.owner_ids){
            s = (s =='' ? '' :s +  ',')+ (personMap.containsKey(i) ? personMap.get(i) : String.valueOf(i));
        }

        return s;
    }

    private void processUpsertResults(List<SObject> sobjs, List<Database.UpsertResult> upsertResults) {
        for (Integer i=0; i<upsertResults.size(); i++) {
            if (!upsertResults[i].isSuccess()) {
                errors.add('' + sobjs[i] + ' => ' + upsertResults[i].getErrors());
            }
        }
    }
}