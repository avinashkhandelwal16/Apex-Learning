public class ContactSearch {
    public static List<contact> searchForContacts(String lastName,String  postalCode){
    List<Contact> Contacts = [select Id,Name from Contact where LastName =:lastName and MailingPostalCode =: postalCode];
    return Contacts;
    }
}