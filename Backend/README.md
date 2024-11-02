# EcoClean

## Project Description
EcoClean is a decentralized application built on Starknet that connects waste pickers with recycling companies to facilitate efficient plastic waste management. The platform incentivizes waste collection by enabling direct compensation through a token-based reward system. Companies can set their requirements and pricing, while waste pickers can easily deposit collected plastics and receive automatic payments through smart contracts.

## Functionality
- **Company Registration**: Companies can register and specify their requirements for plastic collection, including minimum weight requirements and maximum price per kilogram.
- **Waste Picker Management**: Individuals can register as waste pickers, deposit plastic waste, and track their earnings.
- **Transaction Processing**: Smart contract handles the validation of deposits and automated payment processing.
- **Reward System**: Integration with ERC20 tokens for seamless and transparent payments.

## Usage
1. **Company Setup**:
   - Register company profile with requirements
   - Set pricing and minimum weight thresholds
   - Approve token allowance for payments

2. **Waste Picker Operations**:
   - Register as a waste picker
   - Deposit collected plastics
   - Track transactions and earnings

3. **Transaction Flow**:
   - Pickers deposit plastic waste
   - Companies validate deposits
   - Smart contract processes payments automatically

## Installation
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Lukman-01/Stark-Eco-Clean.git
   cd Stark-Eco-Clean/Backend
   ```

2. **Install Dependencies**:
   ```bash
   scarb install
   ```

3. **Set Up Environment**:
   Configure your Starknet wallet and ensure you have the required test tokens.

## Compile
To compile the smart contract:
```bash
scarb build
```

## Deploy
Deploy the contract to Starknet:
```bash
starkli deploy target/dev/eco_clean_EcoClean.contract_class --account <account> --network <network>
```

## Testing
Run the test suite:
```bash
scarb test
```

### Deployed Addresses
[Add deployed contract addresses and network information here]
