// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/access/Ownable.sol";

contract BeggingContract is Ownable {
    // 捐款总额
    uint256 public totalDonations;
    // 捐款top3
    address[] public topDonors;
    //捐赠开始时间
    uint256 startTime; 
    // 捐赠结束时间
    uint256 endTime;
    // 捐款信息
    mapping(address => uint256) donations;
    // 记录每次捐赠的地址和金额。
    event DonationReceived(address donor, uint256 amount);

    constructor() Ownable(msg.sender) {
        startTime =block.timestamp; // 合约部署即开始捐赠
        endTime = startTime + 3 days ; // 3天后结束
    }

    //是否开始捐赠
    modifier isDonationActive() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Donation period is over");
        _;
    }

    // 捐赠
    function donate() external payable isDonationActive {
        uint256 amount = msg.value;
        require(amount > 0, "Donation amount must be greater than 0");
        totalDonations += amount;
        donations[msg.sender] += amount;
        isTopDonor(msg.sender);
        emit DonationReceived(msg.sender, amount);
    }

    // 判断是否是前三名
    function isTopDonor(address donor) private returns (bool) {
        if (topDonors.length < 4) {
            topDonors.push(donor);
            return true;
        }
        uint256 amount = donations[donor];

        for (uint8 i = 0; i < 3; i++) {
            uint256 topAmount = donations[topDonors[i]];
            if (amount > topAmount) {
                topDonors[i] = donor;
                return true;
            }
        }

        return false;
    }

    // 拥有者提取所有捐赠
    function withdraw() external payable onlyOwner { 
        require(totalDonations > 0,"totalDonations eques 0 ");
        payable(owner()).transfer(totalDonations);
        totalDonations = 0;
    }
    
    // 获取捐赠
    function getDonation(address donor) external view returns (uint256) {
        return donations[donor];
    }

    //获取合约地址
    function getContractAddress() external view returns (address) {
        return address(this);
    }    

}