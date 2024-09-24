// SPDX-License-Identifier: UNLICENSED
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
    function checkAndExecuteArbitrage(uint256 amountBorrow) external onlyOwner {
        console.log("Step 1: Borrow tokens from MockFlashLoanProvider");
        // Step 1: Borrow tokens from MockFlashLoanProvider
        flashLoanProvider.transferToken(address(token), address(this), amountBorrow);

        console.log("Step 2: Transfer borrowed tokens to DEX2 (simulating buying tokens)");
        // Step 2: Transfer borrowed tokens to DEX2 (simulating buying tokens)
        console.log("-->token.balanceOf(address(dex2)", token.balanceOf(address(dex2)));
        token.approve(dex2, amountBorrow);
        token.transfer(dex2, amountBorrow);  // Simulated swap on DEX2

        console.log("Assume some profit after DEX2 \"swap\", get token balance back");
        // Assume some profit after DEX2 "swap", get token balance back
        uint256 tokenBalanceAfterDex2 = token.balanceOf(address(dex2));  // Get the new token balance on DEX2
        console.log("tokenBalanceAfterDex2", tokenBalanceAfterDex2);

        console.log("Step 3: Transfer tokens back from DEX2 to DEX1 (simulating selling tokens)");
        // Step 3: Transfer tokens back from DEX2 to DEX1 (simulating selling tokens)
        console.log("-->token.balanceOf(address(dex1)", token.balanceOf(address(dex1)));
        token.approve(dex1, tokenBalanceAfterDex2);
        console.log("--------------------------------");
        token.transfer(dex1, 1000);  // Simulated swap on DEX1
        console.log("-->token.balanceOf(address(dex1)", token.balanceOf(address(dex1)));

        console.log("Step 4: Ensure you have enough tokens to repay the loan");
        // Step 4: Ensure you have enough tokens to repay the loan
        uint256 finalBalance = token.balanceOf(address(this));
        //require(finalBalance > amountBorrow, "No profit made");
        console.log("Final balance after DEX1 swap:", finalBalance);
        // Step 5: Repay flash loan
        token.transfer(address(flashLoanProvider), amountBorrow);
        
        console.log("Step 6: Keep the profit");
        // Step 6: Keep the profit
        uint256 profit = finalBalance - amountBorrow;
        token.transfer(owner, profit);
    }

    function getDexTokenBalance(address dex) public view returns (uint256) {
        return token.balanceOf(dex);
    }
}



/*
// Inside the flashLoan callback or execution flow of your contract

// 1. Borrow tokens from DEX2 instead of DEX1.
// Assuming dex2 is the address of DEX2, borrow the tokens from there.
// If you're using a flash loan service, initiate the loan from DEX2 for the tokens.

IERC20 token2 = IERC20(token2Address); // DEX2's token

// Assuming flash loan from DEX2, the logic would look like this:
dex2.flashLoan(address(this), token2Address, amountBorrow, data);

// Now that you've borrowed from DEX2, you want to use the borrowed amount to purchase DEX2 tokens.
// 2. Use the borrowed amount to buy tokens from DEX2.
uint256 amountToSpend = amountBorrow; // this is the amount you borrowed

// Approve DEX2 to spend the borrowed amount
token2.approve(dex2Address, amountToSpend);

// Execute the swap on DEX2, buying as many tokens as you can with the borrowed amount.
// You need to swap `amountToSpend` worth of token2 for tokens on DEX2.
dex2.swapExactTokensForTokens(amountToSpend, 0, path2, address(this), block.timestamp);

// 3. Now, you have acquired tokens from DEX2. The next step is to sell them on DEX1.
// Get the balance of tokens after the swap on DEX2.
uint256 tokenBalance = token2.balanceOf(address(this));

// Approve DEX1 to spend the tokens you acquired from DEX2.
token2.approve(dex1Address, tokenBalance);

// Execute the swap on DEX1, selling the tokens for profit.
// This is where you sell the tokens you bought from DEX2 to DEX1 at a better price.
dex1.swapExactTokensForTokens(tokenBalance, 0, path1, address(this), block.timestamp);

// 4. After the swap, calculate profit and repay the flash loan to DEX2.
uint256 finalBalance = token2.balanceOf(address(this));

// Ensure you have enough profit to cover the flash loan repayment.
require(finalBalance > amountBorrow, "No profit was made");

// Repay the flash loan to DEX2.
token2.transfer(dex2Address, amountBorrow);

// Keep the profit (finalBalance - amountBorrow) as your arbitrage gain.
uint256 profit = finalBalance - amountBorrow;

*/