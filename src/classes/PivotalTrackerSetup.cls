public class PivotalTrackerSetup {
    public Pivotal_Tracker__c config {get; set;}
    public Boolean editMode {get; set;}

    public PivotalTrackerSetup() {
        config = Pivotal_Tracker__c.getValues('default');

        if (config == NULL) {
            config = new Pivotal_Tracker__c(Name = 'default');
        }
    }

    public void sync() {
        if (String.isNotBlank(config.API_Token__c)) {
            PivotalTrackerSync.sync();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Synchronization started'));
        }
    }

    public void save() {
        upsert config;
        edit();
    }

    public void edit() {
        editMode = editMode != true;
    }
}