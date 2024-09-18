// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Interface IDex
interface IDex {
    function getPrice(address token) external returns (uint256);
    function swap(address token, uint256 amount) external;
}

contract Dex1 is IDex {
    uint256 private price = 100;

    // Implements the getPrice function
    function getPrice(address token) external returns (uint256) {
        return price;
    }
    
    // Implements the swap function
    function swap(address tokenAddress, uint amount) public {
        IERC20 token = IERC20(tokenAddress);
        // Ensure Dex1 has enough balance for the swap
        require(token.balanceOf(address(this)) >= amount, "Dex1: Not enough liquidity");

        // Transfer tokens from Arbitrage contract to Dex1
        require(token.transferFrom(msg.sender, address(this), amount), "Dex1: Transfer failed");

        // You could add logic here to simulate buying back at a certain price, 
        // or returning another asset if you're simulating a swap between different tokens
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}