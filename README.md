# calculate-gas-failure
A standalone file that reproduces a Go-Ethereum gas calculation failure in a larger project.

You need your own Infura API key for Ethereum Main net to view the error.

Save the .env.example file as .env and add your own Infura API key.

The task is to fix the gas calculation failure in the code so that it returns the correct gas amount.

When you submit code for review, create a new repo with the name of your Github username.

Then include a brief description of the error and the fix you implemented.

The contract deployed here: https://etherscan.io/address/0xcBc57F275dB5fd2F4da20882fCa443B9cd302eCD 

It is an implementation of https://docs.equalizer.finance/getting-started/how-do-i-borrow-a-flash-loan-a-deep-dive

See Appendix
A.1 Flash Borrower smart contract example

To run this code.
```
In terminal 1: $ anvil
Choose the address from the terminal above and add it to the main.go file
Choose the private key from the terminal above and add it to the flash-loan-simulation/script/FlashloanReceiver.s.sol
In terminal 2: 
$ forge script script/FlashloanReceiver.s.sol --rpc-url http://127.0.0.1:8545 --broadcast
flash-loan-simulation$ forge test --fork-url http://127.0.0.1:8545 -vvv
flash-loan-simulation$ forge test --fork-url http://127.0.0.1:8545 --match-contract FlashloanReceiverTest --match-test test_flashloan -vvv
flash-loan-simulation$ forge test --fork-url http://127.0.0.1:8545 --match-contract FlashloanReceiverTest --match-test test_checkOwnerETHBalanceAndTransfer -vvv

flash-loan-simulation$ forge test --fork-url http://127.0.0.1:8545 --match-contract FlashloanReceiverTest --debug test_flashloan
flash-loan-simulation$ forge test --fork-url http://127.0.0.1:8545 --match-contract ExampleTest --debug test_logging

forge test --fork-url http://127.0.0.1:8545 --match-contract ArbitrageTest --match-test test_arbitrage -vvv

In terminal 3: $ go run main.go
```
#geth --nousb


