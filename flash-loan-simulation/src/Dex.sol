// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex {
    mapping(address => uint256) public tokenPrices;
    string public name;

    constructor(string memory _name) {
        name = _name;
    }

    function getName() external view returns (string memory) {
        return name;
    }

    function setTokenPrice(address _tokenAddress, uint _xTokenprice) external {
        tokenPrices[_tokenAddress] = _xTokenprice;
    }

    function getTokenPrice(address _tokenAddress) external view returns (uint256) {
        return tokenPrices[_tokenAddress];
    }

    function valueOfTokens(address _tokenAddress) external view returns (uint256) {
        IERC20 token = IERC20(_tokenAddress);
        return token.balanceOf(address(this)) * tokenPrices[_tokenAddress];
    }
}