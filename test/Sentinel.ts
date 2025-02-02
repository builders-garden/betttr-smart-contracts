import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ERC20ABI } from "./ERC20ABI";

async function createControllerSignature(
  params: {
    idBet: string;
    amountOut: string;
    quoteTimestamp: number;
    exclusivityDeadline: number;
    exclusivityRelayer: string;
    onlyWithdraw: boolean;
    sentinelAddress: string;
  }
) {
  // Construct the message in the same way as the contract
  const message = hre.ethers.solidityPacked(
    ["uint256", "uint256", "uint32", "uint32", "address", "bool", "address"],
    [
      params.idBet,
      params.amountOut,
      params.quoteTimestamp,
      params.exclusivityDeadline,
      params.exclusivityRelayer,
      params.onlyWithdraw,
      params.sentinelAddress,
    ]
  );

  // Create the hash
  const messageHash = hre.ethers.keccak256(message);

  return messageHash;
}

describe("Sentinel", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deploySentinelFixture() {
    // Contracts are deployed using the first signer/account by default
    const [account1, account2] = await hre.ethers.getSigners();
    console.log(account1.address, "account1");
    console.log(account2.address, "account2");
    // Constructor parameters
    const controller = account1.address;
    const operator = account2.address;
    const swapRouter = "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45";
    const lp = "0x7043E4e1c4045424858ECBCED80989FeAfC11B36";
    //const lp = "0x3528186476fd0ea0adc9fccc41de4cd138f99653"; // (Pre-Production) LP
    const azuroBet = "0x8ed7296b5CAe379d07C70280Af622BC410F01Ed7";
    const usdcAddress = "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359";
    const usdtAddress = "0xc2132D05D31c914a87C6611C10748AEb04B58e8F";

    // Configuration variables for initializeProtocol
    //const acrossGenericHandler = "0x924a9f036260DdD5808007E1AA95f08eD08aA569";
    const acrossGenericHandler = "0x88a1493366D48225fc3cEFbdae9eBb23E323Ade3"; //fake acrossGenericHandler
    const acrossSpokePool = "0x9295ee1d8C5b022Be115A2AD3c30C72E34e7F096";
    const protocolFeeRecipient = "0xDB6308968A6d90892A65989A318E0F0408147317";
    const protocolFeePercentage = 1000;
    const referralFeePercentage = 100;
    //const coreBase = "0x2477B960080B3439b4684df3D9CE53B2ACe64315" // (Pre-Production) PreMatch
    const coreBase = "0xA40F8D69D412b79b49EAbdD5cf1b5706395bfCf7"; //PreMatch
    //const coreBase = "0x92a4e8Bc6B92a2e1ced411f41013B5FE6BE07613"; //BetExpress
    const quoter = "0x7637Aaeb5BD58269B782726680d83f72C651aE74";
    const poolFee = 100; // 0.02%
    const destinationChainId = 137; // Polygon mainnet

    const Sentinel = await hre.ethers.getContractFactory("Sentinel");
    const sentinel = await Sentinel.connect(account2).deploy(
      controller,
      operator,
      swapRouter,
      lp,
      azuroBet,
      usdcAddress,
      usdtAddress
    );
    expect(await sentinel.operator()).to.equal(operator);
    console.log(await sentinel.controller());
    expect(await sentinel.controller()).to.equal(controller);
    console.log(await sentinel.swapRouter());

    const initializeProtocol = await sentinel
      .connect(account2)
      .initializeProtocol(
        acrossGenericHandler,
        acrossSpokePool,
        protocolFeeRecipient,
        protocolFeePercentage,
        referralFeePercentage,
        coreBase,
        quoter,
        poolFee,
        destinationChainId
      );
    const usdc = await hre.ethers.getContractAt("IERC20", usdcAddress);
    const usdt = await hre.ethers.getContractAt("IERC20", usdtAddress);
    const sentinelAddress = await sentinel.getAddress();
    return {
      sentinel,
      sentinelAddress,
      account1,
      account2,
      usdcAddress,
      usdtAddress,
      acrossGenericHandler,
      usdc,
      usdt,
      swapRouter,
      lp,
    };
  }

  describe("Deployment", function () {
    it("Should check the operator and controller", async function () {
      const { sentinel, account1, account2 } = await loadFixture(
        deploySentinelFixture
      );

      expect(await sentinel.operator()).to.equal(account2.address);
      expect(await sentinel.controller()).to.equal(account1.address);
    });
    it("Should execute handleBet", async function () {
      const {
        sentinel,
        sentinelAddress,
        account1,
        account2,
        usdcAddress,
        usdtAddress,
        acrossGenericHandler,
        usdc,
        usdt,
        swapRouter,
        lp,
      } = await loadFixture(deploySentinelFixture);
      // Create bet parameters
      const condition = "100610060000000000262983090000000000000271848208"; // Example condition ID
      const outcome = "29"; // Example outcome
      const referrer = "0x216BeA48DE17eba784027a591DBD2866EF606EC6";

      // Encode bet data using ethers
      const betData = hre.ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256", "uint64", "address"],
        [condition, outcome, referrer]
      );
      const amount = "5000000"; // 5 USDC

      // Impersonate acrossGenericHandler
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [acrossGenericHandler],
      });

      const acrossGenericHandlerSigner = await hre.ethers.getSigner(
        acrossGenericHandler
      );
      //approve sentinel to spend acrossGenericHandler's USDC
      await usdc
        .connect(acrossGenericHandlerSigner)
        .approve(sentinelAddress, amount);

      const bet = await sentinel
        .connect(acrossGenericHandlerSigner)
        .handleBet(usdcAddress, usdtAddress, amount, betData);

      // Stop impersonating
      await hre.network.provider.request({
        method: "hardhat_stopImpersonatingAccount",
        params: [acrossGenericHandler],
      });
    });
  });
});


/*
const messageHash = await createControllerSignature({
        idBet: "1",
        amountOut: "1000000000000000000",
        quoteTimestamp: 1712150400,
        exclusivityDeadline: 1712150400,
        exclusivityRelayer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
        onlyWithdraw: false,
        sentinelAddress: sentinelAddress,
      });
      const signature = await acrossGenericHandlerSigner.signMessage(
        hre.ethers.getBytes(messageHash)
      );
*/
