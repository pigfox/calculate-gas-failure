// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
//import {console} from "forge-std/console.sol";
//import {Test, console} from "forge-std/Test.sol"; //<-default from project - fails
import {console} from "../lib/forge-std/src/console.sol"; //<-- proper path
import {Arbitrage} from "../src/Arbitrage.sol";

function setUp() public {

}

function test_arbitrage() public {
    console.log("Starting");

    console.log("end");
}