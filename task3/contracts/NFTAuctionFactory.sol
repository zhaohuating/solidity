// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;
import "./interface/INFTAuction.sol";
import "./NFTAuction.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
contract NFTAuctionFactory is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable
{
    address public auctionImpl; // 当前拍卖逻辑实现
    address[] public allAuctions; // 所有拍卖合约地址

    function initialize(address _auctionImpl) public initializer {
        __Ownable_init(msg.sender);
        __UUPSUpgradeable_init();
        auctionImpl = _auctionImpl;
    }

    function createAuction(
        address _tokenAddress,
        address _nftAddress, 
        uint256 _tokenID, 
        uint256 _duration,
        // 起拍价
        uint256 _minBid) external returns (address) {
        // 使用代理模式创建新的NFTAuction合约实例
        address proxy = address(new ERC1967Proxy(auctionImpl, 
        abi.encodeWithSelector(NFTAuction.initialize.selector, msg.sender,_nftAddress,_tokenID,_minBid, _duration)));
        INFTAuction(proxy).createAuction(_tokenAddress,_nftAddress, _tokenID, _duration, _minBid);
        allAuctions.push(proxy);

        return proxy;
    }

    /// @dev 升级全局实现合约（仅 owner）
    function upgradeAuctionImpl(address newImpl) external onlyOwner {
        auctionImpl = newImpl;
    }

    /// @dev 查询已创建的拍卖总数
    function auctionsLength() external view returns (uint256) {
        return allAuctions.length;
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal virtual override {}
}