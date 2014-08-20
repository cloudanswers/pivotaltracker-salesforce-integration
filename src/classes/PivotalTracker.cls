public with sharing class PivotalTracker {

    private String apiToken;
    private Integer projectId;

    public PivotalTracker(String apiToken, Integer projectId) {
        this.apiToken = apiToken;
        this.projectId = projectId;
    }

    public List<PivotalTrackerStory> getStories() {
        return (List<PivotalTrackerStory>)JSON.deserialize(
            get('https://www.pivotaltracker.com/services/v5/projects/'+projectId+'/stories'), 
            List<PivotalTrackerStory>.class
        );
    }
    

    public List<PivotalTrackerLabel> getLabels(){
        return (List<PivotalTrackerLabel>) JSON.deserialize(
            get('https://www.pivotaltracker.com/services/v5/projects/'+projectId+'/labels'),
            List<PivotalTrackerLabel>.class
            );
    }

    public List<PivotalTrackerProject> getProject(){
        return (List<PivotalTrackerProject>)JSON.deserialize(
            get('https://www.pivotaltracker.com/services/v5/projects'+projectId),
            List<PivotalTrackerProject>.class
        );
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
        return res.getBody();
    }

    // deserialization classes

    public class PivotalTrackerStory {
        public String kind;
        public Integer id;
        public Double created_at;
        public Double updated_at;
        public String story_type;
        public String name;
        public String description;
        public String current_state;
        public Integer requested_by_id;
        public Integer project_id;
        public String url;
        public List<String> owner_ids;
        public list<PivotalTrackerLabel> labels;
    }

    public class PivotalTrackerLabel {
        public Integer id;
        public Integer project_id;
        public String kind;
        public String name;
        public Double created_at;
        public Double updated_at;
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
        public String time_zone;
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