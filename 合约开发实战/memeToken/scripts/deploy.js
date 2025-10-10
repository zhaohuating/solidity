const { ethers } = require("hardhat");

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with the account:", deployer.address);

    const MeMeToken = await ethers.getContractFactory("MeMeToken");
    const memeToken = await MeMeToken.deploy("0x986dadb82491834f6d17bd3287eb84be0b4d4cc7");
    await memeToken.deployed();
    console.log("MeMeToken deployed to:", memeToken.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
