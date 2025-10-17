// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Stake {
    address public owner;
    uint256 public totalStaked;
    uint256 public totalUnstaked;
    uint256 public totalRewards;

    mapping(address => uint256) public stakedBalances;
    mapping(address => uint256) public unstakedBalances;

    constructor() {
        owner = msg.sender;
    }
    // Function to stake tokens
    function stake(address token,uint256 amount) external returns (bool success) {
        require(amount > 0, "Amount must be greater than 0");
        success = IERC20(token).transferFrom(msg.sender, address(this), amount);
        stakedBalances[msg.sender] += amount;
        totalStaked += amount;
    }   
    // Function to unstake tokens
    function unstake(address token,uint256 amount) external returns (bool success) {
        require(amount > 0, "Amount must be greater than 0");
        require(stakedBalances[msg.sender] >= amount, "Insufficient staked balance");
        stakedBalances[msg.sender] -= amount;
        unstakedBalances[msg.sender] += amount;
        totalUnstaked += amount;
        success = IERC20(token).transfer(msg.sender, amount);
    }

    // get staked balance of a user
    function getStakedBalance(address user) external view returns (uint256) {
        return stakedBalances[user];
    }
}