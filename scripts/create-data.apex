Account a = new Account ();
a.Name = 'Test';
insert a;

List < Contact > contacts = new List < Contact > ();
for ( integer x = 0; x < 1000; x++ ) {
    Contact c = new Contact ();
    c.FirstName = 'First + ' + x;
    c.LastName = 'Test';
    c.accountId = a.id;
    contacts.add ( c );
}
insert contacts;

List < Contact > contacts = [ SELECT ID, LastName FROM Contact ];
for ( Contact c : contacts ) {
    c.LastName = 'Test';
}
update contacts;