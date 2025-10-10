const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("MeMeToken", function () {
    let MeMeToken;
    let memeToken;
    let owner;
    let addr1;
    let addr2;
    let sepoliaAddress = "0x3a9d48ab9751398bbfa63ad67599bb04e4bdf98b"; // Sepolia 测试网的 WETH 地址

    beforeEach(async function () {
        [owner, addr1, addr2] = await ethers.getSigners();
        MeMeToken = await ethers.getContractFactory("MeMeToken");
        memeToken = await MeMeToken.deploy("0x986dadb82491834f6d17bd3287eb84be0b4d4cc7");
    });

    it("Should deploy with correct name and symbol", async function () {
        expect(await memeToken.name()).to.equal("MeMeToken");
        expect(await memeToken.symbol()).to.equal("MMT");
    });

    it("Should transfer tokens between accounts", async function () {
        await memeToken.transfer(addr1.address, 100);
        expect(await memeToken.balanceOf(addr1.address)).to.equal(100);
    });

    it("Should enforce daily transfer limits", async function () {
        const transferAmount = ethers.parseEther("20");
        // 测试每日转账限制逻辑
        await memeToken.transfer(addr1.address, 100);
        await expect(memeToken.transfer(addr1.address, transferAmount)).to.be.revertedWith("Daily trade amount limit exceeded");
    });

    describe("addLiquidity", () => {
        it("should add liquidity and emit LiquidityAdded event", async () => {
            const tokenAmount = ethers.parseEther("5");
            const ethAmount = ethers.parseEther("1");
            console.log("Token Amount:", tokenAmount.toString());
            console.log("ETH Amount:", ethAmount.toString());

            // 先给合约地址转一些 MeMeToken 以确保有足够的余额添加流动性
            await memeToken.transfer(owner.address, tokenAmount);

            // 添加流动性
            const tx = await memeToken.addLiquidity(tokenAmount, ethAmount, { value: ethAmount });

            await expect(tx)
                .to.emit(memeToken, "LiquidityAdded")
                .withArgs(tokenAmount, ethAmount, anyValue);
            // 检查流动性是否成功添加
            const liquidity = await memeToken.getLiquidity();
            expect(liquidity).to.be.gt(0);
        });
    });
});
