const { deployments, upgrades, ethers } = require("hardhat");
const fs   = require("fs");
const path = require("path");

module.exports = async ({ getNamedAccounts }) => {
  const { deployer } = await getNamedAccounts();

  console.log("部署用户地址:", deployer);
  console.log("部署 NFT 拍卖合约...");

  /* 1. 用 OpenZeppelin upgrades 插件部署 UUPS 代理 */
  const NFTAuctionFactory = await ethers.getContractFactory("NFTAuction");
  const proxy = await upgrades.deployProxy(
    NFTAuctionFactory,
    [
      deployer,
      "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6",// NFT代理合约地址
      1, // tokenId
      ethers.parseEther("0.01"), // 起拍价 0.01 ETH
      60 * 60 * 24 // 拍卖时长 24 小时
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
    path.join(cacheDir, "proxyNftAuction.json"),
    JSON.stringify(
      {
        NFTAuction: implAddress,
        NFTAuctionProxy: proxyAddress,
        ABI: artifact.abi
      },
      null,
      2
    )
  );

  /* 3. 让 hardhat-deploy 也记录一份（方便后续 deployments.get） */
  await deployments.save("NFTAuctionPorxy", {
    address: proxyAddress,
    abi:     artifact.abi
  });

  console.log("✅ 部署完成！");
};
module.exports.tags = ["deploy_nft_auction"];