public class ContactAndLeadSearch {
    public static List<List<sObject>> searchContactsAndLeads(String newString){
      List<List<sObject>> searchList = [FIND :newString IN ALL FIELDS RETURNING Contact(FirstName,LastName), Lead(FirstName,LastName)];
        System.debug(searchList);
    return searchList; 
    }
}