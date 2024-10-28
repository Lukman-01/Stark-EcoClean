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
    #[abi(embed_v0)]
    impl EcoCleanImpl of IEcoClean<ContractState> {
        fn constructor(ref self: ContractState, eco_token_address: ContractAddress) {
            assert(eco_token_address.is_non_zero(), Errors::INVALID_TOKEN_ADDRESS);
            self.eco_token_address.write(eco_token_address);
            self.total_transactions.write(0);
            self.locked.write(false);
        }

        fn get_registered_company_count(self: @ContractState) -> u32 {
            self.company_addresses_len.read()
        }

        fn get_registered_picker_count(self: @ContractState) -> u32 {
            self.picker_addresses_len.read()
        }

        fn get_picker(self: @ContractState, address: ContractAddress) -> Picker {
            self.pickers.read(address)
        }

        fn get_company(self: @ContractState, address: ContractAddress) -> Company {
            self.companies.read(address)
        }

        fn register_company(
            ref self: ContractState,
            name: felt252,
            min_weight_requirement: u256,
            max_price_per_kg: u256,
            active: bool
        ) -> bool {
            let caller = get_caller_address();
            assert(name != 0, Errors::NAME_REQUIRED);
            assert(max_price_per_kg > 0, Errors::INVALID_PRICE);
            assert(min_weight_requirement > 0, Errors::INVALID_WEIGHT);

            let existing_company = self.companies.read(caller);
            assert(existing_company.max_price_per_kg == 0, Errors::COMPANY_EXISTS);

            let new_company = Company {
                company_address: caller,
                name: name,
                min_weight_requirement: min_weight_requirement,
                max_price_per_kg: max_price_per_kg,
                active: active,
            };

            self.companies.write(caller, new_company);
            let current_len = self.company_addresses_len.read();
            self.company_addresses.write(current_len, caller);
            self.company_addresses_len.write(current_len + 1);

            self.emit(Event::CompanyRegistered(CompanyRegistered {
                company_address: caller,
                name: name,
                min_weight_requirement: min_weight_requirement,
                max_price_per_kg: max_price_per_kg,
                active: active,
            }));

            true
        }

        fn edit_company(
            ref self: ContractState,
            name: felt252,
            min_weight_requirement: u256,
            max_price_per_kg: u256,
            active: bool
        ) -> bool {
            let caller = get_caller_address();
            let mut company = self.companies.read(caller);
            assert(company.max_price_per_kg != 0, Errors::COMPANY_NOT_FOUND);
            assert(name != 0, Errors::NAME_REQUIRED);
            assert(max_price_per_kg > 0, Errors::INVALID_PRICE);
            assert(min_weight_requirement > 0, Errors::INVALID_WEIGHT);

            company.name = name;
            company.min_weight_requirement = min_weight_requirement;
            company.max_price_per_kg = max_price_per_kg;
            company.active = active;

            self.companies.write(caller, company);

            self.emit(Event::CompanyEdited(CompanyEdited {
                company_address: caller,
                name: name,
                min_weight_requirement: min_weight_requirement,
                max_price_per_kg: max_price_per_kg,
                active: active,
            }));

            true
        }

        fn update_company_name(ref self: ContractState, name: felt252) {
            let caller = get_caller_address();
            assert(name != 0, Errors::NAME_REQUIRED);
            let mut company = self.companies.read(caller);
            assert(company.max_price_per_kg != 0, Errors::COMPANY_NOT_FOUND);
            company.name = name;
            self.companies.write(caller, company);
        }

        fn update_company_min_weight_requirement(ref self: ContractState, min_weight_requirement: u256) {
            let caller = get_caller_address();
            assert(min_weight_requirement > 0, Errors::INVALID_WEIGHT);
            let mut company = self.companies.read(caller);
            assert(company.max_price_per_kg != 0, Errors::COMPANY_NOT_FOUND);
            company.min_weight_requirement = min_weight_requirement;
            self.companies.write(caller, company);
        }

        fn update_company_max_price_per_kg(ref self: ContractState, max_price_per_kg: u256) {
            let caller = get_caller_address();
            assert(max_price_per_kg > 0, Errors::INVALID_PRICE);
            let mut company = self.companies.read(caller);
            assert(company.max_price_per_kg != 0, Errors::COMPANY_NOT_FOUND);
            company.max_price_per_kg = max_price_per_kg;
            self.companies.write(caller, company);
        }

        fn update_company_active_status(ref self: ContractState, active: bool) {
            let caller = get_caller_address();
            let mut company = self.companies.read(caller);
            assert(company.max_price_per_kg != 0, Errors::COMPANY_NOT_FOUND);
            company.active = active;
            self.companies.write(caller, company);
        }

        fn register_picker(ref self: ContractState, name: felt252, email: felt252) -> bool {
            let caller = get_caller_address();
            assert(name != 0, Errors::NAME_REQUIRED);
            assert(email != 0, 'Email required');

            let existing_picker = self.pickers.read(caller);
            assert(existing_picker.name == 0, Errors::PICKER_EXISTS);

            let new_picker = Picker {
                picker_address: caller,
                name: name,
                email: email,
                weight_deposited: 0,
            };

            self.pickers.write(caller, new_picker);
            let current_len = self.picker_addresses_len.read();
            self.picker_addresses.write(current_len, caller);
            self.picker_addresses_len.write(current_len + 1);

            self.emit(Event::PickerRegistered(PickerRegistered {
                picker_address: caller,
                name: name,
                email: email,
            }));

            true
        }

        fn edit_picker(ref self: ContractState, name: felt252, email: felt252) -> bool {
            let caller = get_caller_address();
            assert(name != 0, Errors::NAME_REQUIRED);
            assert(email != 0, 'Email required');

            let mut picker = self.pickers.read(caller);
            assert(picker.name != 0, Errors::PICKER_NOT_FOUND);

            picker.name = name;
            picker.email = email;
            self.pickers.write(caller, picker);

            self.emit(Event::PickerEdited(PickerEdited {
                picker_address: caller,
                name: name,
                email: email,
            }));

            true
        }

        fn update_picker_name(ref self: ContractState, name: felt252) {
            let caller = get_caller_address();
            assert(name != 0, Errors::NAME_REQUIRED);
            let mut picker = self.pickers.read(caller);
            assert(picker.name != 0, Errors::PICKER_NOT_FOUND);
            picker.name = name;
            self.pickers.write(caller, picker);
        }

        fn update_picker_email(ref self: ContractState, email: felt252) {
            let caller = get_caller_address();
            assert(email != 0, 'Email required');
            let mut picker = self.pickers.read(caller);
            assert(picker.name != 0, Errors::PICKER_NOT_FOUND);
            picker.email = email;
            self.pickers.write(caller, picker);
        }

        fn deposit_plastic(
            ref self: ContractState,
            company_address: ContractAddress,
            weight: u256
        ) -> u256 {
            let caller = get_caller_address();
            
            // Validate picker
            let picker = self.pickers.read(caller);
            assert(picker.name != 0, Errors::PICKER_NOT_FOUND);
            
            // Validate company and weight
            let company = self.companies.read(company_address);
            assert(company.active, Errors::COMPANY_NOT_ACTIVE);
            assert(weight >= company.min_weight_requirement, Errors::INSUFFICIENT_WEIGHT);

            let transaction_id = self.total_transactions.read();
            let price = weight * company.max_price_per_kg;
            
            let new_transaction = Transaction {
                id: transaction_id,
                company_address: company_address,
                picker_address: caller,
                weight: weight,
                price: price,
                is_approved: false
            };

            // Store the transaction
            self.transactions.write(transaction_id, new_transaction);
            
            // Update picker's transaction list
            let picker_tx_len = self.picker_transactions_len.read(caller);
            self.picker_transactions.write((caller, picker_tx_len), transaction_id);
            self.picker_transactions_len.write(caller, picker_tx_len + 1);
            
            // Increment total transactions counter
            self.total_transactions.write(transaction_id + 1);

            // Emit event
            self.emit(Event::PlasticDeposited(PlasticDeposited {
                transaction_id: transaction_id,
                company_address: company_address,
                picker_address: caller,
                weight: weight,
                price: price,
            }));

            transaction_id
        }

        fn validate_plastic(ref self: ContractState, transaction_id: u256) -> bool {
            let caller = get_caller_address();
            
            // Get transaction
            let mut transaction = self.transactions.read(transaction_id);
            assert(transaction.company_address == caller, Errors::UNAUTHORIZED);
            assert(!transaction.is_approved, Errors::ALREADY_APPROVED);

            // Update transaction status
            transaction.is_approved = true;
            self.transactions.write(transaction_id, transaction);

            // Update picker's total weight deposited
            let mut picker = self.pickers.read(transaction.picker_address);
            picker.weight_deposited += transaction.weight;
            self.pickers.write(transaction.picker_address, picker);

            self.emit(Event::PlasticValidated(PlasticValidated {
                transaction_id: transaction_id,
                company_address: caller,
                picker_address: transaction.picker_address,
            }));

            true
        }

        fn pay_picker(ref self: ContractState, transaction_id: u256) -> bool {
            assert(!self.locked.read(), Errors::REENTRANCY);
            self.locked.write(true);

            let transaction = self.transactions.read(transaction_id);
            assert(transaction.company_address == get_caller_address(), Errors::UNAUTHORIZED);
            assert(transaction.is_approved, 'Transaction not validated');

            // Get EcoToken contract
            let eco_token_address = self.eco_token_address.read();
            let eco_token = IERC20Dispatcher { contract_address: eco_token_address };

            // Check allowance and balance
            let company_address = transaction.company_address;
            let picker_address = transaction.picker_address;
            let amount = transaction.price;

            let allowance = eco_token.allowance(company_address, get_contract_address());
            assert(allowance >= amount, Errors::INSUFFICIENT_ALLOWANCE);

            let balance = eco_token.balance_of(company_address);
            assert(balance >= amount, Errors::INSUFFICIENT_BALANCE);

            // Transfer tokens
            let transfer_success = eco_token.transfer_from(
                company_address, picker_address, amount
            );
            assert(transfer_success, Errors::TRANSFER_FAILED);

            self.emit(Event::PickerPaid(PickerPaid {
                transaction_id: transaction_id,
                company_address: company_address,
                picker_address: picker_address,
                amount: amount,
            }));

            self.locked.write(false);
            true
        }

        fn get_all_company_addresses(self: @ContractState) -> Array<ContractAddress> {
            let mut addresses = ArrayTrait::new();
            let len = self.company_addresses_len.read();
            let mut i: u32 = 0;
            
            loop {
                if i >= len {
                    break;
                }
                addresses.append(self.company_addresses.read(i));
                i += 1;
            };
            
            addresses
        }

        fn get_all_companies(self: @ContractState) -> Array<Company> {
            let mut companies = ArrayTrait::new();
            let len = self.company_addresses_len.read();
            let mut i: u32 = 0;
            
            loop {
                if i >= len {
                    break;
                }
                let address = self.company_addresses.read(i);
                companies.append(self.companies.read(address));
                i += 1;
            };
            
            companies
        }

        fn get_all_picker_addresses(self: @ContractState) -> Array<ContractAddress> {
            let mut addresses = ArrayTrait::new();
            let len = self.picker_addresses_len.read();
            let mut i: u32 = 0;
            
            loop {
                if i >= len {
                    break;
                }
                addresses.append(self.picker_addresses.read(i));
                i += 1;
            };
            
            addresses
        }

        fn get_picker_transactions(
            self: @ContractState,
            picker_address: ContractAddress
        ) -> Array<Transaction> {
            let mut transactions = ArrayTrait::new();
            let len = self.picker_transactions_len.read(picker_address);
            let mut i: u32 = 0;
            
            loop {
                if i >= len {
                    break;
                }
                let transaction_id = self.picker_transactions.read((picker_address, i));
                transactions.append(self.transactions.read(transaction_id));
                i += 1;
            };
            
            transactions
        }
    }
}