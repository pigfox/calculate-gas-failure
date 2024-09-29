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
        //Create instances of contracts
        mfp = new MockFlashLoanProvider();
        vault = new Vault();
        dex1 = new Dex("1");
        dex2 = new Dex("2");
        xtoken = new XToken(0);

        //Supply tokens to dexes and mfp
        xtoken.supply(address(dex1), 25000);
        xtoken.supply(address(dex2), 5000);
        xtoken.supply(address(mfp), 1000000);

        //Set token price per dex
        dex1.setTokenPrice(address(xtoken),125);
        dex2.setTokenPrice(address(xtoken),100);

        uint256 dex1BalanceOf = xtoken.balanceOf(address(dex1));
        uint256 dex2BalanceOf = xtoken.balanceOf(address(dex2));
        uint256 dex1ValueOfTokens = dex1.valueOfTokens(address(xtoken));
        uint256 dex2ValueOfTokens = dex2.valueOfTokens(address(xtoken));
        uint256 dex1TokenPrice = dex1.getTokenPrice(address(xtoken));
        uint256 dex2TokenPrice = dex2.getTokenPrice(address(xtoken));

        console.log("dex1TokenPrice", dex1TokenPrice);
        console.log("dex2TokenPrice", dex2TokenPrice);

        //Creating contract arbitrage here, since it depends on the token balances of dex1 and dex2
        //SwapAmount is the minimum of the two balances, buy from lower price and sell to higher price
        if (dex1TokenPrice > dex2TokenPrice) {
            arbitrage = new Arbitrage(address(mfp),address(dex2), address(dex1), address(xtoken));
            swapAmount = arbitrage.findMinimuBalance(dex2BalanceOf, dex1BalanceOf);
        } else {
            arbitrage = new Arbitrage(address(mfp),address(dex1), address(dex2), address(xtoken));
            swapAmount = arbitrage.findMinimuBalance(dex1BalanceOf, dex2BalanceOf);
        }
/*
        console.log("swapAmount:", swapAmount);
        console.log("--Before flashloan--");
        console.log("xtoken.balanceOf(address(mfp)):", xtoken.balanceOf(address(mfp)));
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("dex1BalanceOf:", dex1BalanceOf);
        console.log("dex2BalanceOf:", dex2BalanceOf);
*/
        console.log("dex1ValueOfTokens:", dex1ValueOfTokens);
        console.log("dex2ValueOfTokens:", dex2ValueOfTokens);

        console.log("dex1.valueOfTokens(address(xtoken)):", dex1.valueOfTokens(address(xtoken)));
        console.log("dex2.valueOfTokens(address(xtoken)):", dex2.valueOfTokens(address(xtoken)));
        console.log("End Setup");
    }

    function test_arbitrage() public {
        console.log("Before swap");
        //Take flashloan from mfp to arbitrage
        mfp.transferToken(address(xtoken), address(arbitrage), swapAmount);

        // Perform the arbitrage operation (transaction)
        uint256 gasBefore = gasleft();
        try arbitrage.checkAndExecuteArbitrage(swapAmount) {
            console.log("Arbitrage executed successfully");
        } catch {
            console.log("Arbitrage execution failed");
        }
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
        //Repay flashloan
        mfp.transferToken(address(xtoken), address(mfp), swapAmount);
        console.log("After swap");
        console.log("xtoken.balanceOf(address(arbitrage)):", xtoken.balanceOf(address(arbitrage)));
        console.log("xtoken.balanceOf(address(dex1)):", xtoken.balanceOf(address(dex1)));
        console.log("xtoken.balanceOf(address(dex2)):", xtoken.balanceOf(address(dex2)));
    }
}