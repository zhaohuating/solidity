# MetaNodeStake

## 项目概述

**MetaNodeStake** 是一个基于智能合约的质押系统，支持代币质押、奖励分配和合约升级。项目采用 Solidity 编写，结合 Hardhat 开发框架和 OpenZeppelin 库，确保安全性和可维护性。

## 核心合约

1. **MetaNodeStake.sol**  
   主逻辑合约，实现质押和奖励计算功能。
3. **MetaNodeToken.sol**  
   ERC20 代币合约，用于质押和奖励分配。

## 功能特性

- **质押机制**：用户质押代币后，按规则获得奖励。
- **可升级性**：通过代理模式（Proxy Pattern）支持合约逻辑升级，无需迁移数据。
- **权限管理**：关键操作（如升级、奖励分配）需管理员权限，防止恶意调用。

## 快速开始

### 安装依赖
```bash
npm install
```

### 部署合约
```bash
npx hardhat run scripts/deploy.js --network <network-name>
```

### 运行测试
```bash
npx hardhat test
```

## 安全与最佳实践

- **代理模式**：使用 OpenZeppelin 的 `ERC1967Proxy`，确保升级时状态数据保留。
- **初始化保护**：逻辑合约的 `initialize` 函数仅能调用一次，防止重复初始化攻击。
- **权限隔离**：通过 `AccessControl` 实现角色管理，限制关键操作权限。

## 贡献与支持

欢迎提交 Issue 或 Pull Request 改进项目

## 许可证

MIT License