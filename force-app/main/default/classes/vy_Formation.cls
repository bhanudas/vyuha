// Interface to Custom Metadata "Formation" information

global with sharing class vy_Formation {

    private vy_DataSource dataSource;

    global vy_Formation() {
        this.dataSource = new vy_DataSource ( null );
    }
}
