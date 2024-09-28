// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract XToken is ERC20 {
    address public owner;

    constructor(uint256 initialSupply) ERC20("XToken", "XTK") {
        owner = msg.sender;
    }

    modifier onlyOwner()virtual {
        require(msg.sender == owner, "Not the owner");
        _;
    }

    function supply(address destination, uint256 amount) external onlyOwner{
        _mint(destination, amount);
        _transfer(destination, destination, amount);
    }
}
