import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ERC20ABI } from "./ERC20ABI";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

// Helper function for signature creation
async function createControllerSignature(
  account1: HardhatEthersSigner,
  params: {
    idBet: string;
    totalFeeAmount: string;
    quoteTimestamp: number;
    exclusivityDeadline: number;
    exclusivityRelayer: string;
    isMultipleBet: boolean;
    onlyWithdraw: boolean;
    sentinelAddress: string;
  }
) {
  // Create a random nonce
  const nonce = hre.ethers.randomBytes(32);

  const domain = {
    name: "BetVerifier",
    version: "1",
    chainId: await account1.provider.getNetwork().then((n) => n.chainId),
    verifyingContract: params.sentinelAddress,
  };

  const types = {
    Withdraw: [
      { name: "idBet", type: "uint256" },
      { name: "amountOut", type: "uint256" },
      { name: "quoteTimestamp", type: "uint32" },
      { name: "exclusivityDeadline", type: "uint32" },
      { name: "exclusivityRelayer", type: "address" },
      { name: "isMultipleBet", type: "bool" },
      { name: "onlyWithdraw", type: "bool" },
      { name: "verifyingContract", type: "address" },
      { name: "nonce", type: "bytes32" },
    ],
  };

  const value = {
    idBet: params.idBet,
    amountOut: params.totalFeeAmount,
    quoteTimestamp: params.quoteTimestamp,
    exclusivityDeadline: params.exclusivityDeadline,
    exclusivityRelayer: params.exclusivityRelayer,
    isMultipleBet: params.isMultipleBet,
    onlyWithdraw: params.onlyWithdraw,
    verifyingContract: params.sentinelAddress,
    nonce: nonce,
  };

  // Sign using EIP-712
  const signature = await account1.signTypedData(domain, types, value);

  // Split signature into r,s,v components
  const sig = hre.ethers.Signature.from(signature);

  // Create a properly padded v value (32 bytes)
  const paddedV = new Uint8Array(32);
  paddedV[31] = sig.yParity ? 28 : 27;

  // Return signature components and nonce separately
  return {
    signature: hre.ethers.concat([
      sig.r, // 32 bytes for r
      sig.s, // 32 bytes for s
      paddedV, // 32 bytes for v
    ]),
    nonce,
  };
}

// Update helper function for bet signatures
async function createBetSignature(
  account1: HardhatEthersSigner,
  params: {
    tokenIn: string;
    tokenOut: string;
    amountIn: string;
    bet: string;
    verifyingContract: string;
  }
) {
  // Create a random nonce
  const nonce = hre.ethers.randomBytes(32);

  const domain = {
    name: "BetVerifier",
    version: "1",
    chainId: await account1.provider.getNetwork().then((n) => n.chainId),
    verifyingContract: params.verifyingContract,
  };

  const types = {
    Bet: [
      { name: "tokenIn", type: "address" },
      { name: "tokenOut", type: "address" },
      { name: "amountIn", type: "uint256" },
      { name: "betHash", type: "bytes32" },
      { name: "verifyingContract", type: "address" },
      { name: "nonce", type: "bytes32" },
    ],
  };

  const betHash = hre.ethers.keccak256(params.bet);
  const value = {
    tokenIn: params.tokenIn,
    tokenOut: params.tokenOut,
    amountIn: params.amountIn,
    betHash: betHash,
    verifyingContract: params.verifyingContract,
    nonce: nonce,
  };

  // Sign using EIP-712
  const signature = await account1.signTypedData(domain, types, value);

  // Split signature into r,s,v components
  const sig = hre.ethers.Signature.from(signature);

  // Create a properly padded v value (32 bytes)
  const paddedV = new Uint8Array(32);
  paddedV[31] = sig.yParity ? 28 : 27;

  // Return signature components and nonce separately
  return {
    signature: hre.ethers.concat([
      sig.r, // 32 bytes for r
      sig.s, // 32 bytes for s
      paddedV, // 32 bytes for v
    ]),
    nonce,
  };
}

describe("Sentinel", function () {
  // Test configuration
  const ADDRESSES = {
    SWAP_ROUTER: "0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45",
    LP: "0x7043E4e1c4045424858ECBCED80989FeAfC11B36",
    AZURO_BET: "0x8ed7296b5CAe379d07C70280Af622BC410F01Ed7", //this is for the PreMatch
    USDC: "0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359",
    USDC_DESTINATION: "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",
    USDT: "0xc2132D05D31c914a87C6611C10748AEb04B58e8F",
    ACROSS_GENERIC_HANDLER: "0x88a1493366D48225fc3cEFbdae9eBb23E323Ade3", // Test handler
    ACROSS_SPOKE_POOL: "0x9295ee1d8C5b022Be115A2AD3c30C72E34e7F096",
    PROTOCOL_FEE_RECIPIENT: "0xDB6308968A6d90892A65989A318E0F0408147317",
    CORE_BASE: "0xA40F8D69D412b79b49EAbdD5cf1b5706395bfCf7", // PreMatch
    EXPRESS_ADDRESS: "0x92a4e8Bc6B92a2e1ced411f41013B5FE6BE07613", //this is for the nft too
    QUOTER: "0x7637Aaeb5BD58269B782726680d83f72C651aE74",
  };

  const CONFIG = {
    PROTOCOL_FEE_PERCENTAGE: 1000,
    REFERRAL_FEE_PERCENTAGE: 100,
    POOL_FEE: 100, // 0.02%
    DESTINATION_CHAIN_ID: 8453, // Base mainnet
  };

  async function deploySentinelFixture() {
    const [account1, account2] = await hre.ethers.getSigners();
    const contractCode = (await hre.artifacts.readArtifact("SentinelV1"))
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
    const Sentinel = await hre.ethers.getContractFactory("SentinelV1");
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
        ADDRESSES.USDC_DESTINATION,
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
    //const deployedAddress = "0xcb1eca680cB0ADa20b78a501f350fdfDB2b10BD8"
    const deployedSentinel = await hre.ethers.getContractAt(
      "SentinelV1",
      deployedAddress
    );

    const usdc = await hre.ethers.getContractAt("IERC20", ADDRESSES.USDC);
    const usdt = await hre.ethers.getContractAt("IERC20", ADDRESSES.USDT);

    const NFTSingle = await hre.ethers.getContractAt(
      "IERC721",
      ADDRESSES.AZURO_BET
    );
    const NFTMultiple = await hre.ethers.getContractAt(
      "IERC721",
      ADDRESSES.EXPRESS_ADDRESS
    );

    return {
      deployedSentinel,
      deployedAddress,
      account1,
      account2,
      usdc,
      usdt,
      NFTSingle,
      NFTMultiple,
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
      const { deployedSentinel, deployedAddress, account1, usdc } =
        await loadFixture(deploySentinelFixture);

      const betParams = {
        conditions: ["100610060000000000263918750000000000000378650531"],
        outcomes: ["29"],
        referrer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
        amount: "2000000", // 2 USDC
      };

      const betData = hre.ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256[]", "uint64[]", "address"],
        [betParams.conditions, betParams.outcomes, betParams.referrer]
      );

      // Create signature
      const signatureParams = {
        tokenIn: ADDRESSES.USDC,
        tokenOut: ADDRESSES.USDT,
        amountIn: betParams.amount,
        bet: betData,
        verifyingContract: deployedAddress,
      };

      const { signature, nonce } = await createBetSignature(
        account1,
        signatureParams
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

      // Execute handleBet with the properly formatted signature
      await deployedSentinel
        .connect(acrossGenericHandlerSigner)
        .handleBet(
          ADDRESSES.USDC,
          ADDRESSES.USDT,
          BigInt(betParams.amount),
          betData as `0x${string}`,
          signature as `0x${string}`,
          nonce
        );

      // Check fee distribution
      const expectedProtocolFee =
        (BigInt(betParams.amount) * BigInt(CONFIG.PROTOCOL_FEE_PERCENTAGE)) /
        BigInt(10000);
      const expectedReferralFee =
        ((BigInt(betParams.amount) - expectedProtocolFee) *
          BigInt(CONFIG.REFERRAL_FEE_PERCENTAGE)) /
        BigInt(10000);

      expect(await usdc.balanceOf(betParams.referrer)).to.equal(
        initialReferrerBalance + expectedReferralFee
      );

      await hre.network.provider.request({
        method: "hardhat_stopImpersonatingAccount",
        params: [ADDRESSES.ACROSS_GENERIC_HANDLER],
      });
    });
    /*
    it("Should execute handleBet successfully with multiple bets", async function () {
      const { deployedSentinel, deployedAddress, usdc, account1 } = await loadFixture(
        deploySentinelFixture
      );

      const betParams = {
        conditions: [
          "100610060000000000263446620000000000000329033248",
          "100610060000000000263446630000000000000328133014",
        ],
        outcomes: ["29", "29"], // Two outcomes for multiple bet
        referrer: "0xDB6308968A6d90892A65989A318E0F0408147317",
        amount: "5000000", // 5 USDC
      };

      const betData = hre.ethers.AbiCoder.defaultAbiCoder().encode(
        ["uint256[]", "uint64[]", "address"],
        [betParams.conditions, betParams.outcomes, betParams.referrer]
      );
      console.log(betData, "betData");

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

      // Create signature
      const signatureParams = {
        tokenIn: ADDRESSES.USDC,
        tokenOut: ADDRESSES.USDT,
        amountIn: betParams.amount,
        bet: betData,
        verifyingContract: deployedAddress,
      };

      const { messageHash, nonce } = await createBetSignature(signatureParams);
      const signature = await account1.signMessage(
        hre.ethers.getBytes(messageHash)
      );
      const signatureWithNonce = hre.ethers.concat([signature, nonce]);

      await deployedSentinel
        .connect(acrossGenericHandlerSigner)
        .handleBet(
          ADDRESSES.USDC as `0x${string}`,
          ADDRESSES.USDT as `0x${string}`,
          BigInt(betParams.amount),
          betData,
          signatureWithNonce
        );

      // Check fee distribution
      const expectedProtocolFee =
        (BigInt(betParams.amount) * BigInt(CONFIG.PROTOCOL_FEE_PERCENTAGE)) /
        BigInt(10000);
      const expectedReferralFee =
        ((BigInt(betParams.amount) - expectedProtocolFee) *
          BigInt(CONFIG.REFERRAL_FEE_PERCENTAGE)) /
        BigInt(10000);
      /*
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
    });*/

    it("Should execute handleWithdraw successfully", async function () {
      const {
        deployedSentinel,
        deployedAddress,
        account1,
        account2,
        usdc,
        usdt,
        NFTSingle,
      } = await loadFixture(deploySentinelFixture);

      // Impersonate account to transfer NFT
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: ["0x1892E00226021715d085363682655B62049e3E84"],
      });
      const expressSigner = await hre.ethers.getSigner(
        "0x1892E00226021715d085363682655B62049e3E84"
      );

      await NFTSingle.connect(expressSigner).transferFrom(
        "0x1892E00226021715d085363682655B62049e3E84",
        deployedAddress,
        328904
      );

      expect(await NFTSingle.ownerOf(328904)).to.equal(deployedAddress);

      const withdrawParams = {
        idBet: "328904",
        totalFeeAmount: "1000000", // 1 USDC
        quoteTimestamp: Math.floor(Date.now() / 1000),
        exclusivityDeadline: Math.floor(Date.now() / 1000) + 3600,
        exclusivityRelayer: account2.address,
        isMultipleBet: false,
        onlyWithdraw: false,
        sentinelAddress: deployedAddress,
      };

      // Create signature
      const { signature, nonce } = await createControllerSignature(
        account1,
        withdrawParams
      );

      // Execute withdraw with separate nonce
      await deployedSentinel
        .connect(account2)
        .handleWithdraw(
          BigInt(withdrawParams.idBet),
          BigInt(withdrawParams.totalFeeAmount),
          BigInt(withdrawParams.quoteTimestamp),
          BigInt(withdrawParams.exclusivityDeadline),
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          signature as `0x${string}`,
          nonce
        );

      // Add appropriate assertions here
    });
  });
});
