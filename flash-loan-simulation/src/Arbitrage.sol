// SPDX-License-Identifier: UNLICENSED
//The actual contract that makes the arbitrage swap
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MockFlashLoanProvider.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract Arbitrage {
    address public owner;
    MockFlashLoanProvider public flashLoanProvider;
    IERC20 public token;  // Use ERC20 token directly instead of dex contracts
    address public dex1;  // Use as recipient
    address public dex2;  // Use as recipient

    constructor(address _flashLoanProvider, address _dex1, address _dex2, address _tokenAddress) {
        owner = msg.sender;
        flashLoanProvider = MockFlashLoanProvider(payable(_flashLoanProvider));
        dex1 = _dex1;
        dex2 = _dex2;
        token = IERC20(_tokenAddress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    //Suggest fixes so that this function swap tokens not ETH
    function checkAndExecuteArbitrage(uint256 swapAmount) external onlyOwner {
        console.log("Step 1: Borrow tokens from MockFlashLoanProvider");
        // Step 1: Borrow tokens from MockFlashLoanProvider
        console.log("before flashLoanProvider.transferTokentoken.balanceOf(address(this))", token.balanceOf(address(this)));
        console.log("before flashLoanProvider.transferToken address(flashLoanProvider))", token.balanceOf(address(flashLoanProvider)));
        flashLoanProvider.transferToken(address(flashLoanProvider), address(this), swapAmount);
        console.log("after flashloan token.balanceOf(address(this))", token.balanceOf(address(this)));

        console.log("Step 2: Transfer borrowed tokens to DEX2 (simulating buying tokens)");
        uint dex2TokenBalance = token.balanceOf(dex2);
        // Step 2: Transfer borrowed tokens to DEX2 (simulating buying tokens)
        console.log("dex2TokenBalance", dex2TokenBalance);
        require(dex2TokenBalance >= swapAmount, "Swap amount too high");
        token.approve(dex2, swapAmount);
        token.transfer(dex2, swapAmount);  // Simulated swap on DEX2

        console.log("Assume some profit after DEX2 \"swap\", get token balance back");
        // Assume some profit after DEX2 "swap", get token balance back
        uint256 tokenBalanceAfterDex2 = token.balanceOf(address(dex2));  // Get the new token balance on DEX2
        console.log("tokenBalanceAfterDex2", tokenBalanceAfterDex2);

        console.log("Step 3: Transfer tokens back from DEX2 to DEX1 (simulating selling tokens)");
        // Step 3: Transfer tokens back from DEX2 to DEX1 (simulating selling tokens)
        console.log("-->token.balanceOf(address(dex1)", token.balanceOf(address(dex1)));
        token.approve(dex1, tokenBalanceAfterDex2);
        console.log("--------------------------------");
        token.transfer(dex1, swapAmount);  // Simulated swap on DEX1
        console.log("-->token.balanceOf(address(dex1)", token.balanceOf(address(dex1)));

        console.log("Step 4: Ensure you have enough tokens to repay the loan");
        // Step 4: Ensure you have enough tokens to repay the loan
        uint256 finalBalance = token.balanceOf(address(this));
        require(finalBalance > swapAmount, "No profit made");
        console.log("Final balance after DEX1 swap:", finalBalance);
        // Step 5: Repay flash loan
        token.transfer(address(flashLoanProvider), swapAmount);
        
        console.log("Step 6: Keep the profit");
        // Step 6: Keep the profit
        uint256 profit = finalBalance - swapAmount;
        token.transfer(owner, profit);
    }

    function getDexTokenBalance(address dex) public view returns (uint256) {
        return token.balanceOf(dex);
    }

    function findMinimuBalance(uint256 v1, uint256 v2) public pure returns (uint256) {
        if (v1 < v2) {
            return v1;
        }
        return v2;
    }
}