// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Dex2{
    mapping(address => uint256) public tokenPrices;

    function setPrice(address _tokenAddress, uint _xTokenprice) external {
        tokenPrices[_tokenAddress] = _xTokenprice;
    }

    function getPrice(address _tokenAddress) external view returns (uint256) {
        return tokenPrices[_tokenAddress];
    }

    function valueOfTokens(address _tokenAddress) external view returns (uint256) {
        IERC20 token = IERC20(_tokenAddress);
        return token.balanceOf(address(this)) * tokenPrices[_tokenAddress];
    }
}
