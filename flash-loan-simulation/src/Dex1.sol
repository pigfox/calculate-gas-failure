// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Interface IDex
interface IDex {
    function getPrice(address token) external view returns (uint256);
    function swap(address token, uint256 amount) external;
}

contract Dex1 is IDex {
    uint256 private price = 100;

    // Implements the getPrice function
    function getPrice(address token) external pure override returns (uint256) {
        return 100;
    }
    
    // Implements the swap function
    function swap(address token, uint256 amount) external override {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        // Implement swap logic here if needed
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}