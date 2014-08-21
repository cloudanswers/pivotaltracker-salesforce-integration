public class PivotalTrackerSetup {
    public Pivotal_Tracker__c config{get;set;}
    
    public PivotalTrackerSetup(){
        config = Pivotal_Tracker__c.getValues('default');
        
        if(config == NULL){
            config = new Pivotal_Tracker__c(Name = 'default');
        }
    }
    
    public void sync(){
        if(String.isNotBlank(config.API_Token__c)){
            Type t = Type.forName('PivotalTrackerSync'); 
            Database.Batchable<String> batchClass = ((Database.Batchable<String>) t.newInstance());
            Database.executeBatch(batchClass,10);
        }
    }
    
    public void save(){
        upsert config;
    }
}