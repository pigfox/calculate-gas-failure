// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockFlashLoanProvider{
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(uint256 amount) external onlyOwner{
        require(amount <= address(this).balance, "Insufficient balance");
        payable(owner).transfer(amount);
    }

    function transfer(address recipient, uint256 amount) external onlyOwner{
        require(amount <= address(this).balance, "Insufficient balance");
        payable(recipient).transfer(amount);
    }

    function transferToken(address token, address recipient, uint256 amount) external onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }


    function borrow(address recipient, uint256 amount) external{
        require(amount <= address(this).balance, "Insufficient balance");
        payable(recipient).transfer(amount);
    }

    function deposit() external payable {}
    // Receive function to accept ETH
    receive() external payable {}
}