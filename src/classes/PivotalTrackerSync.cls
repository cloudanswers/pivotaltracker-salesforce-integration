global with sharing class PivotalTrackerSync implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    public List<String> actions;
    public List<String> errors = new List<String>();

    private Database.DMLOptions dmo;
    private PivotalTracker tracker;

    @TestVisible
    private Boolean storiesFinished = false;
    @TestVisible
    private Boolean didScheduleAdditionalBatch;

    // state for stories downloads since they are paginated
    @TestVisible
    private PivotalTracker.PivotalTrackerStoryResult currentStoryResult;
    @TestVisible
    private List<Integer> projectIdsToProcess = new List<Integer>();
    @TestVisible
    private Integer currentProjectId;

    private List<Pivotal_Project__c> projects = new List<Pivotal_Project__c>();
    private List<Pivotal_Story__c> stories = new List<Pivotal_Story__c>();
    private Map<Integer, String> personMap = new Map<Integer, String>();

    global PivotalTrackerSync() {
        // currently only supporting one pivotaltracker token
        // but setting is list so we can handle more if we need in the future
        Pivotal_Tracker__c config = Pivotal_Tracker__c.getValues('default');
        if (config != NULL) {
            this.tracker = new PivotalTracker(config.API_Token__c);
            init();
        } else {
            return;
        }
    }

    global PivotalTrackerSync(PivotalTracker tracker) {
        this.tracker = tracker;
        init();
    }

    global List<String> start(Database.BatchableContext BC) {
        return actions;
    }

    global void execute(Database.BatchableContext BC, List<String> scope) {
        try {
            processScope(scope);
            processUpsertResults(stories, Database.upsert(stories, Pivotal_Story__c.Story_Id__c, false));
            processUpsertResults(projects, Database.upsert(projects, Pivotal_Project__c.Project_Id__c, false));
        } catch (Exception e) {
            errors.add(e.getMessage() + ' => ' + e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC) {

        // this should detect run-away, but it seems like it looks like we should use !storiesFinished instead
        //if ((storiesFinished || actions.size() >= 50) && tracker.hasNext() == false) {
        //    sendErrorEmail();
        //    return;
        //}

        // not done syncing stories for this project,
        // resubmit this batch to sync more stories
        if (currentStoryResult != null && !currentStoryResult.stories.isEmpty()) {
            Integer oldActionsSize = actions.size();
            actions.clear();
            while (actions.size() < oldActionsSize * 2) {
                actions.add('stories');
            }
            didScheduleAdditionalBatch = true;
            if (!Test.isRunningTest()) {
                Database.executeBatch(this, 10);
            }
            return;
        }

        // done syncing this project, schedule next batch with next project
        if (currentStoryResult != null && currentStoryResult.stories.isEmpty() && !projectIdsToProcess.isEmpty()) {
            currentProjectId = projectIdsToProcess.remove(0);
            currentStoryResult = null;
            actions.add('persons');
            while (actions.size() < 20) {
                actions.add('stories');
            }
            didScheduleAdditionalBatch = true;
            if (!Test.isRunningTest()) {
                Database.executeBatch(this, 10);
            }
            return;
        }
    }

    public static void sync() {
        Pivotal_Tracker__c config = Pivotal_Tracker__c.getValues('default');
        if (config != NULL) {
            Type t = Type.forName('PivotalTrackerSync');
            Database.Batchable<String> batchClass = ((Database.Batchable<String>) t.newInstance());
            Database.executeBatch(batchClass, 10);
        }
    }

    private void init() {
        dmo = new Database.DMLOptions();
        dmo.allowFieldTruncation = true;
        actions = new List<String>();
        actions.add('projects');
        actions.add('persons');
        actions.add('stories');
        // pad with a realistic number of stories
        while (actions.size() < 20) {
            actions.add('stories');
        }
    }

    @TestVisible
    private void sendErrorEmail() {
        // if we have errors, stop scheduling new ones
        if (!errors.isEmpty()) {
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String> {UserInfo.getUserEmail()});
            mail.setReplyTo(UserInfo.getUserEmail());
            mail.setSenderDisplayName('Pivotal Salesforce Sync');
            mail.setSubject('Pivotal Salesforce Sync Errors');
            String body = 'Errors: ';
            System.debug('XXXXXXX:' + errors);
            for (String e : errors) {
                body += '\n - ' + e;
            }
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail});
            return;
        }
    }

    private void processScope(List<String> scope) {
        projects.clear();
        stories.clear();
        for (String s : scope) {
            if (s == 'persons') {
                for (PivotalTracker.PivotalTrackerMembership ptm : tracker.getProjectMemberships(currentProjectId)) {
                    personMap.put(ptm.person.id, ptm.person.name);
                }
            } else if (s == 'projects') {
                for (PivotalTracker.PivotalTrackerProject ptp : tracker.getProjects()) {
                    Pivotal_Project__c pp = ptp.toSobject();
                    pp.setOptions(dmo);
                    projectIdsToProcess.add(Integer.valueOf(pp.Project_Id__c));
                    projects.add(pp);
                }
                // set first project to process
                if (!projectIdsToProcess.isEmpty()) {
                    currentProjectId = projectIdsToProcess.remove(0);
                }
            } else if (s == 'stories') {
                if (currentStoryResult == NULL) {
                    currentStoryResult = tracker.getStories(currentProjectId);
                } else {
                    currentStoryResult = currentStoryResult.next();
                }

                for (PivotalTracker.PivotalTrackerStory p : currentStoryResult.stories) {
                    Pivotal_Story__c ps = p.toSobject();
                    ps.Owners__c = getOwners(p);
                    ps.setOptions(dmo);
                    stories.add(ps);
                }
            }
        }
    }

    private String getOwners(PivotalTracker.PivotalTrackerStory p) {
        String s = '';
        for (Integer i : p.owner_ids) {
            s = (s == '' ? '' : s +  ',') + (personMap.containsKey(i) ? personMap.get(i) : String.valueOf(i));
        }

        return s;
    }

    private void processUpsertResults(List<SObject> sobjs, List<Database.UpsertResult> upsertResults) {
        for (Integer i = 0; i < upsertResults.size(); i++) {
            if (!upsertResults[i].isSuccess()) {
                errors.add('' + sobjs[i] + ' => ' + upsertResults[i].getErrors());
            }
        }
    }
}