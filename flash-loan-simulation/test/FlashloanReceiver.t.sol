// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
//import {console} from "forge-std/console.sol";
//import {Test, console} from "forge-std/Test.sol"; //<-default from project - fails
import {console} from "../lib/forge-std/src/console.sol"; //<-- proper path
import {FlashloanReceiver} from "../src/FlashloanReceiver.sol";

interface IFlashloanProvider {
    function flashLoan(
        address receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

interface IERC20 {
    function balanceOf(address account) external returns (uint256);
}

contract FlashloanReceiverTest0 is Test {
    IFlashloanProvider public provider;
    FlashloanReceiver public receiver;
    IERC20 public baseToken;
    address public FLASHLOAN_PROVIDER = 0x4EAF187ad4cE325bF6C84070b51c2f7224A51321; 
    address public BUY_DEX = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //Uniswap router v2
    address public SELL_DEX = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F; //Sushiswap router v2

    uint public BASE_AMOUNT = 1 * 10 ** 18; //WETH
    address public BASE_TOKEN = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH
    address public ASSET_TOKEN = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2; //SUSHI
    
    address public OWNER = address(1);

    function setUp() public {
        provider = IFlashloanProvider(FLASHLOAN_PROVIDER); //Ethereum
        receiver = new FlashloanReceiver(OWNER);
        baseToken = IERC20(BASE_TOKEN);
    }
    /*
       function test_flashloan() public {
           console.log("43");
           console.log("Test message");
           console.log("45");
       }
      */
        function test_flashloan() public {
            console.log("Starting");
           // Encode the data required for flash loan: buy DEX, sell DEX, and asset token addresses
           bytes memory data = abi.encode(BUY_DEX, SELL_DEX, ASSET_TOKEN);
            console.log("53");
           // Initial balances before the flash loan
           uint initialOwnerBalance = baseToken.balanceOf(OWNER);
           console.log("56");
           uint initialReceiverBalance = baseToken.balanceOf(address(receiver));
           console.log("58");
           // "Cheat" by adding some base tokens to the receiver, simulating the start with a small balance
           deal(BASE_TOKEN, address(receiver), BASE_AMOUNT * 5 / 100); // Simulate profit situation
           console.log("61");
           // Trigger the flash loan
           bool success = provider.flashLoan(
               address(receiver),
               BASE_TOKEN,
               BASE_AMOUNT,
               data
           );
           console.log("68");
           // Assert flash loan call was successful
           assertTrue(success, "Flash loan did not succeed");

           // Check if the receiver has paid back the loan plus the fee
           uint finalReceiverBalance = baseToken.balanceOf(address(receiver));
           assertEq(finalReceiverBalance, initialReceiverBalance, "Flash loan repayment failed");

           // Assert the owner has received the profit
           uint finalOwnerBalance = baseToken.balanceOf(OWNER);
           assertGt(finalOwnerBalance, initialOwnerBalance, "Profit was not transferred to the owner");

           console.log("Profit transferred: ", finalOwnerBalance - initialOwnerBalance);
       }

/*
    function test_flashloan() public {
        console.log("OWNER:",OWNER);
        //1. Trigger flashloan
        //2. Verify that we have made a profit
        bytes memory data = abi.encode(BUY_DEX, SELL_DEX, ASSET_TOKEN); 
        deal(BASE_TOKEN, address(receiver), BASE_AMOUNT * 5 / 100); //We "cheat" by sending some base asset to the flashloan contract, to simulate a profit
        provider.flashLoan(
            address(receiver),
            BASE_TOKEN,
            BASE_AMOUNT,
            data
        );
        assertGt(baseToken.balanceOf(OWNER), 0);
    }
*/
    function test_updateOwner_succeeds() public {
        address newOwner = address(2);
        vm.prank(OWNER);
        receiver.updateOwner(newOwner);
        address owner = receiver.owner();
        assertEq(owner, newOwner);
    }

    function test_updateOwner_fails() public {
        address newOwner = address(2);
        vm.expectRevert(bytes("Only current owner can execute this function"));
        receiver.updateOwner(newOwner);
    }
}
