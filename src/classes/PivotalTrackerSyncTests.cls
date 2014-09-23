@isTest
private class PivotalTrackerSyncTests {
    private static String exampleProjectResponse = '[{"id": 1026186,"kind": "project","name": "CloudAnswers Pod 1","version": 5917,"iteration_length": 1,"week_start_day": "Monday","point_scale": "0,1,2,3,5,8,13,16,21,34","point_scale_is_custom": true,"bugs_and_chores_are_estimatable": true,"automatic_planning": true,"enable_tasks": true,"time_zone": {"kind": "time_zone","olson_name": "America/New_York","offset": "-04:00"},"velocity_averaged_over": 1,"number_of_done_iterations_to_show": 12,"has_google_domain": false,"enable_incoming_emails": true,"initial_velocity": 10,"public": false,"atom_enabled": true,"start_time": "2014-02-24T05:00:00Z","created_at": "2014-02-27T20:40:00Z","updated_at": "2014-09-22T04:29:31Z","account_id": 181277,"current_iteration_number": 31,"enable_following": true}, {"id": 1127778,"kind": "project","name": "CloudAnswers Pod 2","version": 856,"iteration_length": 1,"week_start_day": "Monday","point_scale": "0,1,2,3,5,8,16","point_scale_is_custom": true,"bugs_and_chores_are_estimatable": true,"automatic_planning": true,"enable_tasks": true,"time_zone": {"kind": "time_zone","olson_name": "America/New_York","offset": "-04:00"},"velocity_averaged_over": 2,"number_of_done_iterations_to_show": 12,"has_google_domain": false,"enable_incoming_emails": true,"initial_velocity": 10,"public": false,"atom_enabled": false,"start_time": "2014-03-24T04:00:00Z","created_at": "2014-07-22T14:30:10Z","updated_at": "2014-09-22T04:31:55Z","account_id": 181277,"current_iteration_number": 27,"enable_following": true}, {"id": 1149920,"kind": "project","name": "CloudAnswers Operations","version": 14,"iteration_length": 1,"week_start_day": "Monday","point_scale": "0,1,2,3","point_scale_is_custom": false,"bugs_and_chores_are_estimatable": false,"automatic_planning": true,"enable_tasks": true,"time_zone": {"kind": "time_zone","olson_name": "America/New_York","offset": "-04:00"},"velocity_averaged_over": 3,"number_of_done_iterations_to_show": 12,"has_google_domain": false,"enable_incoming_emails": true,"initial_velocity": 10,"public": false,"atom_enabled": false,"start_time": "2014-09-22T04:00:00Z","created_at": "2014-08-20T18:54:02Z","updated_at": "2014-09-22T04:32:13Z","account_id": 181277,"current_iteration_number": 1,"enable_following": true}]';
    private static String exampleStoriesResponse = '[{"kind": "story","id": 66623784,"created_at": "2014-02-27T21:05:45Z","updated_at": "2014-02-28T02:57:51Z","accepted_at": "2014-02-27T21:06:06Z","estimate": 1,"story_type": "feature","name": "scheduled call","current_state": "accepted","requested_by_id": 173357,"project_id": 1026186,"url": "https://www.pivotaltracker.com/story/show/66623784","owner_ids": [173357],"labels": [{"id": 7838730,"project_id": 1026186,"kind": "label","name": "livestream","created_at": "2014-02-28T02:57:50Z","updated_at": "2014-02-28T02:57:50Z"}],"owned_by_id": 173357}, {"kind": "story","id": 66622582,"created_at": "2014-02-27T20:48:33Z","updated_at": "2014-03-02T02:15:58Z","accepted_at": "2014-02-28T17:00:00Z","estimate": 1,"story_type": "feature","name": "github repos cleanup","current_state": "accepted","requested_by_id": 173357,"project_id": 1026186,"url": "https://www.pivotaltracker.com/story/show/66622582","owner_ids": [173357],"labels": [{"id": 7838728,"project_id": 1026186,"kind": "label","name": "apto","created_at": "2014-02-28T02:57:17Z","updated_at": "2014-02-28T02:57:17Z"}],"owned_by_id": 173357}, {"kind": "story","id": 66622766,"created_at": "2014-02-27T20:51:03Z","updated_at": "2014-03-02T02:16:07Z","accepted_at": "2014-02-28T17:00:00Z","estimate": 2,"story_type": "feature","name": "continuous integration setup","current_state": "accepted","requested_by_id": 173357,"project_id": 1026186,"url": "https://www.pivotaltracker.com/story/show/66622766","owner_ids": [173357],"labels": [{"id": 7838728,"project_id": 1026186,"kind": "label","name": "apto","created_at": "2014-02-28T02:57:17Z","updated_at": "2014-02-28T02:57:17Z"}],"owned_by_id": 173357}]';
    @isTest static void itShouldContinueIfNotFinished() {
        PivotalTracker t = new PivotalTracker('test');
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        s.actions = new List<String>{'projects','stories'};
        // simulate that there was a recent result that was non-blank so we know there could be more records on the next page
        s.currentStoryResult = new PivotalTracker.PivotalTrackerStoryResult();
        s.currentStoryResult.stories = new PivotalTracker.PivotalTrackerStory[]{
            new PivotalTracker.PivotalTrackerStory()
        };
        s.finish(null);
        System.assertEquals(true, s.didScheduleAdditionalBatch);
    }

    @isTest static void itShouldNotContinueIfFinished() {
        PivotalTracker t = new PivotalTracker('test');
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        System.assert(s.actions.size() > 0);
        s.currentStoryResult = new PivotalTracker.PivotalTrackerStoryResult();
        s.currentStoryResult.stories = new PivotalTracker.PivotalTrackerStory[]{};
        s.finish(null);
        System.assert(s.didScheduleAdditionalBatch != true);
    }
    
    @isTest static void itShouldHaveExecuteCoverage() {
        PivotalTracker t = new PivotalTracker('test');
        t.getOverride = '[{}]';
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        s.actions.remove(s.actions.size()-1); // take off time entries because incompatible with []
        s.execute(null, s.actions);
    }

    @isTest static void itShouldEmailOnParseError() {
        PivotalTracker t = new PivotalTracker('test');
        t.getOverride = '[{X}]';
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        s.execute(null, new List<String>{'stories'});
        s.finish(null);
    }

    @isTest static void scheduleNextBatchWhenMoreProjectsToProcess() {
        PivotalTracker t = new PivotalTracker('test');
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        s.actions = new List<String>{'stories'};
        s.projectIdsToProcess = new List<Integer>{1, 2};

        // simulate blank page of stories (ie. we're done paginating) to say this project is done syncing
        s.currentStoryResult = new PivotalTracker.PivotalTrackerStoryResult();
        s.currentStoryResult.stories = new PivotalTracker.PivotalTrackerStory[]{};
        
        s.finish(null);
        System.assertEquals(true, s.didScheduleAdditionalBatch);
        System.assertEquals(new List<Integer>{2}, s.projectIdsToProcess);
    }

    @isTest static void integrationTest(){
        PivotalTracker t = new PivotalTracker('test');
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        s.start(null);
        t.getOverride = exampleProjectResponse;
        s.execute(null, new List<String>{'projects'});
        System.assertEquals(1026186, s.currentProjectId, 'should have started processing the first project');
        t.getOverride = exampleStoriesResponse;
        s.execute(null, new List<String>{'stories'});

        // finishing when we had stories returned last api call means we should schedule a new batch
        s.finish(null);
        System.assertEquals(true, s.didScheduleAdditionalBatch);
        s.didScheduleAdditionalBatch = false;

        // when we reach an empty page of stories we should assume we're done
        // and should schedule a new batch with the next project
        t.getOverride = '[]';
        s.execute(null, new List<String>{'stories'});
        s.finish(null);
        System.assertEquals(1127778, s.currentProjectId, 'should have started processing second project');
        System.assertEquals(true, s.didScheduleAdditionalBatch);
        s.didScheduleAdditionalBatch = false;

        s.execute(null, new List<String>{'stories'});
        s.finish(null);
        System.assertEquals(1149920, s.currentProjectId, 'should have started processing third (last) project');
        System.assertEquals(true, s.didScheduleAdditionalBatch);
        s.didScheduleAdditionalBatch = false;

        s.execute(null, new List<String>{'stories'});
        s.finish(null);
        System.assertEquals(false, s.didScheduleAdditionalBatch);
    }

    @isTest static void errorEmailTestCoverage() {
        PivotalTracker t = new PivotalTracker('test');
        PivotalTrackerSync s = new PivotalTrackerSync(t);
        s.errors.add('asdf');
        s.sendErrorEmail();
    }
}