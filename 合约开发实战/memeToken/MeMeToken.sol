// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract MeMeToken is ERC20, Ownable {
    IUniswapV2Router02 public immutable uniswapRouter;
    uint256 private initialSupply = 1e18 * 1e18;
    uint256 public _totalSupply;
    uint256 public liquidityLock;   
    uint256 public constant DEFAULT_MAX_DAY_AMOUNT = 1000 * 1e18;
    uint8 public constant DEFAULT_MAX_DAY_COUNT = 20;
    address public _owner;
    mapping(address => TradeCounter) public tradeRecords;
    mapping(address => TradeCounter) public defaultTradeRecord;

    struct TradeCounter {
        uint256 day;
        uint256 amount;
        uint256 maxDayAmount;
        uint8 count;
        uint8 maxDayCount;
    }

    event LiquidityAdded(uint256 tokenAmount, uint256 ethAmount, uint256 liquidity);
    event LiquidityRemoved(address token, uint256 tokenAmount, uint256 ethAmount, uint256 liquidity);

    constructor(address _uniswapRouter) ERC20("MeMeToken", "MMT") Ownable(_msgSender()) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        _owner = _msgSender();
        _totalSupply = initialSupply;
        _mint(_msgSender(), initialSupply);
        emit Transfer(address(0), _msgSender(), initialSupply);
    }

    modifier checkTransferLimit(address addr, uint256 amount) {
        uint256 today = block.timestamp / 1 days;
        if (defaultTradeRecord[addr].day == 0) {
            TradeCounter memory tc = TradeCounter({
                day: today,
                amount: 0,
                maxDayAmount: DEFAULT_MAX_DAY_AMOUNT,
                count: 0,
                maxDayCount: DEFAULT_MAX_DAY_COUNT
            });
            defaultTradeRecord[addr] = tc;
            tradeRecords[addr] = tc;
        }
        if (tradeRecords[addr].day < today) {
            defaultTradeRecord[addr].day = today;
            tradeRecords[addr] = defaultTradeRecord[addr];
        }
        require(tradeRecords[addr].day == today, "Daily trading limit reset failed");
        require(tradeRecords[addr].count < tradeRecords[addr].maxDayCount, "Daily trading limit reached");
        require(tradeRecords[addr].amount + amount <= tradeRecords[addr].maxDayAmount, "Daily trade amount limit exceeded");
        _;
        tradeRecords[addr].count += 1;
        tradeRecords[addr].amount += amount;
    }

    function transfer(address to, uint256 amount) public override checkTransferLimit(_msgSender(), amount) returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf(msg.sender), "ERC20: insufficient balance");
        uint256 tax = amount * 5 / 1000;  // 0.5% 税费
        _transfer(msg.sender, to, amount - tax);
        _transfer(msg.sender, address(this), tax);
        emit Transfer(msg.sender, to, amount - tax);
        return true;
    }

    /// @notice 添加流动性（支持 ETH）
    function addLiquidity(uint256 tokenAmount, uint256 ethAmount) public payable {
        require(msg.value == ethAmount, "ETH amount mismatch");
        _approve(address(this), address(uniswapRouter), tokenAmount);
        (,, uint256 liquidity) = uniswapRouter.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            tokenAmount * 95 / 100,
            ethAmount * 95 / 100,
            msg.sender,
            block.timestamp + 600
        );
        emit LiquidityAdded(tokenAmount, ethAmount, liquidity);
    }

    /// @notice 移除流动性（返回 ETH 和 Token）
    function removeLiquidity(uint256 liquidity) public returns (uint256 tokenAmount, uint256 ethAmount) {
        require(block.timestamp >= liquidityLock, "Liquidity is locked");
        (tokenAmount, ethAmount) = uniswapRouter.removeLiquidityETH(
            address(this),
            liquidity,
            0,
            0,
            msg.sender,
            block.timestamp + 600
        );
        emit LiquidityRemoved(address(this), tokenAmount, ethAmount, liquidity);
        return (tokenAmount, ethAmount);
    }

        /// @notice 锁定流动性
    function lockLiquidity(uint256 daysToLock) external onlyOwner {
        require(daysToLock <= 365, "Lock period too long");
        liquidityLock = block.timestamp + daysToLock * 1 days;
    }

}