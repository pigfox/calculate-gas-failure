// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import "../src/FlashloanReceiver.sol";

contract FlashloanReceiverScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        FlashloanReceiver receiver = new FlashloanReceiver(vm.addr(deployerPrivateKey));
        vm.stopBroadcast();
    }
}