const { deployments, upgrades, ethers } = require("hardhat");
const fs   = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts();

  console.log("部署用户地址:", deployer);
  console.log("部署 NFT 拍卖合约工厂...");

  /* 1. 用 OpenZeppelin upgrades 插件部署 UUPS 代理 */
  const NFTAuctionFactory = await ethers.getContractFactory("NFTAuctionFactory");
  const proxy = await upgrades.deployProxy(
    NFTAuctionFactory,
    [
      "0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1"// NFT代理合约地址
    ],               // 构造函数参数
    { initializer: "initialize", kind: "uups" }
  );
  await proxy.waitForDeployment();

  const proxyAddress = await proxy.getAddress();
  const implAddress  = await upgrades.erc1967.getImplementationAddress(proxyAddress);

  console.log("代理地址:", proxyAddress);
  console.log("逻辑地址:", implAddress);

  /* 2. 保存元数据到 JSON 文件 */
  const cacheDir  = path.resolve(__dirname, ".cache");
  if (!fs.existsSync(cacheDir)) fs.mkdirSync(cacheDir, { recursive: true });

  const artifact = await deployments.getArtifact("NFTAuction");
  fs.writeFileSync(
    path.join(cacheDir, "proxyNftAuctionFactroy.json"),
    JSON.stringify(
      {
        NFTAuctionFactory: implAddress,
        NFTAuctionFactoryProxy: proxyAddress,
        ABI: artifact.abi
      },
      null,
      2
    )
  );

  /* 3. 让 hardhat-deploy 也记录一份（方便后续 deployments.get） */
  await deployments.save("NFTAuctionFactoryProxy", {
    address: proxyAddress,
    abi:     artifact.abi
  });

  console.log("✅ 工厂合约部署完成！");
};
module.exports.tags = ["deploy_nft_auction_factory"];