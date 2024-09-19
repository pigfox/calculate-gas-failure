#!/bin/sh
set +x
set +e
echo "Running flash loan simulation"
forge clean
forge test --fork-url http://127.0.0.1:8545 --match-contract ArbitrageTest --match-test test_arbitrage -vvvv
