public with sharing class AccountCreationController {

    // Accepts 10–15 consecutive digits (after stripping formatting characters)
    private static final Pattern PHONE_DIGIT_PATTERN = Pattern.compile('^\\d{10,15}$');

    /**
     * Creates an Account with the provided name and phone number.
     * Phone formatting characters (spaces, dashes, parentheses) are stripped
     * before the digit-count check; the raw value is persisted to the Phone field.
     *
     * @param accountName  Account.Name — required, non-blank
     * @param phone        Account.Phone — required, 10–15 digits
     * @return             Id of the newly created Account
     */
    @AuraEnabled(cacheable=false)
    public static Id saveAccount(String accountName, String phone) {
        if (String.isBlank(accountName)) {
            throw new AuraHandledException('Account Name is required.');
        }
        if (String.isBlank(phone)) {
            throw new AuraHandledException('Phone is required.');
        }

        String digits = phone.replaceAll('[^0-9]', '');
        if (!PHONE_DIGIT_PATTERN.matcher(digits).matches()) {
            throw new AuraHandledException(
                'Phone must contain between 10 and 15 digits.'
            );
        }

        Account acc = new Account(
            Name  = accountName.trim(),
            Phone = phone.trim()
        );

        SObjectAccessDecision decision = Security.stripInaccessible(
            AccessType.CREATABLE,
            new List<Account>{ acc }
        );

        try {
            insert decision.getRecords();
        } catch (DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0));
        }

        return decision.getRecords()[0].Id;
    }
}
