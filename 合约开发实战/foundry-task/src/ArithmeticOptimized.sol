// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ArithmeticOptimized {
    uint256 public result;
    uint256 public operationCount;
    
    event OperationPerformed(string operation, uint256 a, uint256 b, uint256 result);
    
    function add(uint256 a, uint256 b) public returns (uint256) {
        // 使用unchecked块避免溢出检查
        unchecked {
            result = a + b;
            operationCount++;
        }
        emit OperationPerformed("add", a, b, result);
        return result;
    }
    
    function subtract(uint256 a, uint256 b) public returns (uint256) {
        // 使用unchecked块，手动处理下溢检查
        unchecked {
            require(b <= a, "Subtraction underflow");
            result = a - b;
            operationCount++;
        }
        emit OperationPerformed("subtract", a, b, result);
        return result;
    }
    
    function multiply(uint256 a, uint256 b) public returns (uint256) {
        unchecked {
            result = a * b;
            operationCount++;
        }
        emit OperationPerformed("multiply", a, b, result);
        return result;
    }
    
    function divide(uint256 a, uint256 b) public returns (uint256) {
        unchecked {
            require(b > 0, "Division by zero");
            result = a / b;
            operationCount++;
        }
        emit OperationPerformed("divide", a, b, result);
        return result;
    }
}