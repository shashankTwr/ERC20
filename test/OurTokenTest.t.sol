// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address sha = makeAddr("sha");
    address han = makeAddr("han");

    uint256 public STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(sha, STARTING_BALANCE);
    }

    function testBalance() public view {
        assertEq(ourToken.balanceOf(sha), STARTING_BALANCE);
    }

    function testAllowances() public {
        // transferFrom
        uint256 initialAllowance = 1000;

        // Han approves Sha to spend tokens on her behalf
        vm.prank(sha);
        ourToken.approve(han, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(han);
        ourToken.transferFrom(sha, han, transferAmount);

        assertEq(ourToken.balanceOf(han), transferAmount);
        assertEq(ourToken.balanceOf(sha), STARTING_BALANCE - transferAmount);
    }

    // Test adjusting allowance with approve and re-approve
    function testAllowanceAdjustment() public {
        uint256 initialAllowance = 1000 ether;
        uint256 newAllowance = 1500 ether;

        // SHA approves HAN to spend tokens on her behalf
        vm.prank(sha);
        ourToken.approve(han, initialAllowance);
        assertEq(ourToken.allowance(sha, han), initialAllowance);

        // SHA increases HAN's allowance
        vm.prank(sha);
        ourToken.approve(han, newAllowance);
        assertEq(ourToken.allowance(sha, han), newAllowance);
    }

    // Test transfer exceeding allowance should revert
    function testTransferExceedingAllowance() public {
        uint256 initialAllowance = 500 ether;
        uint256 transferAmount = 600 ether;

        // SHA approves HAN to spend tokens on her behalf
        vm.prank(sha);
        ourToken.approve(han, initialAllowance);

        // HAN attempts to transfer more than the approved allowance
        // ERC20InsufficientAllowance(han,initialAllowance,transferAmount)
        vm.expectRevert();
        vm.prank(han);
        ourToken.transferFrom(sha, han, transferAmount);
    }

    // Test direct transfer between accounts
    function testDirectTransfer() public {
        uint256 transferAmount = 20 ether;

        // SHA transfers directly to HAN
        vm.prank(sha);
        ourToken.transfer(han, transferAmount);

        // Verify balances after transfer
        assertEq(ourToken.balanceOf(sha), STARTING_BALANCE - transferAmount);
        assertEq(ourToken.balanceOf(han), transferAmount);
    }

    // Test transfer to a zero address should revert
    function testTransferToZeroAddress() public {
        uint256 transferAmount = 10 ether;

        // SHA tries to transfer to zero address
        // "ERC20InvalidReceiver" error
        vm.prank(sha);
        vm.expectRevert();
        ourToken.transfer(address(0), transferAmount);
    }
}
