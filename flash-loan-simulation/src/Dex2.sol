// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex2{
    uint256 private xTokenprice = 95;

    function getPrice(address token) external view returns (uint256) {
        return xTokenprice;
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }
}
