import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ERC20ABI } from "./ERC20ABI";

// Helper function for signature creation
async function createControllerSignature(params: {
  idBet: string;
  amountOut: string;
  quoteTimestamp: number;
  exclusivityDeadline: number;
  exclusivityRelayer: string;
  onlyWithdraw: boolean;
  sentinelAddress: string;
}) {
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
  return hre.ethers.keccak256(message);
}

describe("Sentinel", function () {
  // Test configuration
  const ADDRESSES = {
    SWAP_ROUTER: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
    LP: "0x7043E4e1c4045424858ECBCED80989FeAfC11B36",
    AZURO_BET: "0x8ed7296b5CAe379d07C70280Af622BC410F01Ed7",
    USDC: "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359",
    USDT: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
    ACROSS_GENERIC_HANDLER: "0x88a1493366D48225fc3cEFbdae9eBb23E323Ade3", // Test handler
    ACROSS_SPOKE_POOL: "0x9295ee1d8C5b022Be115A2AD3c30C72E34e7F096",
    PROTOCOL_FEE_RECIPIENT: "0xDB6308968A6d90892A65989A318E0F0408147317",
    CORE_BASE: "0xA40F8D69D412b79b49EAbdD5cf1b5706395bfCf7", // PreMatch
    EXPRESS_ADDRESS: "0x92a4e8Bc6B92a2e1ced411f41013B5FE6BE07613",
    QUOTER: "0x7637Aaeb5BD58269B782726680d83f72C651aE74",
  };

  const CONFIG = {
    PROTOCOL_FEE_PERCENTAGE: 1000,
    REFERRAL_FEE_PERCENTAGE: 100,
    POOL_FEE: 100, // 0.02%
    DESTINATION_CHAIN_ID: 137, // Polygon mainnet
  };

  async function deploySentinelFixture() {
    const [account1, account2] = await hre.ethers.getSigners();
    const contractCode = (await hre.artifacts.readArtifact("Sentinel"))
      .bytecode;

    // Deploy factory
    const Factory = await hre.ethers.getContractFactory(
      "SentinelFactoryCreate2"
    );
    const factory = await Factory.connect(account2).deploy(
      account2.address, // operator
      contractCode
    );

    // Prepare Sentinel initialization
    const Sentinel = await hre.ethers.getContractFactory("Sentinel");
    const sentinel = await Sentinel.connect(account2).deploy();

    const initContractCore = sentinel.interface.encodeFunctionData(
      "initializeCore",
      [
        account1.address, // controller
        account2.address, // operator
        ADDRESSES.SWAP_ROUTER,
        ADDRESSES.LP,
        ADDRESSES.AZURO_BET,
        ADDRESSES.USDC,
        ADDRESSES.USDT,
      ]
    );

    const initContractProtocol = sentinel.interface.encodeFunctionData(
      "initializeProtocol",
      [
        ADDRESSES.ACROSS_GENERIC_HANDLER,
        ADDRESSES.ACROSS_SPOKE_POOL,
        ADDRESSES.PROTOCOL_FEE_RECIPIENT,
        CONFIG.PROTOCOL_FEE_PERCENTAGE,
        CONFIG.REFERRAL_FEE_PERCENTAGE,
        ADDRESSES.CORE_BASE,
        ADDRESSES.EXPRESS_ADDRESS,
        ADDRESSES.QUOTER,
        CONFIG.POOL_FEE,
        CONFIG.DESTINATION_CHAIN_ID,
      ]
    );

    // Deploy through factory
    await factory
      .connect(account2)
      .deploy(account1.address, initContractCore, initContractProtocol);

    const deployedAddress = await factory.deployedControllers(account1.address);
    const deployedSentinel = await hre.ethers.getContractAt(
      "Sentinel",
      deployedAddress
    );

    const usdc = await hre.ethers.getContractAt("IERC20", ADDRESSES.USDC);
    const usdt = await hre.ethers.getContractAt("IERC20", ADDRESSES.USDT);

    return {
      deployedSentinel,
      deployedAddress,
      account1,
      account2,
      usdc,
      usdt,
      factory,
    };
  }

  describe("Deployment", function () {
    it("Should set correct operator and controller", async function () {
      const { deployedSentinel, account1, account2 } = await loadFixture(
        deploySentinelFixture
      );

      expect(await deployedSentinel.operator()).to.equal(account2.address);
      expect(await deployedSentinel.controller()).to.equal(account1.address);
    });

    it("Should prevent duplicate deployment for same controller", async function () {
      const { factory, account1, account2 } = await loadFixture(
        deploySentinelFixture
      );

      const dummyData = "0x";
      await expect(
        factory.connect(account2).deploy(account1.address, dummyData, dummyData)
      )
        .to.be.revertedWithCustomError(factory, "AlreadyDeployed")
        .withArgs(account1.address);
    });

    it("Should execute handleBet successfully", async function () {
      const { deployedSentinel, deployedAddress, usdc } = await loadFixture(
        deploySentinelFixture
      );

      const betParams = {
        conditions: [
          "100610060000000000264450940000000000000354486732"
        ],
        outcomes: ["29"], // Two outcomes for multiple bet
        referrer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
        amount: "5000000", // 5 USDC
        isMultiple: true, // Flag for multiple bet
      };

      const betData = hre.ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256[]", "uint64[]", "address"],
        [betParams.conditions, betParams.outcomes, betParams.referrer]
      );

      // Get initial balances
      const initialProtocolBalance = await usdc.balanceOf(
        ADDRESSES.PROTOCOL_FEE_RECIPIENT
      );
      const initialReferrerBalance = await usdc.balanceOf(betParams.referrer);

      // Impersonate acrossGenericHandler
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [ADDRESSES.ACROSS_GENERIC_HANDLER],
      });

      const acrossGenericHandlerSigner = await hre.ethers.getSigner(
        ADDRESSES.ACROSS_GENERIC_HANDLER
      );

      await usdc
        .connect(acrossGenericHandlerSigner)
        .approve(deployedAddress, betParams.amount);

      await deployedSentinel
        .connect(acrossGenericHandlerSigner)
        .handleBet(ADDRESSES.USDC, ADDRESSES.USDT, betParams.amount, betData);

      // Check fee distribution
      const expectedProtocolFee =
        (BigInt(betParams.amount) * BigInt(CONFIG.PROTOCOL_FEE_PERCENTAGE)) /
        BigInt(10000);
      const expectedReferralFee =
        ((BigInt(betParams.amount) - expectedProtocolFee) *
          BigInt(CONFIG.REFERRAL_FEE_PERCENTAGE)) /
        BigInt(10000);

      expect(await usdc.balanceOf(ADDRESSES.PROTOCOL_FEE_RECIPIENT)).to.equal(
        initialProtocolBalance + expectedProtocolFee
      );
      expect(await usdc.balanceOf(betParams.referrer)).to.equal(
        initialReferrerBalance + expectedReferralFee
      );

      await hre.network.provider.request({
        method: "hardhat_stopImpersonatingAccount",
        params: [ADDRESSES.ACROSS_GENERIC_HANDLER],
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
