#!/bin/sh
set +x
set +e
clear
echo "Running flash loan simulation"
forge clean
forge build --force
forge test --fork-url http://127.0.0.1:8545 --gas-report --verbosity --match-contract ArbitrageTest --match-test test_arbitrage -vvvv
