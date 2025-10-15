const { loadFixture } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MetaNodeStake", function () {
  async function deployMetaNodeStakeFixture() {
    const [owner, user1, user2] = await ethers.getSigners();
    const MetaNodeToken = await ethers.getContractFactory("MetaNodeToken");
    const metaNodeToken = await MetaNodeToken.deploy();
    const MetaNodeStake = await ethers.getContractFactory("MetaNodeStake");
    const metaNodeStake = await MetaNodeStake.deploy();
    await metaNodeStake.initialize(metaNodeToken.target, { from: owner.address });

    // 分配代币给 user1 和 user2
    await metaNodeToken.connect(owner).transfer(user1.address, ethers.parseEther("100"));
    await metaNodeToken.connect(owner).transfer(user2.address, ethers.parseEther("100"));
    await metaNodeStake.connect(owner).addPool(metaNodeToken.target, 100, ethers.parseEther("1"), 100);
    return { metaNodeStake, metaNodeToken, owner, user1, user2 };
  }

  describe("Deployment", function () {
    it("Should set the right admin roles", async function () {
      const { metaNodeStake, owner } = await loadFixture(deployMetaNodeStakeFixture);
      expect(await metaNodeStake.hasRole(await metaNodeStake.DEFAULT_ADMIN_ROLE(), owner.address)).to.be.true;
      expect(await metaNodeStake.hasRole(await metaNodeStake.ADMIN_ROLE(), owner.address)).to.be.true;
    });

    it("Should initialize rewardPerBlock correctly", async function () {
      const { metaNodeStake } = await loadFixture(deployMetaNodeStakeFixture);
      expect(await metaNodeStake.rewardPerBlock()).to.equal(ethers.parseEther("1"));
    });
  });

  describe("Stake Functionality", function () {
    it("Should allow users to stake tokens", async function () {
      const { metaNodeStake, metaNodeToken, user1 } = await loadFixture(deployMetaNodeStakeFixture);
      console.log("metaNodeStake.target:", metaNodeStake.target);
      await metaNodeToken.connect(user1).approve(metaNodeStake.target, ethers.parseEther("10"));
      await metaNodeToken.connect(user1).transfer(metaNodeStake.target, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).stake(0, ethers.parseEther("5"));
      const userInfo = await metaNodeStake.users(0, user1.address);
      expect(userInfo.stAmount).to.equal(ethers.parseEther("5"));
    });

    it("Should fail if staking amount is below minimum", async function () {
      const { metaNodeStake, metaNodeToken, user1, owner } = await loadFixture(deployMetaNodeStakeFixture);
      await metaNodeToken.connect(user1).approve(metaNodeStake.target, ethers.parseEther("10"));
      await metaNodeToken.connect(user1).transfer(metaNodeStake.target, ethers.parseEther("5"));
      await expect(metaNodeStake.connect(user1).stake(0, ethers.parseEther("0.5"))).to.be.revertedWith("Amount below minimum deposit");
    });
  });

  describe("Unstake Functionality", function () {
    it("Should allow users to unstake tokens", async function () {
      const { metaNodeStake, metaNodeToken, user1 } = await loadFixture(deployMetaNodeStakeFixture);
      await metaNodeToken.connect(user1).approve(metaNodeStake.target, ethers.parseEther("10"));
      await metaNodeToken.connect(user1).transfer(metaNodeStake.target, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).stake(0, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).unstake(0, ethers.parseEther("2"));
      const userInfo = await metaNodeStake.users(0, user1.address);
      expect(userInfo.stAmount).to.equal(ethers.parseEther("3"));
    });

    it("Should fail if unstaking is paused", async function () {
      const { metaNodeStake, metaNodeToken, user1, owner } = await loadFixture(deployMetaNodeStakeFixture);
      await metaNodeToken.connect(user1).approve(metaNodeStake.target, ethers.parseEther("10"));
      await metaNodeToken.connect(user1).transfer(metaNodeStake.target, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).stake(0, ethers.parseEther("5"));
      await metaNodeStake.connect(owner).setUnstakePaused(true);
      await expect(metaNodeStake.connect(user1).unstake(0, ethers.parseEther("2"))).to.be.revertedWith("Unstaking is paused");
    });
  });

  describe("Claim Functionality", function () {
    it("Should allow users to claim rewards", async function () {
      const { metaNodeStake, metaNodeToken, user1 } = await loadFixture(deployMetaNodeStakeFixture);
      await metaNodeToken.connect(user1).approve(metaNodeStake.target, ethers.parseEther("10"));
      await metaNodeToken.connect(user1).transfer(metaNodeStake.target, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).stake(0, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).claim(0);
      const userInfo = await metaNodeStake.users(0, user1.address);
      expect(userInfo.pendingMetaNode).to.equal(0);
    });

    it("Should fail if claiming is paused", async function () {
      const { metaNodeStake, metaNodeToken, user1, owner } = await loadFixture(deployMetaNodeStakeFixture);
      await metaNodeToken.connect(user1).approve(metaNodeStake.target, ethers.parseEther("10"));
      await metaNodeToken.connect(user1).transfer(metaNodeStake.target, ethers.parseEther("5"));
      await metaNodeStake.connect(user1).stake(0, ethers.parseEther("5"));
      await metaNodeStake.connect(owner).setClaimPaused(true);
      await expect(metaNodeStake.connect(user1).claim(0)).to.be.revertedWith("Claiming is paused");
    });
  });

  describe("Admin Operations", function () {
    it("Should allow admin to add a new pool", async function () {
      const { metaNodeStake, metaNodeToken, owner } = await loadFixture(deployMetaNodeStakeFixture);
      const poolLength = await metaNodeStake.getPoolLength();
      await metaNodeStake.connect(owner).addPool(metaNodeToken.target, 100, ethers.parseEther("1"), 100);
      expect(await metaNodeStake.getPoolLength()).to.equal(poolLength + 1n);
    });

    it("Should fail if non-admin tries to add a pool", async function () {
      const { metaNodeStake, metaNodeToken, user1 } = await loadFixture(deployMetaNodeStakeFixture);
      await expect(metaNodeStake.connect(user1).addPool(metaNodeToken.target, 100, ethers.parseEther("1"), 100)).to.be.reverted;
    });
  });
});