// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/Arithmetic.sol";
import "../src/ArithmeticOptimized.sol";

contract ArithmeticOptimizedTest is Test {
    ArithmeticOptimized public arithmeticOptimized;
    
    event OperationPerformed(string operation, uint256 a, uint256 b, uint256 result);
    
    function setUp() public {
        arithmeticOptimized = new ArithmeticOptimized();
    }

    function test_AddOptimized() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmeticOptimized.add(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 15);
        assertEq(arithmeticOptimized.result(), 15);
        
        emit log_named_uint("Gas used for add", gasBefore - gasAfter);
    }

    function test_SubtractOptimized() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmeticOptimized.subtract(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 5);
        assertEq(arithmeticOptimized.result(), 5);
        
        emit log_named_uint("Gas used for subtract", gasBefore - gasAfter);
    }

    function test_MultiplyOptimized() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmeticOptimized.multiply(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 50);
        assertEq(arithmeticOptimized.result(), 50);
        
        emit log_named_uint("Gas used for multiply", gasBefore - gasAfter);
    }
    
    function test_DivideOptimizedOptimized() public {
        uint256 gasBefore = gasleft();
        uint256 result = arithmeticOptimized.divide(10, 5);
        uint256 gasAfter = gasleft();
        
        assertEq(result, 2);
        assertEq(arithmeticOptimized.result(), 2);
        
        emit log_named_uint("Gas used for divide", gasBefore - gasAfter);
    }
}