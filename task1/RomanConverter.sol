// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26; 

contract RomanConverter {
    uint256[] nums = [
        1000, 900, 500, 400,
        100, 90, 50, 40,
        10, 9, 5, 4,
        1, 0 // 0作为终止标记
    ];

    string[] romanSymbols = [
        "M", "CM", "D", "CD",
        "C", "XC", "L", "XL",
        "X", "IX", "V", "IV",
        "I", ""
    ];

    mapping (string => int256) public romanValues;
    constructor() {
        romanValues["I"] = 1;
        romanValues["V"] = 5;
        romanValues["X"] = 10;
        romanValues["L"] = 50;
        romanValues["C"] = 100;
        romanValues["D"] = 500;
        romanValues["M"] = 1000;
    }

    function unitToRoman(uint256 _num) public view returns (string memory) {
        require(_num>0 && _num<4000, "Input must be between 1 and 3999");
        string memory result = "";
        for (uint256 i = 0; nums[i] > 0; i++ ) {
            while (_num >= nums[i]){
                result = string(abi.encodePacked(result, romanSymbols[i]));
                _num -= nums[i];
            }
        }
        
        return result;
    }


    // 将罗马数字字符串转换为整数
    function romanToInt(string memory s) public view returns (int256) {
        int256 result = 0;
        bytes memory romanBytes = bytes(s); // 将字符串转换为bytes以访问单个字符
        
        for (uint256 i = 0; i < romanBytes.length; i++) {
            // 获取当前符号的值
            int256 current = romanValues[string(abi.encodePacked(romanBytes[i]))];
            
            // 如果当前符号小于下一个符号，则减去当前值（左减规则）
            if (i < romanBytes.length - 1 && current < romanValues[string(abi.encodePacked(romanBytes[i + 1]))]) {
                result -= current;
            } else {
                // 否则加上当前值（右加规则）
                result += current;
            }
        }
        
        return result;
    }

}

