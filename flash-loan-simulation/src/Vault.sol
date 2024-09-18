// SPDX-License-Identifier: UNLICENSED
/*
Destination for profits of flash loans and arbitrage operations
*/
pragma solidity 0.8.26;


contract Vault {
    address public owner;
    uint256 public balance;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function deposit() external payable {
        balance += msg.value;
    }

    function withdraw(uint256 amount) external onlyOwner {
        require(amount <= balance, "Insufficient balance");
        balance -= amount;
        payable(owner).transfer(amount);
    }

    function getBalance() external view returns (uint256) {
        return balance;
    }
}