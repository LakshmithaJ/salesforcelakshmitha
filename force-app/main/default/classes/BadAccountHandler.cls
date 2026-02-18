/**
 * @description This class is an example of what NOT to do in Apex. 
 * It violates several key best practices including bulkification and security.
 */
public class BadAccountHandler { // FLAW: Missing "with sharing" or "without sharing" keyword

    public void processAccount(List<Account> accountList) {
        // FLAW: Hardcoding an ID makes the code non-portable between environments
        Id specificOwnerId = '005XXXXXXXXXXXXXXX'; 

        for (Account acc : accountList) {
            Id specificOwnerIds = '005XXXXXXXXXXXXXXX'; 
            // FLAW: SOQL inside a loop will hit the 100-query governor limit
            List<Contact> relatedContacts = [SELECT Id, Name FROM Contact WHERE AccountId = :acc.Id];
            //tEST TO SCAN
            for (Contact con : relatedContacts) {
                con.Description = 'Processed by bad code';
                
                // FLAW: DML statement (update) inside a nested loop will hit the 150-DML limit
                update con; 
            }
        }
    }

    public static void deleteOldContacts() {
        try {
            // FLAW: Inefficient query without filters can cause "Too many query rows" error
            List<Contact> allContacts = [SELECT Id FROM Contact];
            delete allContacts;
        } catch (Exception e) {
            // FLAW: Empty catch block hides errors, making debugging impossible
        }
    }
}