#[starknet::contract]
pub mod EcoToken {
    use crate::Interfaces::IEcoToken::IERC20;
    use crate::Errors::TokenErrors::Errors;
    use core::num::traits::Zero;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StorageMapReadAccess, StorageMapWriteAccess, StoragePointerReadAccess,
        StoragePointerWriteAccess
    };


    #[storage]
    struct Storage {
        name: felt252,
        symbol: felt252,
        decimals: u8,
        total_supply: felt252,
        balances: Map::<ContractAddress, felt252>,
        allowances: Map::<(ContractAddress, ContractAddress), felt252>,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub enum Event {
        Transfer: Transfer,
        Approval: Approval,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Transfer {
        pub from: ContractAddress,
        pub to: ContractAddress,
        pub value: felt252,
    }
    #[derive(Copy, Drop, Debug, PartialEq, starknet::Event)]
    pub struct Approval {
        pub owner: ContractAddress,
        pub spender: ContractAddress,
        pub value: felt252,
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        recipient: ContractAddress,
        name: felt252,
        decimals: u8,
        initial_supply: felt252,
        symbol: felt252
    ) {
        self.name.write(name);
        self.symbol.write(symbol);
        self.decimals.write(decimals);
        // Set the contract owner to the deployer
        self.owner.write(get_caller_address());
        self._mint(recipient, initial_supply);
    }

    #[abi(embed_v0)]
    impl IEcoTokenImpl of IERC20<ContractState> {
        fn get_name(self: @ContractState) -> felt252 {
            self.name.read()
        }

        fn get_symbol(self: @ContractState) -> felt252 {
            self.symbol.read()
        }

        fn get_decimals(self: @ContractState) -> u8 {
            self.decimals.read()
        }

        fn get_total_supply(self: @ContractState) -> felt252 {
            self.total_supply.read()
        }

        fn balance_of(self: @ContractState, account: ContractAddress) -> felt252 {
            self.balances.read(account)
        }

        fn allowance(
            self: @ContractState, owner: ContractAddress, spender: ContractAddress
        ) -> felt252 {
            self.allowances.read((owner, spender))
        }

        fn transfer(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            let sender = get_caller_address();
            self._transfer(sender, recipient, amount);
        }

        fn mint(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), Errors::NOT_OWNER);
            self._mint(recipient, amount);
        }

        fn burn(ref self: ContractState, amount: felt252) {
            let caller = get_caller_address();
            assert(caller == self.owner.read(), Errors::NOT_OWNER);
            self._burn(caller, amount);
        }

        fn transfer_from(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252
        ) {
            let caller = get_caller_address();
            self.spend_allowance(sender, caller, amount);
            self._transfer(sender, recipient, amount);
        }

        fn approve(ref self: ContractState, spender: ContractAddress, amount: felt252) {
            let caller = get_caller_address();
            self.approve_helper(caller, spender, amount);
        }

        fn increase_allowance(
            ref self: ContractState, spender: ContractAddress, added_value: felt252
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) + added_value
                );
        }

        fn decrease_allowance(
            ref self: ContractState, spender: ContractAddress, subtracted_value: felt252
        ) {
            let caller = get_caller_address();
            self
                .approve_helper(
                    caller, spender, self.allowances.read((caller, spender)) - subtracted_value
                );
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn _transfer(
            ref self: ContractState,
            sender: ContractAddress,
            recipient: ContractAddress,
            amount: felt252
        ) {
            assert(sender.is_non_zero(), Errors::TRANSFER_FROM_ZERO);
            assert(recipient.is_non_zero(), Errors::TRANSFER_TO_ZERO);
            self.balances.write(sender, self.balances.read(sender) - amount);
            self.balances.write(recipient, self.balances.read(recipient) + amount);
            self.emit(Transfer { from: sender, to: recipient, value: amount });
        }

        fn spend_allowance(
            ref self: ContractState,
            owner: ContractAddress,
            spender: ContractAddress,
            amount: felt252
        ) {
            let allowance = self.allowances.read((owner, spender));
            self.allowances.write((owner, spender), allowance - amount);
        }

        fn approve_helper(
            ref self: ContractState,
            owner: ContractAddress,
            spender: ContractAddress,
            amount: felt252
        ) {
            assert(spender.is_non_zero(), Errors::APPROVE_TO_ZERO);
            self.allowances.write((owner, spender), amount);
            self.emit(Approval { owner, spender, value: amount });
        }

        fn _mint(ref self: ContractState, recipient: ContractAddress, amount: felt252) {
            assert(recipient.is_non_zero(), Errors::MINT_TO_ZERO);

            let supply = self.total_supply.read() + amount;
            self.total_supply.write(supply);

            let balance = self.balances.read(recipient) + amount;
            self.balances.write(recipient, balance);

            self
                .emit(
                    Event::Transfer(
                        Transfer {
                            from: contract_address_const::<0>(), to: recipient, value: amount
                        }
                    )
                );
        }

        fn _burn(ref self: ContractState, account: ContractAddress, amount: felt252) {
            assert(account.is_non_zero(), Errors::BURN_FROM_ZERO);

            let balance = self.balances.read(account);
            //assert(balance >= amount, 'ERC20: burn amount exceeds balance');

            self.balances.write(account, balance - amount);

            let supply = self.total_supply.read() - amount;
            self.total_supply.write(supply);

            self
                .emit(
                    Event::Transfer(
                        Transfer { from: account, to: contract_address_const::<0>(), value: amount }
                    )
                );
        }
    }
}
