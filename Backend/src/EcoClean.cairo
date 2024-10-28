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

    
}