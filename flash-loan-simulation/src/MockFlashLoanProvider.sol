// SPDX-License-Identifier: UNLICENSED
// Simulates FlashLoanProvider Equalizer Finance with no fee.
pragma solidity 0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {console} from "../lib/forge-std/src/console.sol";

contract MockFlashLoanProvider{
    address public owner;

    event TransferLog(string message, string data, address recipient);
    event OwnerLog(address recipient, uint256 amount);
    error TransferError(string message, string data, address recipient);

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

    function transferToken(address tokenAddress, address recipient, uint256 amount) external {
        IERC20 token = IERC20(tokenAddress);

        //token.balanceOf(address(this));
        //emit OwnerLog(recipient, token.balanceOf(address(this)));

        // Transfer tokens from this contract's balance to the recipient
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSignature("transfer(address,uint256)", recipient, amount)
        );
        
        // Convert bytes to string
        string memory dataAsString = bytesToString(data);
        if(success){
            emit TransferLog("Data", dataAsString, recipient);
        }else{
            revert TransferError("Token transfer failed", dataAsString, recipient);
        }
    }

    function borrowETH(address recipient, uint256 amount) external{
        require(amount <= address(this).balance, "Insufficient balance");
        payable(recipient).transfer(amount);
    }

    function deposit() external payable {}
    // Receive function to accept ETH
    receive() external payable {}

     // Utility function to convert bytes to string
    function bytesToString(bytes memory data) internal pure returns (string memory) {
        return string(data);
    }
}