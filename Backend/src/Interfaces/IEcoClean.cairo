use starknet::ContractAddress;
use crate::EcoCleanStructs::{Company, Picker, Transaction};

#[starknet::interface]
pub trait IEcoClean<TContractState> {
    fn constructor(ref self: TContractState, eco_token_address: ContractAddress);
    fn register_company(
        ref self: TContractState,
        name: felt252,
        min_weight_requirement: u256,
        max_price_per_kg: u256,
        active: bool
    ) -> bool;
    fn get_registered_company_count(self: @TContractState) -> u32;
    fn edit_company(
        ref self: TContractState,
        name: felt252,
        min_weight_requirement: u256,
        max_price_per_kg: u256,
        active: bool
    ) -> bool;
    fn update_company_name(ref self: TContractState, name: felt252);
    fn update_company_min_weight_requirement(
        ref self: TContractState, min_weight_requirement: u256
    );
    fn update_company_max_price_per_kg(ref self: TContractState, max_price_per_kg: u256);
    fn update_company_active_status(ref self: TContractState, active: bool);
    fn register_picker(ref self: TContractState, name: felt252, email: felt252) -> bool;
    fn get_picker(self: @TContractState, address: ContractAddress) -> Picker;
    fn get_company(self: @TContractState, address: ContractAddress) -> Company;
    fn get_registered_picker_count(self: @TContractState) -> u32;
    fn edit_picker(ref self: TContractState, name: felt252, email: felt252) -> bool;
    fn update_picker_name(ref self: TContractState, name: felt252);
    fn update_picker_email(ref self: TContractState, email: felt252);
    fn deposit_plastic(
        ref self: TContractState, company_address: ContractAddress, weight: u256
    ) -> u256;
    fn validate_plastic(ref self: TContractState, transaction_id: u256) -> bool;
    fn pay_picker(ref self: TContractState, transaction_id: u256) -> bool;
    fn get_all_company_addresses(self: @TContractState) -> Array<ContractAddress>;
    fn get_all_companies(self: @TContractState) -> Array<Company>;
    fn get_all_picker_addresses(self: @TContractState) -> Array<ContractAddress>;
    fn get_picker_transactions(
        self: @TContractState, picker_address: ContractAddress
    ) -> Array<Transaction>;
}
