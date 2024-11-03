pub mod Errors {
    pub const APPROVE_FROM_ZERO: felt252 = 'ERC20: approve from 0';
    pub const APPROVE_TO_ZERO: felt252 = 'ERC20: approve to 0';
    pub const TRANSFER_FROM_ZERO: felt252 = 'ERC20: transfer from 0';
    pub const TRANSFER_TO_ZERO: felt252 = 'ERC20: transfer to 0';
    pub const BURN_FROM_ZERO: felt252 = 'ERC20: burn from 0';
    pub const MINT_TO_ZERO: felt252 = 'ERC20: mint to 0';
    pub const NOT_OWNER: felt252 = 'ERC20: caller is not owner';
}
