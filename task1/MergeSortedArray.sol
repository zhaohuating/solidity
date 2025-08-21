// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
contract MergeSortedArray {
    uint256[] arr1 = [1,3,4,5,6];
    uint256[] arr2 = [2,4,5,7,8];
    uint256[] public arr3 = new uint256[](arr1.length + arr2.length);


    function merge() public returns (uint256[] memory){
        uint256 i = 0;
        uint256 j = 0;
        uint256 k = 0;

        while (i < arr1.length && j < arr2.length) {
            if (arr1[i] < arr2[j]) {
                arr3[k] = arr1[i];
                i++;
            } else {
                arr3[k] = arr2[j];
                j++;
            }
            k++;
        }
        while (i < arr1.length) {
            arr3[k] = arr1[i];
            i++;
            k++;
        }
        while (j < arr2.length) {
            arr3[k] = arr2[j];
            j++;
            k++;
        }

        return arr3;
    }

    function getArr3() public view returns (uint256[] memory){
        return arr3;
    }

}