// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract Voting {
    // 版本号，用于重置候选人的得票数
    uint256 version = 1;
    //存储候选人的得票数
    mapping(uint256 => mapping(address => uint256))  candidateToVotes;
    // 一个vote函数，允许用户投票给某个候选人
    function vote(address addr) public {
        candidateToVotes[version][addr]++;  
    }

    // 一个getVotes函数，返回某个候选人的得票数
    function getVotes(address addr) public view returns(uint256) {
        return candidateToVotes[version][addr];
    } 
    // 一个resetVotes函数，重置所有候选人的得票数
    function resetVotes() public {
        version++;
    }
    // 一个getVersion函数，返回当前的版本号
    function getVersion() public view returns(uint256) {
        return version;
    }

    // 字符串反转
    function reverseString(string memory str) public pure returns(string memory) {
        bytes memory bStr = bytes(str);
        for (uint i = 0; i < bStr.length / 2; i++) {
            uint j = bStr.length - 1 - i;
            (bStr[i], bStr[j]) = (bStr[j], bStr[i]);
        }
        return string(bStr);
    }

}