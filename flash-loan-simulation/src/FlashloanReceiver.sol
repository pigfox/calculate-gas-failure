// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external returns (uint256);
    function transfer(address recipient, uint256 amount) external returns(bool);
}

interface IERC3156FlashBorrower {
    /**
     * @dev Receive a flash loan.
     * @param initiator The initiator of the loan.
     * @param token The loan currency.
     * @param amount The amount of tokens lent.
     * @param fee The additional amount of tokens to repay.
     * @param data Arbitrary data structure, intended to contain user-defined parameters.
     * @return The keccak256 hash of "ERC3156FlashBorrower.onFlashLoan"
     */
    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);
}

interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract FlashloanReceiver is IERC3156FlashBorrower {
    uint256 MAX_INT = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function updateOwner(address newOwner) external {
        require(msg.sender == owner, "Only current owner can execute this function");
        owner = newOwner;
    }

    // @dev ERC-3156 Flash loan callback
    function onFlashLoan(
        address initiator,
        address baseTokenAddress,  //token borrowed
        uint256 amount, //amount borrowed
        uint256 fee,
        bytes calldata data
    ) external override returns (bytes32) { //need for override keyword? don't think so
        initiator; //silence warning
        (address buyDexAddress, address sellDexAddress, address assetTokenAddress) = abi.decode(data, (address, address, address));
        IUniswapRouter buyDex = IUniswapRouter(buyDexAddress);
        IUniswapRouter sellDex = IUniswapRouter(sellDexAddress);
        IERC20 baseToken = IERC20(baseTokenAddress);
        IERC20 assetToken = IERC20(assetTokenAddress);

        //Buy asset token
        address[] memory buyPath = new address[](2);
        buyPath[0] = baseTokenAddress;
        buyPath[1] = assetTokenAddress;
        baseToken.approve(buyDexAddress, MAX_INT); //can we be more restrictive?
        buyDex.swapExactTokensForTokens(
            amount,
            0,  //amountOutMin
            buyPath,
            address(this),
            block.timestamp
        );

        //Sell asset token
        address[] memory sellPath = new address[](2);
        sellPath[0] = assetTokenAddress;
        sellPath[1] = baseTokenAddress;
        assetToken.approve(sellDexAddress, MAX_INT); //can we be more restrictive?
        sellDex.swapExactTokensForTokens(
            assetToken.balanceOf(address(this)),
            0,  //amountOutMin
            sellPath,
            address(this),
            block.timestamp
        );

        //Send profit to owner
        uint profit = baseToken.balanceOf(address(this)) - amount - fee;
        baseToken.transfer(owner, profit);

        // Set the allowance to payback the flash loan
        baseToken.approve(msg.sender, MAX_INT); //not great to have MAX_INT, can we be more restrictive?

        // Return success to the lender, he will transfer get the funds back if allowance is set accordingly
        return keccak256('ERC3156FlashBorrower.onFlashLoan');
    }
}