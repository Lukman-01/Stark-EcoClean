//use starknet::ContractAddress;

#[starknet::contract]
pub mod EcoClean {
    use starknet::{ContractAddress,get_block_timestamp, get_caller_address, get_contract_address};
    use core::array::ArrayTrait;
    //use core::option::OptionTrait;
    use core::num::traits::Zero;
    // use traits::Into;
    // use box::BoxTrait;

    //use super::IEcoClean;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess
    };

    #[starknet::interface]
    trait IERC20<TContractState> {
        fn transfer_from(ref self: TContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256) -> bool;
        fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
        fn allowance(self: @TContractState, owner: ContractAddress, spender: ContractAddress) -> u256;
    }

    #[storage]
    struct Storage {
        eco_token_address: ContractAddress,
        company_addresses: Map::<u32, ContractAddress>,
        company_addresses_len: u32,
        picker_addresses: Map::<u32, ContractAddress>,
        picker_addresses_len: u32,
        companies: Map::<ContractAddress, Company>,
        pickers: Map::<ContractAddress, Picker>,
        transactions: Map::<u256, Transaction>,
        picker_transactions: Map::<(ContractAddress, u32), u256>,
        picker_transactions_len: Map::<ContractAddress, u32>,
        total_transactions: u256,
        locked: bool,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Company {
        company_address: ContractAddress,
        name: felt252,
        min_weight_requirement: u256,
        max_price_per_kg: u256,
        active: bool,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Picker {
        picker_address: ContractAddress,
        name: felt252,
        email: felt252,
        weight_deposited: u256,
    }

    #[derive(Copy, Drop, Serde, starknet::Store)]
    struct Transaction {
        id: u256,
        company_address: ContractAddress,
        picker_address: ContractAddress,
        weight: u256,
        price: u256,
        is_approved: bool,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CompanyRegistered: CompanyRegistered,
        CompanyEdited: CompanyEdited,
        PickerRegistered: PickerRegistered,
        PickerEdited: PickerEdited,
        PlasticDeposited: PlasticDeposited,
        PlasticValidated: PlasticValidated,
        PickerPaid: PickerPaid,
    }

    #[derive(Drop, starknet::Event)]
    struct CompanyRegistered {
        company_address: ContractAddress,
        name: felt252,
        min_weight_requirement: u256,
        max_price_per_kg: u256,
        active: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct CompanyEdited {
        company_address: ContractAddress,
        name: felt252,
        min_weight_requirement: u256,
        max_price_per_kg: u256,
        active: bool,
    }

    #[derive(Drop, starknet::Event)]
    struct PickerRegistered {
        picker_address: ContractAddress,
        name: felt252,
        email: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct PickerEdited {
        picker_address: ContractAddress,
        name: felt252,
        email: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct PlasticDeposited {
        transaction_id: u256,
        company_address: ContractAddress,
        picker_address: ContractAddress,
        weight: u256,
        price: u256,
    }

    #[derive(Drop, starknet::Event)]
    struct PlasticValidated {
        transaction_id: u256,
        company_address: ContractAddress,
        picker_address: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    struct PickerPaid {
        transaction_id: u256,
        company_address: ContractAddress,
        picker_address: ContractAddress,
        amount: u256,
    }

    // Error declarations
    mod Errors {
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

    #[starknet::interface]
    pub trait IEcoClean<TContractState> {
        fn constructor(ref self: TContractState, eco_token_address: ContractAddress);
        fn register_company(ref self: TContractState, name: felt252, min_weight_requirement: u256, max_price_per_kg: u256, active: bool) -> bool;
        fn get_registered_company_count(self: @TContractState) -> u32;
        fn edit_company(ref self: TContractState, name: felt252, min_weight_requirement: u256, max_price_per_kg: u256, active: bool) -> bool;
        fn update_company_name(ref self: TContractState, name: felt252);
        fn update_company_min_weight_requirement(ref self: TContractState, min_weight_requirement: u256);
        fn update_company_max_price_per_kg(ref self: TContractState, max_price_per_kg: u256);
        fn update_company_active_status(ref self: TContractState, active: bool);
        fn register_picker(ref self: TContractState, name: felt252, email: felt252) -> bool;
        fn get_picker(self: @TContractState, address: ContractAddress) -> Picker;
        fn get_company(self: @TContractState, address: ContractAddress) -> Company;
        fn get_registered_picker_count(self: @TContractState) -> u32;
        fn edit_picker(ref self: TContractState, name: felt252, email: felt252) -> bool;
        fn update_picker_name(ref self: TContractState, name: felt252);
        fn update_picker_email(ref self: TContractState, email: felt252);
        fn deposit_plastic(ref self: TContractState, company_address: ContractAddress, weight: u256) -> u256;
        fn validate_plastic(ref self: TContractState, transaction_id: u256) -> bool;
        fn pay_picker(ref self: TContractState, transaction_id: u256) -> bool;
        fn get_all_company_addresses(self: @TContractState) -> Array<ContractAddress>;
        fn get_all_companies(self: @TContractState) -> Array<Company>;
        fn get_all_picker_addresses(self: @TContractState) -> Array<ContractAddress>;
        fn get_picker_transactions(self: @TContractState, picker_address: ContractAddress) -> Array<Transaction>;
    }

    // Contract implementation
    
}