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
       // 构造函数参数
    ],               
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
  await deployments.save("NFTAuctionProxy", {
    address: proxyAddress,
    abi:     artifact.abi
  });

  // // 2. 手动读取文件，添加implAddress并重新写入
  // const deploymentPath = path.join(
  //   hre.config.paths.deployments, // hardhat-deploy默认部署目录
  //   hre.network.name, // 当前网络名称（如hardhat、sepolia）
  //   "NFTAuctionProxy.json"
  // );
  // // 读取现有部署信息
  // const deploymentData = JSON.parse(fs.readFileSync(deploymentPath, "utf8"));

  // // 添加implAddress字段
  // deploymentData.implAddress = implAddress;

  // // 重新写入文件
  // fs.writeFileSync(
  //   deploymentPath,
  //   JSON.stringify(deploymentData, null, 2) // 格式化JSON，便于阅读
  // );

  console.log("✅ 部署完成！");
};
module.exports.tags = ["deploy_nft_auction"];