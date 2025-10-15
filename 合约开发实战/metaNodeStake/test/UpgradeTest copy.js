const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("MetaNodeStake Upgrade", function () {
  it("Should upgrade successfully", async function () {
    const MetaNodeStake = await ethers.getContractFactory("MetaNodeStake");
    const MetaNodeStakeV2 = await ethers.getContractFactory("MetaNodeStakeV2");
    const MetaNodeToken = await ethers.getContractFactory("MetaNodeToken");
    const metaNodeToken = await MetaNodeToken.deploy();
    await metaNodeToken.waitForDeployment();
    const metaNodeTokenAddress = metaNodeToken.target;
    console.log("metaNodeTokenAddress:", metaNodeTokenAddress);
    const instance = await upgrades.deployProxy(MetaNodeStake, metaNodeTokenAddress, { initializer: "initialize" });
    await instance.waitForDeployment();

    const upgraded = await upgrades.upgradeProxy(instance.address, MetaNodeStakeV2);
    expect(upgraded.target).to.equal(instance.target);
  });
});