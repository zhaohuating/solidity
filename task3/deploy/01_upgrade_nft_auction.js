const {deployments, ethers, upgrades } = require("hardhat");
const fs   = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts();

    /* 1. 读取缓存里的代理地址 */
  const _NFTAuctionProxyObj = await deployments.get("NFTAuctionProxy");
  const NFTAuctionProxy = _NFTAuctionProxyObj.address
  /* 2. 升级代理（OpenZeppelin 插件一次性完成） */
  const NFTAuctionV2 = await ethers.getContractFactory("NFTAuctionV2");
  const proxy = await upgrades.upgradeProxy(NFTAuctionProxy, NFTAuctionV2, { deployer });
  await proxy.waitForDeployment();

  const newImpl = await upgrades.erc1967.getImplementationAddress(NFTAuctionProxy);
  console.log("新逻辑地址:", newImpl);
  console.log("代理地址不变:", NFTAuctionProxy);

  /* 3. 让 hardhat-deploy 也记录一份 ABI 与地址 */
  const artifact = await deployments.getArtifact("NFTAuctionV2");
  await deployments.save("NFTAuctionV2", {
    address: NFTAuctionProxy, // 代理地址
    abi:     artifact.abi
  });

  /* 4. 可选：更新缓存文件 */
  const cacheDir  = path.resolve(__dirname, ".cache");
  if (!fs.existsSync(cacheDir)) fs.mkdirSync(cacheDir, { recursive: true });
  fs.writeFileSync(
    path.join(cacheDir, "NFTAuctionV2.json"),
    JSON.stringify(
      {
        NFTAuction: newImpl,
        NFTAuctionProxy
      },
      null,
      2
    )
  );

  console.log("✅ 升级完成！");
};

module.exports.tags = ["upgrade_nft_auction"];