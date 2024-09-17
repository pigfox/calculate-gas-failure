// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
//import {console} from "forge-std/console.sol";
//import {Test, console} from "forge-std/Test.sol"; //<-default from project - fails
import {console} from "../lib/forge-std/src/console.sol"; //<-- proper path
import {Arbitrage} from "../src/Arbitrage.sol";
import {Dex1} from "../src/Dex1.sol";
import {Dex2} from "../src/Dex2.sol";
import {XToken} from "../src/XToken.sol";

contract ArbitrageTest is Test {
    Arbitrage public arbitrage;
    Dex1 public dex1;
    Dex2 public dex2;
    XToken public xtoken;

    function setUp() public {
        dex1 = new Dex1();
        vm.deal(address(dex1), 10 * 1e18);
        dex2 = new Dex2();
        vm.deal(address(dex2), 10 * 1e18);
        xtoken = new XToken(0);
        xtoken.suppy(address(dex1), 25000);
        xtoken.suppy(address(dex2), 5000);
        arbitrage = new Arbitrage(address(dex1), address(dex2), address(xtoken));
        xtoken.suppy(address(arbitrage), 1000);

        console.log("arbitrage:", address(arbitrage));
        console.log("xtoken:", address(xtoken));
        console.log("dex1:", address(dex1));
        console.log("dex1.balance:", address(dex1).balance);
        console.log("dex2:", address(dex2));
        console.log("dex2.balance:", address(dex2).balance);
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));
    }

    function test_arbitrage() public {
        console.log("Starting");
        arbitrage.checkAndExecuteArbitrage(500);
        console.log("End");
    }
}