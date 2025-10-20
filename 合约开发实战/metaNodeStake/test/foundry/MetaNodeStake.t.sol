// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;
import {Test,console} from "forge-std/Test.sol";
import "../../contracts/MetaNodeStake.sol";
import "../../contracts/MetaNodeToken.sol";
// import {console} from "forge-std/console.sol";

contract MetaNodeStakeTest is Test {
    MetaNodeStake public metaNodeStake;
    MetaNodeToken public metaNodeToken;
    address public admin = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    IERC20 public stToken1;
    IERC20 public stToken2;

    function setUp() public {
        vm.startPrank(admin);
        metaNodeToken = new MetaNodeToken();
        metaNodeStake = new MetaNodeStake();
        metaNodeStake.initialize(metaNodeToken);
        stToken1 = IERC20(metaNodeToken);
        // Mint some tokens to users
        deal(address(stToken1), user1, 1000 ether);
        deal(address(stToken1), user2, 1000 ether);
        metaNodeStake.addPool(address(stToken1), 100, 100, 10);
        vm.stopPrank();
    }
    function testInitialize() public {
        assertEq(address(metaNodeStake.metaNodeToken()), address(metaNodeToken));
        assertEq(metaNodeStake.rewardPerBlock(), 1e18);
        assertTrue(metaNodeStake.hasRole(metaNodeStake.DEFAULT_ADMIN_ROLE(), admin));
        assertTrue(metaNodeStake.hasRole(metaNodeStake.ADMIN_ROLE(), admin));
        assertTrue(metaNodeStake.hasRole(metaNodeStake.UPGRADER_ROLE(), admin));
    }


    function testStake() public {
        vm.startPrank(user1);
        stToken1.approve(address(metaNodeStake), 5 ether);
        metaNodeStake.stake(0, 5 ether);
        vm.stopPrank();

        ( , , , , uint256 stTokenAmount, , ) = metaNodeStake.pools(0);
        assertEq(stTokenAmount, 5 ether);

        (uint256 stAmount, , , ) = metaNodeStake.users(0, user1);
        assertEq(stAmount, 5 ether);
    }

    function testUnstake() public {
        testStake();
        ( , uint256 poolWeight, uint256 lastRewardBlock,uint256 accMetaNodePerST , uint256 stTokenAmount, , ) = metaNodeStake.pools(0);
        console.log("Pool lastRewardBlock before unstake:", lastRewardBlock);
        console.log("Pool poolWeight before unstake:", poolWeight);
        console.log("Pool accMetaNodePerST before unstake:", accMetaNodePerST);
        console.log("Pool stTokenAmount before unstake:", stTokenAmount);
        console.log("bolck.number before unstake:", block.number);
        vm.warp(block.timestamp + 600); // 快进时间以模拟区块增长
        vm.roll(block.number + 100); // 增加100个区块
        console.log("bolck.number after warp and roll:", block.number);
        vm.startPrank(user1);
        metaNodeStake.unstake(0, 2 ether);
        vm.stopPrank();
        (uint256 stAmount, ,uint256 pendingMetaNode, ) = metaNodeStake.users(0, user1);
        console.log("User1 stAmount after unstake:", stAmount);
        console.log("User1 pendingMetaNode after unstake:", pendingMetaNode);
        console.log("meteNodeStake.rewardPerBlock()",metaNodeStake.rewardPerBlock());
        ( , uint256 poolWeight1, uint256 lastRewardBlock1,uint256 accMetaNodePerST1 , uint256 stTokenAmount1, , ) = metaNodeStake.pools(0);
        console.log("Pool lastRewardBlock after unstake:", lastRewardBlock1);
        console.log("Pool poolWeight after unstake:", poolWeight1);
        console.log("Pool accMetaNodePerST after unstake:", accMetaNodePerST1);
        console.log("Pool stTokenAmount after unstake:", stTokenAmount1);
        console.log("bolck.number after unstake:", block.number);
        
        assertEq(stTokenAmount1, 3 ether);
    }

    function testClaim() public {
        testUnstake();
        vm.startPrank(user1);
        metaNodeStake.claim(0);
        vm.stopPrank();

        uint256 userBalance = metaNodeToken.balanceOf(user1);
        console.log("User1 MetaNodeToken Balance:", userBalance);
        assertGt(userBalance, 0);
    }
    function testAddPool() public {
        vm.startPrank(admin);
        metaNodeStake.addPool(address(stToken1), 100, 100, 10);
        vm.stopPrank();
        (IERC20 stTokenAddress, uint256 poolWeight, , , , uint256 minDepositAmount,uint256 unstakeLockedBlocks) = metaNodeStake.pools(0);
        assertEq(address(stTokenAddress), address(stToken1));
        assertEq(poolWeight, 100);
        assertEq(minDepositAmount, 100);
        assertEq(unstakeLockedBlocks, 10);
    }
}