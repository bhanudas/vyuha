// Interface to Custom Metadata "Formation" information

public with sharing class vy_Formation {

    public vy_DataSource dataSource;

    public vy_Formation() {
        this.dataSource = new vy_DataSource ( null );
    }
}
