// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract BinarySearch {
    function binarySearch(uint256[] memory arr, uint256 targe) public pure returns (int256) {
    uint256 left = 0;
    uint256 right = arr.length-1;
    uint256 mid;
        
    while (left <= right) {
        mid = left +(right - left ) / 2;
        if (targe == arr[mid]) {
            return int256(mid);
        } else if (targe > arr[mid]) {
            left = mid + 1;
        } else {
            right = mid - 1;
        }
    }
        return -1;
    }
}