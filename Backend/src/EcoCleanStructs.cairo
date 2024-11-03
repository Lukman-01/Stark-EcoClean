use starknet::ContractAddress;

#[derive(Drop, Serde, starknet::Store)]
pub struct Company {
    pub company_address: ContractAddress,
    pub name: felt252,
    pub min_weight_requirement: u256,
    pub max_price_per_kg: u256,
    pub active: bool,
}

#[derive(Drop, Serde, starknet::Store)]
pub struct Picker {
    pub picker_address: ContractAddress,
    pub name: felt252,
    pub email: felt252,
    pub weight_deposited: u256,
}

#[derive(Drop, Serde, starknet::Store)]
pub struct Transaction {
    pub id: u256,
    pub company_address: ContractAddress,
    pub picker_address: ContractAddress,
    pub weight: u256,
    pub price: u256,
    pub is_approved: bool,
}
