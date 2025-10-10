require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545", // 本地节点默认端口
    },
    sepolia: {
      url: `https://ethereum-sepolia-rpc.publicnode.com`,
      accounts: ["YOUR_PRIVATE_KEY_HERE"], // 替换为你的私钥
    },
  },
};
