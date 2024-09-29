// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Script, console} from "forge-std/Script.sol";
import "../src/FlashloanReceiver.sol";

contract FlashloanReceiverScript is Script {
    function setUp() public {}

    function run() public {
        //get deployer private key from anvil
        uint256 deployerPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80; //vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        FlashloanReceiver receiver = new FlashloanReceiver(vm.addr(deployerPrivateKey));
        receiver; // Silence warning
        vm.stopBroadcast();
    }
}