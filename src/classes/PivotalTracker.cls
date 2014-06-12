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
}