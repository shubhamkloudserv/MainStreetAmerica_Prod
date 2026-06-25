@IsTest
private class AccountCreationControllerTest {

    // ─── Happy path ────────────────────────────────────────────────────────

    @IsTest
    static void testSaveAccount_tenDigitPhone_returnsId() {
        Test.startTest();
        Id accountId = AccountCreationController.saveAccount('Acme Corp', '1234567890');
        Test.stopTest();

        System.assertNotEquals(null, accountId, 'A valid Account Id must be returned.');

        Account saved = [SELECT Name, Phone FROM Account WHERE Id = :accountId LIMIT 1];
        System.assertEquals('Acme Corp', saved.Name, 'Name should match input.');
        System.assertEquals('1234567890', saved.Phone, 'Phone should match input.');
    }

    @IsTest
    static void testSaveAccount_fifteenDigitPhone_returnsId() {
        Test.startTest();
        Id accountId = AccountCreationController.saveAccount('Global Corp', '123456789012345');
        Test.stopTest();

        System.assertNotEquals(null, accountId, 'A 15-digit phone should succeed.');
    }

    @IsTest
    static void testSaveAccount_formattedPhone_stripsAndValidates() {
        // Formatted number "(800) 555-1234" has 10 digits — should succeed
        Test.startTest();
        Id accountId = AccountCreationController.saveAccount('Formatted LLC', '(800) 555-1234');
        Test.stopTest();

        System.assertNotEquals(null, accountId, 'Formatted phone with 10 digits should succeed.');
        Account saved = [SELECT Phone FROM Account WHERE Id = :accountId LIMIT 1];
        System.assertEquals('(800) 555-1234', saved.Phone, 'Raw phone value should be persisted.');
    }

    // ─── Account Name validation ───────────────────────────────────────────

    @IsTest
    static void testSaveAccount_nullName_throwsException() {
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount(null, '1234567890');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Null Account Name should throw AuraHandledException.');
    }

    @IsTest
    static void testSaveAccount_blankName_throwsException() {
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('   ', '1234567890');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Blank Account Name should throw AuraHandledException.');
    }

    @IsTest
    static void testSaveAccount_emptyName_throwsException() {
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('', '1234567890');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Empty Account Name should throw AuraHandledException.');
    }

    // ─── Phone validation ──────────────────────────────────────────────────

    @IsTest
    static void testSaveAccount_nullPhone_throwsException() {
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('Test Corp', null);
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Null phone should throw AuraHandledException.');
    }

    @IsTest
    static void testSaveAccount_blankPhone_throwsException() {
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('Test Corp', '');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Blank phone should throw AuraHandledException.');
    }

    @IsTest
    static void testSaveAccount_phoneTooShort_throwsException() {
        // 9 digits — below the 10-digit minimum
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('Test Corp', '123456789');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, '9-digit phone should throw AuraHandledException.');
    }

    @IsTest
    static void testSaveAccount_phoneTooLong_throwsException() {
        // 16 digits — above the 15-digit maximum
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('Test Corp', '1234567890123456');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, '16-digit phone should throw AuraHandledException.');
    }

    @IsTest
    static void testSaveAccount_phoneAllSpaces_throwsException() {
        Boolean threw = false;
        try {
            AccountCreationController.saveAccount('Test Corp', '   ');
        } catch (AuraHandledException e) {
            threw = true;
        }
        System.assert(threw, 'Whitespace-only phone should throw AuraHandledException.');
    }
}
