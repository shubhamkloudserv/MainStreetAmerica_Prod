import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveAccount from '@salesforce/apex/AccountCreationController.saveAccount';

// Matches 10–15 consecutive digits (after stripping non-digit characters)
const PHONE_DIGIT_REGEX = /^\d{10,15}$/;

export default class AccountCreationForm extends LightningElement {

    accountName = '';
    phone = '';
    isLoading = false;

    // Tracks whether each field currently has a validation error.
    // Separate from the value itself so isSaveDisabled can be reactive
    // without needing DOM access inside a getter.
    _nameHasError = false;
    _phoneHasError = false;

    get isSaveDisabled() {
        return (
            this.isLoading ||
            !this.accountName.trim() ||
            !this.phone.trim() ||
            this._nameHasError ||
            this._phoneHasError
        );
    }

    // ─── Event handlers ────────────────────────────────────────────────────

    handleNameChange(event) {
        this.accountName = event.detail.value;
        this.validateName();
    }

    handlePhoneChange(event) {
        this.phone = event.detail.value;
        this.validatePhone();
    }

    // ─── Validation ────────────────────────────────────────────────────────

    validateName() {
        const input = this.template.querySelector('[data-id="accountName"]');
        if (!this.accountName.trim()) {
            input.setCustomValidity('Account Name is required.');
            this._nameHasError = true;
        } else {
            input.setCustomValidity('');
            this._nameHasError = false;
        }
        input.reportValidity();
    }

    validatePhone() {
        const input = this.template.querySelector('[data-id="phone"]');
        const digits = this.phone.replace(/\D/g, '');
        let errorMsg = '';
  
        if (!this.phone.trim()) {
            errorMsg = 'Phone is required.';
        } else if (!PHONE_DIGIT_REGEX.test(digits)) {
            errorMsg = 'Phone must contain between 10 and 15 digits.';
        }

        input.setCustomValidity(errorMsg);
        input.reportValidity();
        this._phoneHasError = errorMsg !== '';
    }

    // ─── Save ──────────────────────────────────────────────────────────────

    async handleSave() {
        // Re-validate both fields to surface errors on untouched fields
        this.validateName();
        this.validatePhone();

        const allInputsValid = [...this.template.querySelectorAll('lightning-input')]
            .every(input => input.checkValidity());

        if (!allInputsValid) {
            return;
        }

        this.isLoading = true;
        try {
            const accountId = await saveAccount({
                accountName: this.accountName.trim(),
                phone: this.phone.trim()
            });

            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Account created successfully.',
                variant: 'success'
            }));

            this.dispatchEvent(new CustomEvent('accountcreated', { detail: { accountId } }));
            this.resetForm();

        } catch (error) {
            const message = error?.body?.message ?? 'An unexpected error occurred.';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error Creating Account',
                message,
                variant: 'error',
                mode: 'sticky'
            }));
        } finally {
            this.isLoading = false;
        }
    }

    // ─── Utilities ─────────────────────────────────────────────────────────

    resetForm() {
        this.accountName = '';
        this.phone = '';
        this._nameHasError = false;
        this._phoneHasError = false;
        this.template.querySelectorAll('lightning-input').forEach(input => {
            input.setCustomValidity('');
            input.reportValidity();
        });
    }
}
