// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
interface INFTAuction {
    function createAuction(
        address _nftAddress, 
        uint256 _tokenID, 
        uint256 _duration,
        // 起拍价
        uint256 _minBid
        )  external;
    // 出价
    function bid(uint256 _auctionId) external payable;
    //卖家取消竞拍
    function cancelAuction(uint256 _auctionId) external;
     // 结束竞拍
    function endAuction(uint256 _auctionId) external;
    // 卖家提取资金
    function sellerWithdraw(uint256 _auctionId) external;

    
}