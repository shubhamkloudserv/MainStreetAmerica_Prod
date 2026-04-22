@isTest
public class MembershipAccountIdSequenceGeneratorTest {

    @testSetup
    static void setupData() {

        // Get Person Account Record Type
        Id personRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Account' AND IsPersonType = true LIMIT 1].Id;

        // Create Person Account
        Account pa = new Account(RecordTypeId = personRT, FirstName = 'OldPAFirst', LastName = 'OldPALast', PersonEmail = 'oldpa@test.com');
        insert pa;

        // Create normal Account
        Account org = new Account(Name = 'Org Account');
        insert org;

        // Create Contact
        Contact con = new Contact(FirstName = 'OldConFirst', LastName = 'OldConLast', Email = 'oldcon@test.com', AccountId = org.Id);
        insert con;
    }

    // ===============================
    // TEST assignAccountNumbers
    // ===============================
    @isTest
    static void test_assignAccountNumbers() {

        List<Account> accList = new List<Account>();
        for(Integer i = 0; i < 5; i++){
            accList.add(new Account(Name = 'Test ' + i));
        }

        Test.startTest();
        MembershipAccountIdSequenceGenerator.assignAccountNumbers(accList);
        Test.stopTest();
    }

    // ===============================
    // TEST fetchCurrentMaxAccountNumber
    // ===============================
    @isTest
    static void test_fetchCurrentMaxAccountNumber() {

        Account acc1 = new Account(Name='A1', Account_Id_Number__c = 5);
        Account acc2 = new Account(Name='A2', Account_Id_Number__c = 10);

        insert new List<Account>{acc1, acc2};

        Test.startTest();
        Decimal maxVal = MembershipAccountIdSequenceGenerator.fetchCurrentMaxAccountNumber();
        Test.stopTest();
    }

    // ===============================
    // TEST updatePrimaryContact (Person Account)
    // ===============================
    @isTest
    static void test_updatePrimaryContact_PersonAccount() {

        Account pa = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount = true LIMIT 1];

        Account source = new Account(Name = 'Source', Primary_Contact__c = pa.PersonContactId,
            						Person_First_Name__c = 'NewPAFirst', Person_Last_Name__c = 'NewPALast', 
                                     Person_Email__c = 'newpa@test.com');
        insert source;

        // OLD MAP simulation
        Account oldRec = source.clone(false, true, false, false);
        oldRec.Person_First_Name__c = 'Old';
        oldRec.Person_Last_Name__c  = 'Old';
        oldRec.Person_Email__c      = 'old@test.com';

        Map<Id, Account> oldMap = new Map<Id, Account>{source.Id => oldRec};

        Test.startTest();
        MembershipAccountIdSequenceGenerator.updatePrimaryContact(new List<Account>{source}, oldMap);
        Test.stopTest();
    }

    // ===============================
    // TEST updatePrimaryContact (Contact)
    // ===============================
    @isTest
    static void test_updatePrimaryContact_Contact() {

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        Account source = new Account(Name = 'Source2', Primary_Contact__c = con.Id, Person_First_Name__c = 'NewConFirst',
            							Person_Last_Name__c = 'NewConLast', Person_Email__c = 'newcon@test.com');
        insert source;

        // OLD MAP
        Account oldRec = source.clone(false, true, false, false);
        oldRec.Person_First_Name__c = 'Old';
        oldRec.Person_Last_Name__c  = 'Old';
        oldRec.Person_Email__c      = 'old@test.com';

        Map<Id, Account> oldMap = new Map<Id, Account>{source.Id => oldRec};

        Test.startTest();
        MembershipAccountIdSequenceGenerator.updatePrimaryContact(new List<Account>{source}, oldMap);
        Test.stopTest();
    }

    // ===============================
    // TEST No Change Scenario
    // ===============================
    @isTest
    static void test_updatePrimaryContact_NoChange() {

        Account acc = new Account(Name='No Change');
        insert acc;

        Map<Id, Account> oldMap = new Map<Id, Account>{acc.Id => acc};

        Test.startTest();
        MembershipAccountIdSequenceGenerator.updatePrimaryContact(new List<Account>{acc}, oldMap);
        Test.stopTest();
    }

    // ===============================
    // TEST Bulk Scenario
    // ===============================
    @isTest
    static void test_bulkScenario() {

        Contact con = [SELECT Id FROM Contact LIMIT 1];

        List<Account> accList = new List<Account>();
        Map<Id, Account> oldMap = new Map<Id, Account>();

        for(Integer i = 0; i < 5; i++){
            Account acc = new Account(Name = 'Bulk ' + i, Primary_Contact__c = con.Id, 
                                      Person_First_Name__c = 'BulkFirst' + i, Person_Last_Name__c  = 'BulkLast' + i,
                						Person_Email__c = 'bulk' + i + '@test.com');
            accList.add(acc);
        }

        insert accList;

        for(Account acc : accList){
            Account oldRec = acc.clone(false, true, false, false);
            oldRec.Person_First_Name__c = 'Old';
            oldRec.Person_Last_Name__c  = 'Old';
            oldRec.Person_Email__c      = 'old@test.com';

            oldMap.put(acc.Id, oldRec);
        }

        Test.startTest();
        MembershipAccountIdSequenceGenerator.updatePrimaryContact(accList, oldMap);
        Test.stopTest();
    }
}