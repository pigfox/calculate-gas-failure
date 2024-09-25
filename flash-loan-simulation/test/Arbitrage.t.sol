// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {Arbitrage} from "../src/Arbitrage.sol";
import {Dex} from "../src/Dex.sol";
import {XToken} from "../src/XToken.sol";
import {Vault} from "../src/Vault.sol";
import {MockFlashLoanProvider} from "../src/MockFlashLoanProvider.sol";

contract ArbitrageTest is Test {
    uint swapAmount;
    Arbitrage public arbitrage;
    Dex public dex1;
    Dex public dex2;
    XToken public xtoken;
    MockFlashLoanProvider public mfp;
    Vault public vault;

    function setUp() public {
        console.log("Begin Setup");
        mfp = new MockFlashLoanProvider();
        vault = new Vault();
        dex1 = new Dex("1");
        //vm.deal(address(dex1), 10 * 1e18);
        dex2 = new Dex("2");
        //vm.deal(address(dex2), 10 * 1e18);
        xtoken = new XToken(0);

        xtoken.supply(address(dex1), 25000);
        xtoken.supply(address(dex2), 5000);
        xtoken.supply(address(mfp), 100000);
        dex1.setTokenPrice(address(xtoken),125);
        dex2.setTokenPrice(address(xtoken),100);
        uint256 dex1Balance = xtoken.balanceOf(address(dex1));
        uint256 dex2Balance = xtoken.balanceOf(address(dex2));
        uint256 dex1Value = dex1.valueOfTokens(address(xtoken));
        uint256 dex2Value = dex2.valueOfTokens(address(xtoken));
        console.log("dex1.getTokenPrice(address(xtoken)", dex1.getTokenPrice(address(xtoken)));
        console.log("dex2.getTokenPrice(address(xtoken)", dex2.getTokenPrice(address(xtoken)));

        if (dex1Balance > dex2Balance) {
            arbitrage = new Arbitrage(address(mfp),address(dex2), address(dex1), address(xtoken));
        } else {
            arbitrage = new Arbitrage(address(mfp),address(dex1), address(dex2), address(xtoken));
        }

        console.log("swapAmount:", swapAmount);
        console.log("dex1Value:", dex1Value);
        console.log("dex2Value:", dex2Value);

        console.log("--Before flashloan--");
        console.log("xtoken.balanceOf(address(mfp)):", xtoken.balanceOf(address(mfp)));
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));

        mfp.transferToken(address(xtoken), address(arbitrage), 1000);

        console.log("--After flashloan--");
        console.log("xtoken.balanceOf(address(mfp)):", xtoken.balanceOf(address(mfp)));
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));
        /*
        console.log("arbitrage:", address(arbitrage));
        console.log("xtoken:", address(xtoken));
        console.log("dex1:", address(dex1));
        console.log("ETH dex1.balance:", address(dex1).balance);
        console.log("dex2:", address(dex2));
        console.log("ETH dex2.balance:", address(dex2).balance);
        */
        console.log("End Setup");
    }

    function test_arbitrage() public {
        console.log("Before swap");
        // Use vm.record() to start tracking the transaction
        //vm.record();

        // Perform the arbitrage operation (transaction)
        uint256 gasBefore = gasleft();
        arbitrage.checkAndExecuteArbitrage(swapAmount);
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used in transaction:", gasUsed);
/*
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
*/
        console.log("After swap");
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));
    }
}