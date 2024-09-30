#!/bin/sh
set +x
set +e
clear
echo "Debugging flash loan simulation..."
forge clean
forge test --debug test_arbitrage