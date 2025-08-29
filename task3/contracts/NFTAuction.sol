// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "./interface/INFTAuction.sol";

contract NFTAuction is Initializable, UUPSUpgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable, INFTAuction {
    struct Auction {
        // 卖家
        address seller;
        // NFT合约地址
        address nftAddress;
        // NFT的tokenId
        uint256 tokenId;
        // 最小出价
        uint256 minBid;
        // 最高出价
        uint256 highestBid;
        // 最高出价者
        address highestBidder;
        // 竞拍结束时间
        uint256 endTime;
        // 竞拍是否结束
        bool ended;
        // 持续时间
        uint256 duration;
        // 资产类型
        address tokenAddress;
        // 卖家是否提取了资金
        bool sellerWithdrawn;
    }
    mapping(uint256 => Auction) public auctions;
    uint256 public auctionCount;
    // 手续费
    
    function _authorizeUpgrade(address newImplementation) internal view override onlyOwner {
        require(newImplementation != address(0), "Invalid implementation address");
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _seller,
        address _nftContract,
        uint256 _tokenId,
        uint256 _startPrice,
        uint256 _duration) public initializer {
        __Ownable_init(_seller);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        createAuction(_nftContract, _tokenId, _duration, _startPrice);

    }
    // 新建竞拍
    function createAuction(
        address _nftAddress, 
        uint256 _tokenID, 
        uint256 _duration,
        // 起拍价
        uint256 _minBid
        )  internal {
        //检查NFT合约地址是否有效
        require(_nftAddress != address(0), "Invalid NFT contract address");
        //检查NFT的tokenId是否有效
        require(_tokenID >= 0, "Invalid token ID");
        //检查竞拍持续时间是否有效
        require(_duration * 60 * 1000 > 10 minutes, "Duration must be greater than 10 minutes");
        //检查起拍价是否有效
        require(_minBid > 0, "Minimum bid must be greater than 0");

        // 将NFT转移到合约地址
        IERC721 nftContract = IERC721(_nftAddress);
        nftContract.transferFrom(owner(), address(this), _tokenID);
        // 创建竞拍
        auctionCount++;
        auctions[auctionCount] = Auction({
            seller: msg.sender,
            nftAddress: _nftAddress,
            tokenId: _tokenID,
            minBid: _minBid,
            highestBid: 0,
            highestBidder: address(0),
            endTime: block.timestamp + _duration,
            ended: false,
            duration: _duration,
            tokenAddress: address(0),
            sellerWithdrawn: false
        });
    }

    // 出价
    function bid(uint256 _auctionId) external payable nonReentrant {
        Auction storage auction = auctions[_auctionId];
        // 检查竞拍是否存在
        require(auction.seller != address(0), "Auction does not exist");
        // 检查竞拍是否结束
        require(block.timestamp < auction.endTime, "Auction has ended");
        // 检查出价是否高于最低出价和当前最高出价
        require(msg.value >= auction.minBid, "Bid must be at least the minimum bid");
        require(msg.value > auction.highestBid, "Bid must be higher than current highest bid");
        // 退还之前的最高出价者
        if (auction.highestBidder != address(0)) {
            payable(auction.highestBidder).transfer(auction.highestBid);
        }
        // 更新最高出价和最高出价者
        auction.highestBid = msg.value;
        auction.highestBidder = msg.sender;
    }

    //卖家取消竞拍
    function cancelAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        // 检查竞拍是否存在
        require(auction.seller != address(0), "Auction does not exist");
        // 检查调用者是否是卖家
        require(msg.sender == auction.seller, "Only the seller can cancel the auction");
        // 检查竞拍是否已经结束
        require(!auction.ended, "Auction has already ended");
        // 检查是否有出价
        require(auction.highestBidder == address(0), "Cannot cancel auction with bids");
        // 标记竞拍为结束
        auction.ended = true;
        // 转移NFT回卖家
        IERC721 nftContract = IERC721(auction.nftAddress);
        nftContract.transferFrom(address(this), auction.seller, auction.tokenId); 
    }

    // 结束竞拍
    function endAuction(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        // 检查竞拍是否存在
        require(auction.seller != address(0), "Auction does not exist");
        // 检查竞拍是否结束
        require(block.timestamp >= auction.endTime, "Auction has not ended yet");
        // 检查竞拍是否已经结束
        require(!auction.ended, "Auction has already been ended");
        // 标记竞拍为结束
        auction.ended = true;
        // 如果有出价，转移NFT给最高出价者
        if (auction.highestBidder != address(0)) {
            IERC721 nftContract = IERC721(auction.nftAddress);
            nftContract.transferFrom(address(this), auction.highestBidder, auction.tokenId);    
        } else {
            // 如果没有出价，转移NFT回卖家
            IERC721 nftContract = IERC721(auction.nftAddress);
            nftContract.transferFrom(address(this), auction.seller, auction.tokenId); 
        }
    }

    // 卖家提取资金
    function sellerWithdraw(uint256 _auctionId) external {
        Auction storage auction = auctions[_auctionId];
        // 检查竞拍是否存在
        require(auction.seller != address(0), "Auction does not exist");
        // 检查竞拍是否已经结束
        require(auction.ended, "Auction has not ended yet");
        // 检查调用者是否是卖家
        require(msg.sender == auction.seller, "Only the seller can withdraw funds");
        // 检查卖家是否已经提取了资金
        require(!auction.sellerWithdrawn, "Seller has already withdrawn funds");
        // 标记卖家已经提取了资金
        auction.sellerWithdrawn = true;
        // 如果有出价，转移资金给卖家
        if (auction.highestBidder != address(0)) {
            // todo 需要考虑手续费问题
            uint256 fee = calcFee(auction.highestBid);
            // 转移手续费给合约拥有者
            (bool feeSuccess, ) = payable(owner()).call{value: fee}("");
            require(feeSuccess, "Transfer of fee failed");
            // 转移剩余资金给卖家
            (bool success, ) = payable(auction.seller).call{value: auction.highestBid - fee}("");
            require(success, "Transfer to seller failed");
        } else {
            // 如果没有出价，卖家无需提取资金
            revert("No funds to withdraw");
        }
    }

    
    /**
     * @dev 计算手续费，分段计算
     * 0-1 ETH 区间，手续费 2 %
     * 1-10 ETH 区间，手续费 1.5 %
     * ≥10 ETH 区间，手续费 1 %
     * @param amount 计算手续费的金额（单位为wei）
     */
    function calcFee(uint256 amount) internal pure returns (uint256 fee) {
        uint256 DENOM = 1_000_000;
        // 0-1 ETH 区间
        if (amount < 1 ether) {
            fee = amount * 20_000 / DENOM; // 2 %
        }
        // 1-10 ETH 区间
        else if (amount < 10 ether) {
            fee = amount * 15_000 / DENOM; // 1.5 %
        }
        // ≥10 ETH 区间
        else {
            fee = amount * 10_000 / DENOM; // 1 %
        }
    }


    function sayHello(string memory name) public pure returns (string memory) {
        return string(abi.encodePacked("Hello, ", name, "! This is NFTAuctionV2"));
    } 
    
}