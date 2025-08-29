const { ethers, upgrades } = require("hardhat");
const { deployments } = require("hardhat"); // 为了 deployments.save
const fs   = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts }) => {

  const IMPLEMENTATION_SLOT = "0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc";
const storage = await ethers.provider.getStorage("0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512", IMPLEMENTATION_SLOT);
console.log("impl slot raw", storage);
console.log("impl address", ethers.getAddress("0x" + storage.slice(-40)));


const { deployer } = await getNamedAccounts();
    /* 1. 读取缓存里的代理地址 */
  const _NFTAuctionProxyObj = await deployments.get("NFTAuctionFactoryProxy");
  const NFTAuctionFactoryProxy = _NFTAuctionProxyObj.address

  /* 2. 升级代理（OpenZeppelin 插件一次性完成） */
  const NFTAuctionFactoryV2 = await ethers.getContractFactory("NFTAuctionFactoryV2");
  const proxy = await upgrades.upgradeProxy(NFTAuctionFactoryProxy, NFTAuctionFactoryV2, { deployer });
  await proxy.waitForDeployment();

  const newImpl = await upgrades.erc1967.getImplementationAddress(NFTAuctionFactoryProxy);
  console.log("新逻辑地址:", newImpl);
  console.log("代理地址不变:", NFTAuctionFactoryProxy);

  /* 3. 让 hardhat-deploy 也记录一份 ABI 与地址 */
  const artifact = await deployments.getArtifact("NFTAuctionFactoryV2");
  await deployments.save("NFTAuctionFactoryV2", {
    address: NFTAuctionFactoryProxy, // 代理地址
    abi:     artifact.abi
  });

  /* 4. 可选：更新缓存文件 */
  const cacheDir  = path.resolve(__dirname, ".cache");
  if (!fs.existsSync(cacheDir)) fs.mkdirSync(cacheDir, { recursive: true });
  fs.writeFileSync(
    path.join(cacheDir, "NFTAuctionFactoryV2.json"),
    JSON.stringify(
      {
        NFTAuctionFactory: newImpl,
        NFTAuctionFactoryProxy
      },
      null,
      2
    )
  );

  console.log("✅ 工厂合约升级完成！");
};

module.exports.tags = ["upgrade_nft_auction_factory"];