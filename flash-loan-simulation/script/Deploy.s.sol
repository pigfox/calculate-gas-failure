// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from "forge-std/Script.sol";
import {FlashLoanReceiver} from "../src/FlashLoanReceiver.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();
        FlashLoanReceiver receiver = new FlashLoanReceiver(/* pass constructor args if any */);
        console.log("FlashLoanReceiver deployed to:", address(receiver));
        vm.stopBroadcast();
    }
}
