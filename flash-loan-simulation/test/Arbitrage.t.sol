// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "../lib/forge-std/src/console.sol"; //<-- proper path
import {Arbitrage} from "../src/Arbitrage.sol";
import {Dex1} from "../src/Dex1.sol";
import {Dex2} from "../src/Dex2.sol";
import {XToken} from "../src/XToken.sol";
import {MockFlashLoanProvider} from "../src/MockFlashLoanProvider.sol";

contract ArbitrageTest is Test {
    uint swapAmount = 500;
    Arbitrage public arbitrage;
    Dex1 public dex1;
    Dex2 public dex2;
    XToken public xtoken;
    MockFlashLoanProvider public mfp;

    function setUp() public {
        console.log("Begin Setup");
        dex1 = new Dex1();
        //vm.deal(address(dex1), 10 * 1e18);
        dex2 = new Dex2();
        //vm.deal(address(dex2), 10 * 1e18);
        xtoken = new XToken(0);
        xtoken.suppy(address(dex1), 25000);
        xtoken.suppy(address(dex2), 5000);
        arbitrage = new Arbitrage(address(dex1), address(dex2), address(xtoken));
        xtoken.suppy(address(arbitrage), 1000);
        MockFlashLoanProvider mfp = new MockFlashLoanProvider();
        xtoken.suppy(address(mfp), 100000);

        console.log("arbitrage:", address(arbitrage));
        console.log("xtoken:", address(xtoken));
        console.log("dex1:", address(dex1));
        console.log("dex1.balance:", address(dex1).balance);
        console.log("dex2:", address(dex2));
        console.log("dex2.balance:", address(dex2).balance);
        console.log("dex1.getPrice(address(xtoken)):", dex1.getPrice(address(xtoken)));
        console.log("dex2.getPrice(address(xtoken)):", dex2.getPrice(address(xtoken)));
        console.log("xtoken.balanceOf(address(mfp)):", xtoken.balanceOf(address(mfp)));
        console.log("End Setup");
    }

    function test_arbitrage() public {
        console.log("Before swap");
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));

        // Use vm.record() to start tracking the transaction
        vm.record();

        // Perform the arbitrage operation (transaction)
        arbitrage.checkAndExecuteArbitrage(swapAmount);

        // Log transaction storage access and logs
        (bytes32[] memory reads, bytes32[] memory writes) = vm.accesses(address(arbitrage));
        console.log("Arbitrage transaction storage reads:");
        for (uint i = 0; i < reads.length; i++) {
            console.logBytes32(reads[i]);
        }

        console.log("Arbitrage transaction storage writes:");
        for (uint i = 0; i < writes.length; i++) {
            console.logBytes32(writes[i]);
        }

        console.log("After swap");
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));
    }
}