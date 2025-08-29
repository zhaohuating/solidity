// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./NFTAuctionFactory.sol";
contract NFTAuctionFactoryV2 is NFTAuctionFactory {

    function version() public pure returns (string memory) {
        return "v2.0";
    }

    function sayHello() public pure returns (string memory) {
        return "Hello from NFTAuctionFactoryV2!";
    }
}