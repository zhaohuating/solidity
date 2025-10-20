// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {console} from "forge-std/Test.sol";

contract MetaNodeStake is Initializable, AccessControlUpgradeable, UUPSUpgradeable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    IERC20 public metaNodeToken;
    uint256 public rewardPerBlock; // 每区块奖励
    uint256 public totalWeights; // 总权重
    uint256 public constant ST_TOKEN_SIZE = 1e18; // 单位代币大小
    struct Pool {
        IERC20 stTokenAddress;
        uint256 poolWeight;
        uint256 lastRewardBlock;
        uint256 accMetaNodePerST;
        uint256 stTokenAmount;
        uint256 minDepositAmount;
        uint256 unstakeLockedBlocks;
    }

    struct User {
        uint256 stAmount;
        uint256 finishedMetaNode;
        uint256 pendingMetaNode;
        uint256 lastStakeBlock;// 最后一次质押的区块高度
    }

    Pool[] public pools;
    mapping(uint256 => mapping(address => User)) public users;

    bool public stakePaused;
    bool public unstakePaused;
    bool public claimPaused;

    event Staked(address indexed user, uint256 indexed pid, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed pid, uint256 amount);
    event Claimed(address indexed user, uint256 indexed pid, uint256 amount);
    event PoolAdded(uint256 indexed pid, address stTokenAddress, uint256 poolWeight, uint256 minDepositAmount, uint256 unstakeLockedBlocks);
    event PoolUpdated(uint256 indexed pid, uint256 poolWeight, uint256 minDepositAmount, uint256 unstakeLockedBlocks);

    function initialize(IERC20 _metaNodeToken) public initializer {
        metaNodeToken = _metaNodeToken;
        rewardPerBlock = ST_TOKEN_SIZE; // 每区块奖励1个MetaNodeToken
        // 初始化合约时，将部署者设置为默认管理员、管理员和升级角色
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADER_ROLE, msg.sender);
    }

      /**
     * @notice 授权合约升级逻辑
     * @dev 只有具有 UPGRADE_ROLE 的角色可以调用此函数
     * @param newImplementation 新合约实现的地址
     * @custom:requirements 调用者必须具有 UPGRADE_ROLE 权限
     */
    function _authorizeUpgrade(address newImplementation)
        internal
        onlyRole(UPGRADER_ROLE)
        override
    {

    }

    modifier onlyAdmin() {
        require(hasRole(ADMIN_ROLE, msg.sender), "Caller is not an admin");
        _;
    }
    modifier onlyUpgrader() {
        require(hasRole(UPGRADER_ROLE, msg.sender), "Caller is not an upgrader");
        _;
    }
    // 质押池是否存在
    modifier poolExists(uint256 _pid) {
        require(_pid < pools.length, "Pool does not exist");
        _;
    }
    // 质押功能检查
    modifier whenStakeNotPaused() {
        require(!stakePaused, "Staking is paused");
        _;
    }
    /**
     * @notice 用户质押代币到指定池
     * @param _pid 池ID
     * @param _amount 质押的代币数量
     * @dev 前置条件：质押功能未暂停，且质押金额满足最小要求
     * @dev 后置条件：更新用户质押状态和池的总质押量
     */
    function stake(uint256 _pid, uint256 _amount) external poolExists(_pid) whenStakeNotPaused() nonReentrant() payable {
        require(_amount > 0, "Amount must be greater than zero");
        require(_amount >= pools[_pid].minDepositAmount, "Amount below minimum deposit");

        Pool storage pool = pools[_pid];
        User storage user = users[_pid][msg.sender];
        updatePool(_pid);
        // 计算并累加未领取的奖励
        if (user.stAmount > 0) {
            uint256 pending = user.stAmount * pool.accMetaNodePerST / ST_TOKEN_SIZE - user.finishedMetaNode;
            if (pending > 0) {
                user.pendingMetaNode += pending;
            }
        }

        // 处理质押逻辑
        if (address(pool.stTokenAddress) == address(0)) {
            require(msg.value == _amount, "Invalid native token amount");
        } else {
            pool.stTokenAddress.safeTransferFrom(msg.sender, address(this), _amount);
        }
        user.stAmount += _amount;
        user.lastStakeBlock = block.number;
        pool.stTokenAmount += _amount;

        emit Staked(msg.sender, _pid, _amount);
    }

    /**
     * @notice 用户解除质押
     * @param _pid 池ID
     * @param _amount 解除质押的代币数量
     * @dev 前置条件：解除质押功能未暂停，且用户质押数量足够
     * @dev 后置条件：记录解除质押请求，等待锁定期结束后可提取
     */
    function unstake(uint256 _pid, uint256 _amount) external nonReentrant() poolExists(_pid) {
        require(!unstakePaused, "Unstaking is paused");
        User storage user = users[_pid][msg.sender];
        require(user.stAmount >= _amount, "Insufficient staked amount");
        require(user.lastStakeBlock + pools[_pid].unstakeLockedBlocks <= block.number, "Unstake locked");

        Pool storage pool = pools[_pid];
        updatePool(_pid);

        // 计算并累加未领取的奖励
        uint256 pending = user.stAmount * pool.accMetaNodePerST / ST_TOKEN_SIZE - user.finishedMetaNode;
        if (pending > 0) {
            user.pendingMetaNode += pending;
        }

        // 更新质押状态并记录解除质押请求
        user.stAmount -= _amount;
        pool.stTokenAmount -= _amount;
        if (address(pool.stTokenAddress) == address(0)) {
            (bool success, ) = msg.sender.call{value: _amount}("");
            require(success, "Native token transfer failed");
        } else {
            pool.stTokenAddress.safeTransfer(msg.sender, _amount);
        }

        emit Unstaked(msg.sender, _pid, _amount);
    }

    /**
     * @notice 用户领取奖励
     * @param _pid 池ID
     * @dev 前置条件：领取功能未暂停，且有可领取的奖励
     * @dev 后置条件：清除用户的待领取奖励记录
     */
    function claim(uint256 _pid) external nonReentrant() poolExists(_pid) {
        require(!claimPaused, "Claiming is paused");
        User storage user = users[_pid][msg.sender];
        uint256 pendingMetaNode = user.pendingMetaNode;
        require(pendingMetaNode > 0, "No pending rewards");

        // 更新奖励状态
        user.pendingMetaNode = 0;
        user.finishedMetaNode += pendingMetaNode;

        // 实际奖励代币转移到用户账户
        IERC20(metaNodeToken).safeTransfer(msg.sender, pendingMetaNode);

        emit Claimed(msg.sender, _pid, pendingMetaNode);
    }

    function addPool(
        address _stTokenAddress,
        uint256 _poolWeight,
        uint256 _minDepositAmount,
        uint256 _unstakeLockedBlocks
    ) external onlyRole(ADMIN_ROLE) {
        pools.push(Pool({
            stTokenAddress: IERC20(_stTokenAddress),
            poolWeight: _poolWeight,
            lastRewardBlock: block.number,
            accMetaNodePerST: 0,
            stTokenAmount: 0,
            minDepositAmount: _minDepositAmount,
            unstakeLockedBlocks: _unstakeLockedBlocks
        }));

        totalWeights += _poolWeight;
        emit PoolAdded(pools.length - 1, _stTokenAddress, _poolWeight, _minDepositAmount, _unstakeLockedBlocks);
    }

    function updatePoolSetting(
        uint256 _pid,
        uint256 _poolWeight,
        uint256 _minDepositAmount,
        uint256 _unstakeLockedBlocks
    ) external onlyRole(ADMIN_ROLE) {
        Pool storage pool = pools[_pid];
        totalWeights = totalWeights - pool.poolWeight + _poolWeight;
        pool.poolWeight = _poolWeight;
        pool.minDepositAmount = _minDepositAmount;
        pool.unstakeLockedBlocks = _unstakeLockedBlocks;

        emit PoolUpdated(_pid, _poolWeight, _minDepositAmount, _unstakeLockedBlocks);
    }

    function updatePool(uint256 _pid) internal {
        require(totalWeights > 0, "No active pools");

        Pool storage pool = pools[_pid];
        require(block.number >= pool.lastRewardBlock, "Pool is not ready");
        if (pool.stTokenAmount == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 blocksPassed = block.number - pool.lastRewardBlock;
        uint256 metaNodeReward = (blocksPassed * pool.poolWeight) / totalWeights;
        pool.accMetaNodePerST += (metaNodeReward * rewardPerBlock) / pool.stTokenAmount;
        pool.lastRewardBlock = block.number;
    }

    function setStakePaused(bool _paused) external onlyRole(ADMIN_ROLE) {
        stakePaused = _paused;
    }

    function setUnstakePaused(bool _paused) external onlyRole(ADMIN_ROLE) {
        unstakePaused = _paused;
    }

    function setClaimPaused(bool _paused) external onlyRole(ADMIN_ROLE) {
        claimPaused = _paused;
    }

    function getPoolLength() external view returns (uint256) {
        return pools.length;
    }
}