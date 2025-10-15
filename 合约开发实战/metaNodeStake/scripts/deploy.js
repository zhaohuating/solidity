const { ethers, upgrades } = require("hardhat");

async function main() {
  // 1. 部署代币合约 MetaNodeToken
  const MetaNodeToken = await ethers.getContractFactory("MetaNodeToken");
  console.log("Deploying MetaNodeToken...");
  const metaNodeToken = await MetaNodeToken.deploy();
  await metaNodeToken.waitForDeployment();
  console.log("MetaNodeToken deployed to:", metaNodeToken.target);

  // 2. 部署逻辑合约 MetaNodeStake（可升级），并传入代币地址
  const MetaNodeStake = await ethers.getContractFactory("MetaNodeStake");
  console.log("Deploying MetaNodeStake...");
  const metaNodeStakProxy = await upgrades.deployProxy(
    MetaNodeStake,
    [metaNodeToken.target], // 初始化参数：代币地址
    { initializer: "initialize" }
  );
  await metaNodeStakProxy.waitForDeployment();
  console.log("MetaNodeStakeProxy deployed to:", metaNodeStakProxy.target);
  upgrades.erc1967.getImplementationAddress(metaNodeStakProxy.target).then((implementationAddress) => {
    console.log("MetaNodeStake implementation address:", implementationAddress);
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
