const {ethers, deployments} = require("hardhat");
const { expect } = require("chai");

 describe("test upgrade", function () {
   it("Should return the new greeting once it's changed", async function () {
     //部署业务合约
    await deployments.fixture(["deploy_nft_auction"]);
    const nafAutionProxy = await deployments.get("NFTAuctionPorxy");

    //调用业务合约
    const nftAution = await ethers.getContractAt("NFTAuction", nafAutionProxy.address);
    const nftContract = "0xdC75cb0d3FB0bB577ecd32772c57B751770618f2";
    await nftAution.createAuction(nftContract, 1, 100*1000, ethers.parseEther("0.1"));
    const auction = await nftAution.auctions(1);
    console.log("创建拍卖成功：： ", auction);

   // 升级合约
   await deployments.fixture(["upgrade_nft_auction"]);
   const auction2 = await nftAution.auctions(1);
   console.log("创建拍卖成功：： ", auction2);
   });

 });
