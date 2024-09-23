// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Interface IDex
interface IDex {
    function getPrice(address token) external returns (uint256);
    function swap(address token, uint256 amount) external;
}

contract Dex2 is IDex {
    uint256 private price = 95;

    function getPrice(address token) external view returns (uint256) {
        return price;
    }
    
    function swap(address tokenAddress, uint amount) public {
        IERC20 token = IERC20(tokenAddress);
        // Ensure Dex2 has enough balance for the swap
        require(token.balanceOf(address(this)) >= amount, "Dex2: Not enough liquidity");

        // Transfer tokens from Arbitrage contract to Dex2
        require(token.transferFrom(msg.sender, address(this), amount), "Dex2: Transfer failed");

        // Simulate sending proceeds back to Arbitrage after swap (in this case, same token)
        // In a real swap, this might involve buying another token and sending it back
        uint proceeds = amount * price / 100; // Just an example calculation
        require(token.transfer(msg.sender, proceeds), "Dex2: Transfer back failed");
    }
    
    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
