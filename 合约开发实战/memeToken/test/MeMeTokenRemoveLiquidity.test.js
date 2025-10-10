const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MeMeToken - removeLiquidity", function () {
  let MeMeToken;
  let memeToken;
  let owner;
  let addr1;
  
  beforeEach(async function () {
    [owner, addr1] = await ethers.getSigners();
    MeMeToken = await ethers.getContractFactory("MeMeToken");
    const routerAddress = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Uniswap Router 地址
    memeToken = await MeMeToken.deploy(routerAddress);
    
    // 添加初始流动性
    const tokenAmount = ethers.parseEther("3");
    const ethAmount = ethers.parseEther("1");
    await memeToken.transfer(memeToken.address, tokenAmount);
    await memeToken.addLiquidity(tokenAmount, ethAmount, { value: ethAmount });
  });

  it("should remove liquidity successfully", async function () {
    // 解锁流动性
    await memeToken.lockLiquidity(0);
    
    // 获取初始流动性
    const initialLiquidity = await memeToken.balanceOf(memeToken.address);
    
    // 移除流动性
    const tx = await memeToken.removeLiquidity(initialLiquidity.div(2));
    
    // 验证事件
    await expect(tx)
      .to.emit(memeToken, "LiquidityRemoved")
      .withArgs(owner.address, anyValue, anyValue, initialLiquidity.div(2));
    
    // 验证余额变化
    const finalLiquidity = await memeToken.balanceOf(memeToken.address);
    expect(finalLiquidity).to.equal(initialLiquidity.div(2));
  });

  it("should revert when liquidity is locked", async function () {
    // 设置锁定7天
    await memeToken.lockLiquidity(7);
    
    // 尝试移除流动性
    await expect(
      memeToken.removeLiquidity(ethers.parseEther("1"))
    ).to.be.revertedWith("Liquidity is locked");
  });

  it("should revert when removing zero liquidity", async function () {
    // 解锁流动性
    await memeToken.lockLiquidity(0);
    
    // 尝试移除0流动性
    await expect(
      memeToken.removeLiquidity(0)
    ).to.be.revertedWith("Insufficient liquidity");
  });
});