const {ethers, deployments} = require("hardhat");
const { expect } = require("chai");

 describe("test upgrade", function () {
  // let nafAutionProxy;
  // beforeEach(async function () {
  //   await deployments.fixture(["deploy_nft_auction_factory"]);
  //   nafAutionProxy = await deployments.get("NFTAuctionPorxy");

  // });
   it("auction 1", async function () {
    // 获取用户
    const [owner, signer1, buyer1] = await ethers.getSigners();
    const balancewei = await ethers.provider.getBalance(owner);
    console.log("部署用户地址:", owner.address);
    console.log("部署用户余额:", ethers.formatEther(balancewei));
    
     //部署业务合约
    await deployments.fixture(["deploy_nft_auction"]);
    const nafAutionProxy = await deployments.get("NFTAuctionPorxy");

    // 生产nft
    const nftFactory = await ethers.getContractFactory("TestERC721");
    const nftContract = await nftFactory.deploy();
    await nftContract.waitForDeployment();
    const ipfsUri = "ipfs://bafkreia3swiryoznkfzpjp3ijxm2oko3xe65o257gj3e6b2h3igxwydlh4";
    const nft = await nftContract.mintNFT(signer1.address, ipfsUri);
    // console.log("nft合约地址：", nftContract.target);
    //  授权
    await nftContract.connect(signer1).setApprovalForAll(nafAutionProxy.address, true);

    //调用业务合约
    const nftAution = await ethers.getContractAt("NFTAuction", nafAutionProxy.address);
    // 创建拍卖
    await nftAution.connect(signer1).createAuction(ethers.ZeroAddress,nftContract.target, 1, 10, ethers.parseEther("0.1"));
    const auction = await nftAution.auctions(1);
    console.log("创建拍卖成功：： ", auction);

    //出价
    await nftAution.connect(buyer1).bid(1,0, ethers.ZeroAddress, {value: ethers.parseEther("2000")});
    const auction1 = await nftAution.auctions(1);
    console.log("出价成功：： ", auction1);

    // // 取消拍卖
    // await nftAution.connect(deployer).cancelAuction(1);
    // const auction0 = await nftAution.auctions(1);
    // console.log("取消拍卖成功：： ", auction0);

    await new Promise((resolve) => setTimeout(resolve, 11 * 1000));

    // // 结束拍卖
    await nftAution.connect(owner).endAuction(1);
    const auction2 = await nftAution.auctions(1);
    console.log("结束拍卖：： ", auction2);
    // 卖家提取资金
    await nftAution.connect(signer1).sellerWithdraw(1);
    console.log("卖家资金提取完成")
    const balancewei2 = await ethers.provider.getBalance(signer1);
    console.log("交易额:", ethers.formatEther(balancewei2 - balancewei));

    const balancewei3 = await ethers.provider.getBalance(owner);
    console.log("部署用户地址:", owner.address);
    console.log("部署用户余额:", ethers.formatEther(balancewei3));
  
   });
 });
