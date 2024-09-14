// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;

import {Test} from "forge-std/Test.sol";
//import {console} from "forge-std/console.sol";
//import {Test, console} from "forge-std/Test.sol"; //<-default from project - fails
import {console} from "../lib/forge-std/src/console.sol"; //<-- proper path
import {ERC20} from "../src/ERC20.sol";
import {FlashloanReceiver} from "../src/FlashloanReceiver.sol";

interface IFlashloanProvider {
    function flashLoan(
        address receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);
}

contract TestToken is ERC20 {
    constructor() ERC20("Test Token", "TTK") {
        mint(msg.sender, 10000 * 10 ** decimals()); // Mint some initial supply
    }
}

contract FlashloanReceiverTest is Test {
    IFlashloanProvider public provider;
    FlashloanReceiver public receiver;
    ERC20 public baseToken;
    address public FLASHLOAN_PROVIDER = 0x4EAF187ad4cE325bF6C84070b51c2f7224A51321;
    address public BUY_DEX = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; //Uniswap router v2
    address public SELL_DEX = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F; //Sushiswap router v2

    uint public BASE_AMOUNT = 1 * 10 ** 18; //WETH
    //address public BASE_TOKEN = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //WETH
    //address public ASSET_TOKEN = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2; //SUSHI

    address public BASE_TOKEN = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8; //from Anvil
    address public ASSET_TOKEN = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC ; //from Anvil

    address public OWNER = address(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266); //from Anvil

    function setUp() public {
        provider = IFlashloanProvider(FLASHLOAN_PROVIDER); //Ethereum
        receiver = new FlashloanReceiver(OWNER);
        baseToken = new TestToken();
        BASE_TOKEN = address(baseToken);

        // Mint some additional tokens if needed
        baseToken.mint(OWNER, 1000 ether); //<-- Member "_mint" not found or not visible after argument-dependent lookup in contract ERC20.
    }

    function test_flashloan() public {
        console.log("Starting");

        console.log("53");
        console.log("OWNER", OWNER);
        console.log("BASE_TOKEN", BASE_TOKEN);
        console.log("baseToken", address(baseToken));
        deal(BASE_TOKEN, OWNER, 1000 ether);
        // Initial balances before the flash loan
        uint initialOwnerBalance = baseToken.balanceOf(OWNER);
        console.log("56");
        uint initialReceiverBalance = baseToken.balanceOf(address(receiver));
       // "Cheat" by adding some base tokens to the receiver, simulating the start with a small balance
        deal(BASE_TOKEN, address(receiver), BASE_AMOUNT * 5 / 100); // Simulate profit situation
       /*
        //Encode the data required for flash loan: buy DEX, sell DEX, and asset token addresses
        //bytes memory data = abi.encode(BUY_DEX, SELL_DEX, ASSET_TOKEN);
        //Trigger the flash loan
        bool success = provider.flashLoan(
            address(receiver),
            BASE_TOKEN,
            BASE_AMOUNT,
            data
        );
         console.log("Flash loan triggered");
       // Assert flash loan call was successful
       assertTrue(success, "Flash loan did not succeed");
*/
       // Check if the receiver has paid back the loan plus the fee
        uint finalReceiverBalance = baseToken.balanceOf(address(receiver));
        assertEq(finalReceiverBalance, initialReceiverBalance, "Flash loan repayment failed");

       // Assert the owner has received the profit
        uint finalOwnerBalance = baseToken.balanceOf(OWNER);
        assertGt(finalOwnerBalance, initialOwnerBalance, "Profit was not transferred to the owner");

        console.log("Profit transferred: ", finalOwnerBalance - initialOwnerBalance);
    }

    function test_checkOwnerETHBalanceAndTransfer() public {
        // Log the initial ETH balance of OWNER before any deal
        console.log("Initial OWNER ETH balance:", OWNER.balance);

        // Pre-fund OWNER with 10 ETH using vm.deal
        vm.deal(OWNER, 10 * 1e18);

        // Log the updated ETH balance after the deal
        console.log("Updated OWNER ETH balance after deal:", OWNER.balance);

        // Start impersonating the OWNER account
        vm.startPrank(OWNER);

        // Transfer 5 ETH from OWNER to receiver
        address payable receiver = payable(
            address(0x1234567890123456789012345678901234567890)
        ); // Example receiver address
        receiver.transfer(5 * 1e18); // Transfer 5 ETH to the receiver

        // Stop impersonation
        vm.stopPrank();

        // Check the ETH balance of OWNER after the transfer
        uint256 ownerEthBalance = OWNER.balance;
        console.log("OWNER ETH balance after transfer:", ownerEthBalance);

        // Check the ETH balance of the receiver after the transfer
        uint256 receiverEthBalance = receiver.balance;
        console.log(
            "Receiver ETH balance after receiving ETH:",
            receiverEthBalance
        );

        // Assert the balance is correct
        assertEq(
            ownerEthBalance,
            5 * 1e18, // Expecting 5 ETH left in OWNER's balance
            "OWNER ETH balance does not match expected amount after transfer"
        );

        assertEq(
            receiverEthBalance,
            5 * 1e18, // Expecting 5 ETH received by the receiver
            "Receiver ETH balance does not match expected amount after receiving"
        );
    }

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
/*
initial test
  function test_flashloan() public {
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