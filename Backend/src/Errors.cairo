pub mod Errors {
    pub const INVALID_TOKEN_ADDRESS: felt252 = 'Invalid token address';
    pub const NAME_REQUIRED: felt252 = 'Name required';
    pub const INVALID_PRICE: felt252 = 'Invalid price';
    pub const INVALID_WEIGHT: felt252 = 'Invalid weight';
    pub const COMPANY_EXISTS: felt252 = 'Company already exists';
    pub const COMPANY_NOT_FOUND: felt252 = 'Company not found';
    pub const PICKER_EXISTS: felt252 = 'Picker already exists';
    pub const PICKER_NOT_FOUND: felt252 = 'Picker not found';
    pub const COMPANY_NOT_ACTIVE: felt252 = 'Company not active';
    pub const INSUFFICIENT_WEIGHT: felt252 = 'Insufficient weight';
    pub const TRANSACTION_NOT_FOUND: felt252 = 'Transaction not found';
    pub const UNAUTHORIZED: felt252 = 'Unauthorized';
    pub const ALREADY_APPROVED: felt252 = 'Already approved';
    pub const INSUFFICIENT_ALLOWANCE: felt252 = 'Insufficient allowance';
    pub const INSUFFICIENT_BALANCE: felt252 = 'Insufficient balance';
    pub const TRANSFER_FAILED: felt252 = 'Transfer failed';
    pub const REENTRANCY: felt252 = 'Reentrancy';
}
