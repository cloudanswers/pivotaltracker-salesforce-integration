global with sharing class PivotalTracker {
    public String apiToken;
    public Boolean isAllProjectSync = false;
    public List<Integer> projectIds;

    private static final integer STORY_LIMIT = 200;
    private Integer projectId;
    private Integer index = 0;

    //sync all the projects along with time enteries
    public PivotalTracker(String apiToken) {
        this.apiToken = apiToken;
        isAllProjectSync = true;
    }


    public PivotalTracker(String apiToken, Integer projectId) {
        this.apiToken = apiToken;
        this.projectIds = new List<Integer>{projectId};
        next();
    }

    public PivotalTracker(String apiToken,List<Integer> projectIds){
        this.apiToken = apiToken;
        this.projectIds = projectIds;
        next();
    }

    public PivotalTrackerStoryResult getStories() {
        PivotalTrackerStoryResult res = new PivotalTrackerStoryResult();
        res.projectId = this.projectId;
        res.tracker =this;
        return res.next();
    }
    

    public List<PivotalTrackerLabel> getLabels(){
        return (List<PivotalTrackerLabel>) JSON.deserialize(
            get('https://www.pivotaltracker.com/services/v5/projects/'+projectId+'/labels'),
            List<PivotalTrackerLabel>.class
            );
    }

    public List<PivotalTrackerProject> getProject(){
        return (List<PivotalTrackerProject>)JSON.deserialize(
            get('https://www.pivotaltracker.com/services/v5/projects'),
            List<PivotalTrackerProject>.class
        );
    }

    public Boolean isSyncAll(){
        return isAllProjectSync;
    }

    public Boolean hasNext(){
        return (index < projectIds.size());
    }

    public void next(){
        if(hasNext()){
            projectId = projectIds[index];
            index++;
        }

    }


    // helpers

    private class HttpException extends Exception {}

    @TestVisible
    private String getOverride;

    private String get(String url) {
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('X-TrackerToken', this.apiToken);
        req.setEndpoint(url);
        Http h = new Http();
        if (getOverride != null) {
            return getOverride;
        }
        HttpResponse res = h.send(req);
        if (res.getStatusCode() != 200) {
            throw new HttpException('Invalid status code ' + res.getStatusCode() + ' for ' + url);
        }
        System.debug(res.getBody());
        return res.getBody();
    }

    // deserialization classes

    public class PivotalTrackerStory {
        public String kind;
        public Integer id;
        public DateTime created_at;
        public DateTime updated_at;
        public DateTime accepted_at;
        public Integer estimate;
        public String story_type;
        public String name;
        public String description;
        public String current_state;
        public Integer requested_by_id;
        public Integer project_id;
        public String url;
        public List<Integer> owner_ids;
        public List<PivotalTrackerLabel> labels;
        public Integer owned_by_id;

        public Pivotal_Story__c toSobject(){
            String labels ='';
            for(PivotalTrackerLabel l : this.labels){
                labels = (labels =='' ? '' :labels +  ',')+l.name;
            }
            return new Pivotal_Story__c(
                        Accepted_at__c = this.accepted_at,
                        Created_At__c = this.created_at,
                        Updated_At__c = this.updated_at,
                        Current_State__c = this.current_state,
                        Description__c = this.description,
                        Estimate__c = this.estimate,
                        Project_Id__c = this.project_id,
                        Story_Type__c = this.story_type,
                        Name = this.name,
                        Kind__c = this.kind,
                        Story_Id__c = this.id,
                        Story_URL__c = this.url,
                        Name__c = this.name,
                        Pivotal_Project__r = new Pivotal_Project__c(Project_Id__c = this.project_id),
                        Labels__c = labels
                    );
        }

    }

    public class PivotalTrackerStoryResult{
        public List<PivotalTrackerStory> stories;
        //variable for maintaining state
        public Integer offset = 0;
        public PivotalTracker tracker;
        public Integer projectId;


        public PivotalTrackerStoryResult next() {
            stories = (List<PivotalTrackerStory>)JSON.deserialize(
                            tracker.get('https://www.pivotaltracker.com/services/v5/projects/'+projectId+'/stories?limit='+STORY_LIMIT+'&offset='+offset), 
                            List<PivotalTrackerStory>.class
                        );
            offset = offset + STORY_LIMIT;

            return this;
        }
    }

    public class PivotalTrackerLabel {
        public Integer id;
        public Integer project_id;
        public String kind;
        public String name;
        public DateTime created_at;
        public DateTime updated_at;
    }
    
    public class PivotalTrackerProject{
        public Integer id;
        public String name;
        public Integer version;
        public Integer iteration_length;
        public String week_start_day;
        public String point_scale;
        public Boolean point_scale_is_custom;
        public Boolean bugs_and_chores_are_estimatable;
        public Boolean automatic_planning;
        public Boolean enable_tasks;
        public Date start_date;
        public Integer velocity_averaged_over;
        public DateTime shown_iterations_start_time;
        public DateTime start_time;
        public Integer number_of_done_iterations_to_show;
        public Boolean has_google_domain;
        public String description;
        public String profile_content;
        public Boolean enable_incoming_emails;
        public Integer initial_velocity;
        public Boolean blnPublic;
        public Boolean atom_enabled;
        public Integer current_iteration_number;
        public Integer current_velocity;
        public Integer account_id;
        public List<PivotalTrackerStory> stories; //story_ids
        public List<PivotalTrackerEpic> epics ; //epic_ids;
        public List<Integer> membership_ids;
        public List<PivotalTrackerLabel> labels; //label_ids
        public List<Integer> integration_ids;
        public List<Integer> iteration_override_numbers;
        public Datetime created_at;
        public DateTime updated_at;
        public String kind;      

        public Pivotal_Project__c toSobject(){
            return new Pivotal_Project__c(
                Project_Id__c = this.id,
                Name = this.name,
                Version__c  = this.version,
                Iteration_Length__c = this.iteration_length,
                Week_Start_Day__c = this.week_start_day,
                Point_Scale__c = this.point_scale,
                Point_Scale_Is_Custom__c = this.point_scale_is_custom,
                Bugs_and_Chores_are_Estimatable__c = this.bugs_and_chores_are_estimatable,
                Automatic_Planning__c = this.automatic_planning,
                Enable_Tasks__c = this.enable_tasks,
                Start_Date__c = this.start_date,
                //Time_Zone__c = this.time_zone,
                Velocity_Averaged_Over__c = this.velocity_averaged_over,
                Shown_Iterations_Start_Time__c = this.shown_iterations_start_time,
                Start_Time__c = this.start_time,
                Number_of_Done_Iterations_to_Show__c = this.number_of_done_iterations_to_show,
                Has_Google_Domain__c = this.has_google_domain,
                Description__c = this.description,
                Profile_Content__c = this.profile_content,
                Enable_Incoming_Emails__c = this.enable_incoming_emails,
                Initial_velocity__c = this.initial_velocity,
                Current_Iteration_Number__c = this.current_iteration_number,
                Current_Velocity__c = this.current_velocity
            );
        } 
    }

    public class PivotalTrackerEpic{
        public Integer id;
        public Integer project_id;
        public String name;
        public Integer label_id;
        public String description;
        public List<Integer> comment_ids;
        public List<Integer> follower_ids; //Beta in v5
        public DateTime created_at;
        public DateTime updated_at;
        public Integer after_id;
        public Integer before_id;
        public String strUrl;
        public String kind;
    }
   
}