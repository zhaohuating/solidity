const { ethers, upgrades } = require("hardhat");

async function main() {
    // 1. 配置参数
    const proxyAddress = "0x..."; // 替换为你的代理合约地址
    const newContractName = "MetaNodeStakeV2"; // 新合约名称

    // 2. 获取新合约工厂
    const NewContract = await ethers.getContractFactory(newContractName);

    // 3. 执行升级
    console.log(`Upgrading proxy contract at ${proxyAddress} to ${newContractName}...`);
    await upgrades.upgradeProxy(proxyAddress, NewContract);
    console.log("Proxy upgraded successfully!");

    // 4. 验证升级
    const newLogicAddress = await upgrades.erc1967.getImplementationAddress(proxyAddress);
    console.log(`New logic contract address: ${newLogicAddress}`);
}

main().catch((error) => {
    console.error("Upgrade failed:", error);
    process.exitCode = 1;
});