// Manages Data Sources defined by Formation, sent into Coordinator for Processing

public with sharing class vy_DataSource {

    private string soqlQuery;

    public vy_DataSource ( String soqlQuery ) {
        this.soqlQuery = soqlQuery;
    }

    public string generateQuery () {
        return this.soqlQuery;
    }
}
