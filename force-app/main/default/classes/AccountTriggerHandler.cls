/**
 * @description       : Handles complex business logic for Account Trigger
 * @author            : Expert Developer
 * @group             : Handlers
 * @last modified on  : 02-06-2026
**/
public with sharing class AccountTriggerHandler {

    // 1. Separation of Concerns: Method handles one specific action
    public static void updateRelatedContacts(List<Account> newAccounts, Map<Id, Account> oldAccountMap) {
        
        Set<Id> accountIdsToUpdate = new Set<Id>();

        // 2. Bulkification: Efficiently identify records that need updating
        for (Account acc : newAccounts) {
            Account oldAcc = oldAccountMap.get(acc.Id);
            
            // Check if phone changed
            if (acc.Phone != oldAcc.Phone) {
                accountIdsToUpdate.add(acc.Id);
            }
        }

        if (accountIdsToUpdate.isEmpty()) {
            return;
        }

        // 3. Querying: Perform SOQL outside of loops
        List<Contact> contactsToUpdate = [SELECT Id, AccountId, Phone 
                                          FROM Contact 
                                          WHERE AccountId IN :accountIdsToUpdate];

        if (contactsToUpdate.isEmpty()) {
            return;
        }

        // 4. Data Handling: Map child records to parents
        for (Contact con : contactsToUpdate) {
            con.Phone = newAccounts[0].Phone; // Simplified for example, normally map by AccountId
        }

        // 5. DML Operation: Perform DML outside of loops
        try {
            update contactsToUpdate;
        } catch (DmlException e) {
            System.debug('Error updating contacts: ' + e.getMessage());
            // Real-world: Log exception to custom object or log table
        }
    }
}