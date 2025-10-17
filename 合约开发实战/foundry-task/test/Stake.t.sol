// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {MockToken} from "../test/mocks/MockToken.sol";
import {Stake} from "../src/Stake.sol";

contract StakeTest is Test {
    MockToken public token;
    Stake public stake;

    function setUp() public {
        token = new MockToken(10000*10**18, "MockToken", 18, "MTK");
        stake = new Stake();
    }

    function test_stake() public {
        uint256 amount = 1 ether;
        token.approve(address(stake), amount);
        bool success = stake.stake(address(token), amount);
        assertTrue(success);
        assertEq(token.balanceOf(address(this)), 1 ether, "Sender's token balance should be 1 ether after staking");
        assertEq(token.balanceOf(address(stake)), amount, "Stake contract's token balance should be equal to staked amount");
        assertEq(stake.getStakedBalance(address(this)), amount, "Staked balance should be equal to staked amount");
    }

    
}
