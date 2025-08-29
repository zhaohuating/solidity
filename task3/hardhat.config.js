require("@nomicfoundation/hardhat-toolbox");
require("hardhat-deploy");
require("@openzeppelin/hardhat-upgrades")

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  namedAccounts: {
    deployer: 0,
    user1: 1,
    user2: 2
  },
  // networks: {
  //   hardhat: {
  //     chainId: 1337, // 设置链ID以避免与MetaMask冲突
  //   },
  // },
  paths: {
    sources: "./contracts", // 合约文件夹
    tests: "./test", // 测试文件夹
    cache: "./cache", // 缓存文件夹
    artifacts: "./artifacts", // 构建文件夹
    deploy: "./deploy" // 部署脚本文件夹
  }    
};
