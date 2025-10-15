const { expect } = require("chai");
const { ethers, upgrades } = require("hardhat");

describe("MetaNodeStake Upgrade", function () {
  it("Should upgrade successfully", async function () {
    const MetaNodeStake = await ethers.getContractFactory("MetaNodeStake");
    const MetaNodeStakeV2 = await ethers.getContractFactory("MetaNodeStakeV2");

    const instance = await upgrades.deployProxy(MetaNodeStake, ["0x..."], { initializer: "initialize" });
    await instance.deployed();

    const upgraded = await upgrades.upgradeProxy(instance.address, MetaNodeStakeV2);
    expect(upgraded.address).to.equal(instance.address);
  });
});