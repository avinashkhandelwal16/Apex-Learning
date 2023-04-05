public class AccountService {
    public static void createRelatedContact(Set<Id> accountIds) {
        List<Contact> contacts = new List<Contact>();
        for(Account account : [SELECT Id, Name FROM Account WHERE Id IN: accountIds]) {
            Contact contact = new Contact();
            contact.LastName = account.Name;
            contact.AccountID = account.Id;
            contacts.add(contact);
        }
        if(!contacts.isEmpty()) {
            insert contacts;
        }
    }
}