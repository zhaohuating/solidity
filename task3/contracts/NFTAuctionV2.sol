// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./NFTAuction.sol";

contract NFTAuctionV2 is NFTAuction {
    function version() public pure returns (string memory) {
        return "v2.0";
    }

    function sayHello() public pure returns (string memory) {
        return "Hello from NFTAuctionV2!";
    }
}   