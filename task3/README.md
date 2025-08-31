# NFT 拍卖合约项目

## 项目简介

本项目实现了基于以太坊的NFT拍卖合约系统，包含基础的NFT拍卖功能及合约升级机制。项目使用Hardhat作为开发框架，结合OpenZeppelin的升级插件实现UUPS代理模式的可升级合约。

## 技术栈

- Solidity 0.8.28（智能合约开发语言）
- Hardhat（以太坊开发环境）
- OpenZeppelin Contracts & Contracts-Upgradeable（智能合约开发库）
- hardhat-deploy（部署管理工具）
- @openzeppelin/hardhat-upgrades（合约升级插件）

## 项目结构

```
task3/
├── contracts/               # 智能合约源代码
├── deploy/                  # 部署脚本
│   ├──.cache/                  # 缓存目录(自动生成)
│   ├── 01_deploy_nft_auction.js        # NFT拍卖合约部署脚本   
│   ├── 01_deploy_nft_auction.js        # NFT拍卖合约部署脚本
│   ├── 01_deploy_nft_auction_factory.js # NFT拍卖工厂合约部署脚本
│   ├── 01_upgrade_nft_auction.js       # NFT拍卖合约升级脚本
│   └── 01_upgrade_nft_auction_factory.js # NFT拍卖工厂合约升级脚本
├── test/                    # 测试文件
│   └── index.js             # 基础测试脚本
├── hardhat.config.js        # Hardhat配置文件
├── package.json             # 项目依赖配置
```

## 快速开始

### 前置要求

- Node.js (v14+)
- npm 或 yarn

### 安装依赖

```bash
npm install
# 或
yarn install
```

### 编译合约

```bash
npm run compile
```

### 清理编译缓存

```bash
npm run clean
```

### 部署合约

在本地测试网部署NFT拍卖合约：

```bash
npm run deploy
```

### 升级合约

升级已部署的NFT拍卖合约：

```bash
npm run upgrade
```

### 运行测试

```bash
npm run test
```

## 合约部署与升级说明

本项目采用UUPS代理模式实现合约可升级性，主要包含以下核心功能：

1. **部署流程**：
   - 通过OpenZeppelin的`deployProxy`函数部署代理合约
   - 同时部署实现合约并完成初始化
   - 保存代理地址和实现地址到缓存文件

2. **升级流程**：
   - 通过代理地址找到已部署的代理合约
   - 使用`upgradeProxy`函数升级到新的实现合约
   - 更新缓存文件中的实现地址信息

3. **部署与升级标签**：
   - 部署NFT拍卖合约：`deploy_nft_auction`
   - 部署NFT拍卖工厂合约：`deploy_nft_auction_factory`
   - 升级NFT拍卖合约：`upgrade_nft_auction`
   - 升级NFT拍卖工厂合约：`upgrade_nft_auction_factory`

## 注意事项

- 确保在部署前配置正确的网络信息（在`hardhat.config.js`的`networks`部分）
- 合约升级前请仔细测试新的实现合约，确保与旧版本兼容
- 缓存文件(.cache目录)记录了代理地址和实现地址，请勿手动修改

## 扩展开发

1. 新增功能可通过创建V3版本合约实现
2. 参照现有升级脚本编写新的升级脚本
3. 扩展测试用例确保新功能正常工作