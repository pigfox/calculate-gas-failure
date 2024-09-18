// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "./XToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {console} from "../lib/forge-std/src/console.sol"; 

interface IDex {
    function getPrice(address token) external view returns (uint256);
    function swap(address token, uint256 amount) external;
}

contract Arbitrage{
    address public owner;
    IDex public dex1;
    IDex public dex2;
    IERC20 public xtoken;
    uint256 public threshold = 5; // 5% difference threshold for arbitrage

    constructor(address _dex1, address _dex2, address _xtoken) {
        owner = msg.sender;
        dex1 = IDex(_dex1);
        dex2 = IDex(_dex2);
        xtoken = IERC20(_xtoken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function checkAndExecuteArbitrage(uint256 amount) external onlyOwner {
        uint256 priceDex1 = dex1.getPrice(address(xtoken));
        uint256 priceDex2 = dex2.getPrice(address(xtoken));
        console.log("Price from DEX1: %d", priceDex1);
        console.log("Price from DEX2: %d", priceDex2);

        // Calculate the price difference percentage
        uint256 priceDiff = priceDex1 > priceDex2
            ? ((priceDex1 - priceDex2) * 100) / priceDex1
            : ((priceDex2 - priceDex1) * 100) / priceDex2;
        console.log("Price difference: %d", priceDiff);
        
        if (priceDiff >= threshold) {
            if (priceDex1 > priceDex2) {
                // Arbitrage: Buy from DEX2 (lower price) and sell on DEX1 (higher price)
                xtoken.approve(address(dex2), amount);
                dex2.swap(address(xtoken), amount);
                xtoken.approve(address(dex1), amount);
                dex1.swap(address(xtoken), amount);
            } else {
                // Arbitrage: Buy from DEX1 (lower price) and sell on DEX2 (higher price)
                xtoken.approve(address(dex1), amount);
                dex1.swap(address(xtoken), amount);
                xtoken.approve(address(dex2), amount);
                dex2.swap(address(xtoken), amount);
            }
        }
    }
}
