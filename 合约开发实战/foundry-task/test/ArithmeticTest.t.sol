// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Arithmetic.sol";
import "../src/ArithmeticOptimized.sol";

contract ArithmeticTest is Test {
    Arithmetic public arithmetic;
    
    event OperationPerformed(string operation, uint256 a, uint256 b, uint256 result);
    
    function setUp() public {
        arithmetic = new Arithmetic();
    }
    
    function test_Add() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmetic.add(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 15);
        assertEq(arithmetic.result(), 15);
        
        emit log_named_uint("Gas used for add", gasBefore - gasAfter);
    }

    
    function test_Subtract() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmetic.subtract(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 5);
        assertEq(arithmetic.result(), 5);
        
        emit log_named_uint("Gas used for subtract", gasBefore - gasAfter);
    }
    
    function test_Multiply() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmetic.multiply(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 50);
        assertEq(arithmetic.result(), 50);
        
        emit log_named_uint("Gas used for multiply", gasBefore - gasAfter);
    }
    
    function test_DivideOptimized() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmetic.divide(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 2);
        assertEq(arithmetic.result(), 2);
        
        emit log_named_uint("Gas used for divide", gasBefore - gasAfter);
    }
}