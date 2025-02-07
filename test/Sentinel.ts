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
  totalFeeAmount: string;
  quoteTimestamp: number;
  exclusivityDeadline: number;
  exclusivityRelayer: string;
  isMultipleBet: boolean;
  onlyWithdraw: boolean;
  sentinelAddress: string;
}) {
  const message = hre.ethers.solidityPacked(
    [
      "uint256",
      "uint256",
      "uint32",
      "uint32",
      "address",
      "bool",
      "bool",
      "address",
    ],
    [
      params.idBet,
      params.totalFeeAmount,
      params.quoteTimestamp,
      params.exclusivityDeadline,
      params.exclusivityRelayer,
      params.isMultipleBet,
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
    const deployedSentinel = await hre.ethers.getContractAt(
      "Sentinel",
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
    /*

    it("Should execute handleBet successfully", async function () {
      const { deployedSentinel, deployedAddress, usdc } = await loadFixture(
        deploySentinelFixture
      );

      const betParams = {
        conditions: ["100610060000000000265044270000000000000371278161"],
        outcomes: ["29"], // Two outcomes for multiple bet
        referrer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
        amount: "5000000", // 5 USDC
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

    it("Should execute handleBet successfully with multiple bets", async function () {
      const { deployedSentinel, deployedAddress, usdc } = await loadFixture(
        deploySentinelFixture
      );

      const betParams = {
        conditions: [
          "100610060000000000265044270000000000000371278161",
          "100610060000000000264450940000000000000354486732",
        ],
        outcomes: ["29", "29"], // Two outcomes for multiple bet
        referrer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
        amount: "5000000", // 5 USDC
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
    */
    
  
    it("Should execute only withdraw successfully", async function () {
      const {
        deployedSentinel,
        deployedAddress,
        account1,
        account2,
        usdc,
        usdt,
        NFTSingle,
      } = await loadFixture(deploySentinelFixture);
      //Impersonate 0xfA6a2662aF427b4645254293adE248285B72AA29 to transfet the NFT with id 327075 to sentinel address
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
      //Check owner of the NFT
      expect(await NFTSingle.ownerOf(328904)).to.equal(deployedAddress);

      //
      const acrossApiUrl = "https://app.across.to/api/suggested-fees?inputToken=0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359&outputToken=0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913&originChainId=137&destinationChainId=8453&amount=9398623"
      const response = await fetch(acrossApiUrl);
      const data = await response.json();
      const totalFeeAmount = data.totalRelayFee.total;
      let exclusivityRelayer = data.exclusivityRelayer;
      const exclusivityDeadline = data.exclusivityDeadline;
      if (exclusivityRelayer === undefined) {
        exclusivityRelayer = "0x0000000000000000000000000000000000000000";
      }
      const timestamp = data.timestamp;
      console.log(totalFeeAmount, "totalFeeAmount")
      
      const withdrawParams = {
        idBet: "328904",
        totalFeeAmount: totalFeeAmount, // 1 USDC
        quoteTimestamp: timestamp,
        exclusivityDeadline: exclusivityDeadline, // 1 hour from now
        exclusivityRelayer: exclusivityRelayer,
        isMultipleBet: false,
        onlyWithdraw: false,
        sentinelAddress: deployedAddress,
      };
      // Create and sign the message
      const messageHash = await createControllerSignature(withdrawParams);
      const signature = await account1.signMessage(
        hre.ethers.getBytes(messageHash)
      );
      const initialUsdtBalance = await usdt.balanceOf(deployedAddress);
      //Operator calls handleWithdrawOperator
      await deployedSentinel
        .connect(account2)
        .handleWithdrawOperator(
          withdrawParams.idBet,
          withdrawParams.totalFeeAmount,
          withdrawParams.quoteTimestamp,
          withdrawParams.exclusivityDeadline,
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          signature
        );
       //Check balance of USDT
       expect(await usdt.balanceOf(deployedAddress)).greaterThan(initialUsdtBalance);
    });
    /*
    
    it("Should execute withdraw and swap successfully", async function () {
      const {
        deployedSentinel,
        deployedAddress,
        account1,
        account2,
        usdc,
        usdt,
        NFTSingle,
      } = await loadFixture(deploySentinelFixture);
      //Impersonate 0xfA6a2662aF427b4645254293adE248285B72AA29 to transfet the NFT with id 327075 to sentinel address
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: ["0xfA6a2662aF427b4645254293adE248285B72AA29"],
      });
      const expressSigner = await hre.ethers.getSigner(
        "0xfA6a2662aF427b4645254293adE248285B72AA29"
      );

      await NFTSingle.connect(expressSigner).transferFrom(
        "0xfA6a2662aF427b4645254293adE248285B72AA29",
        deployedAddress,
        327075
      );
      //Check owner of the NFT
      expect(await NFTSingle.ownerOf(327075)).to.equal(deployedAddress);

      const withdrawParams = {
        idBet: "327075",
        totalFeeAmount: "100", // 0.001 USDC
        quoteTimestamp: Math.floor(Date.now() / 1000),
        exclusivityDeadline: Math.floor(Date.now() / 1000) + 3600, // 1 hour from now
        exclusivityRelayer: account2.address as `0x${string}`,
        isMultipleBet: false,
        onlyWithdraw: false,
        sentinelAddress: deployedAddress,
      };
      // Create and sign the message
      const messageHash = await createControllerSignature(withdrawParams);
      const signature = await account1.signMessage(
        hre.ethers.getBytes(messageHash)
      );
      const initialUsdcBalance = await usdc.balanceOf(deployedAddress);
      //Operator calls handleWithdrawOperator
      await deployedSentinel
        .connect(account2)
        .handleWithdrawOperator(
          withdrawParams.idBet,
          withdrawParams.totalFeeAmount,
          withdrawParams.quoteTimestamp,
          withdrawParams.exclusivityDeadline,
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          signature
        );
       //Check balance of USDC
       expect(await usdc.balanceOf(deployedAddress)).greaterThan(initialUsdcBalance);
    });
    
    it("Should execute withdraw multiple bet successfully", async function () {
      const {
        deployedSentinel,
        deployedAddress,
        account1,
        account2,
        usdc,
        usdt,
        NFTMultiple,
      } = await loadFixture(deploySentinelFixture);
      //Impersonate 0xfA6a2662aF427b4645254293adE248285B72AA29 to transfet the NFT with id 327075 to sentinel address
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: ["0xCd94515535980f011DfC0f7F9C4Eea0506122F88"],
      });
      const expressSigner = await hre.ethers.getSigner(
        "0xCd94515535980f011DfC0f7F9C4Eea0506122F88"
      );

      await NFTMultiple.connect(expressSigner).transferFrom(
        "0xCd94515535980f011DfC0f7F9C4Eea0506122F88",
        deployedAddress,
        181358
      );
      //Check owner of the NFT
      expect(await NFTMultiple.ownerOf(181358)).to.equal(deployedAddress);

      const withdrawParams = {
        idBet: "181358",
        totalFeeAmount: "100", // 0.001 USDC
        quoteTimestamp: Math.floor(Date.now() / 1000),
        exclusivityDeadline: Math.floor(Date.now() / 1000) + 3600, // 1 hour from now
        exclusivityRelayer: account2.address as `0x${string}`,
        isMultipleBet: true,
        onlyWithdraw: true,
        sentinelAddress: deployedAddress,
      };
      // Create and sign the message
      const messageHash = await createControllerSignature(withdrawParams);
      const signature = await account1.signMessage(
        hre.ethers.getBytes(messageHash)
      );
      const initialUsdtBalance = await usdt.balanceOf(deployedAddress);
      //Operator calls handleWithdrawOperator
      await deployedSentinel
        .connect(account2)
        .handleWithdrawOperator(
          withdrawParams.idBet,
          withdrawParams.totalFeeAmount,
          withdrawParams.quoteTimestamp,
          withdrawParams.exclusivityDeadline,
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          signature
        );
       //Check balance of USDT
       expect(await usdt.balanceOf(deployedAddress)).greaterThan(initialUsdtBalance);
    });

    it("Should execute withdraw multiple bet + swap successfully", async function () {
      const {
        deployedSentinel,
        deployedAddress,
        account1,
        account2,
        usdc,
        usdt,
        NFTMultiple,
      } = await loadFixture(deploySentinelFixture);
      //Impersonate 0xfA6a2662aF427b4645254293adE248285B72AA29 to transfet the NFT with id 327075 to sentinel address
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: ["0xCd94515535980f011DfC0f7F9C4Eea0506122F88"],
      });
      const expressSigner = await hre.ethers.getSigner(
        "0xCd94515535980f011DfC0f7F9C4Eea0506122F88"
      );

      await NFTMultiple.connect(expressSigner).transferFrom(
        "0xCd94515535980f011DfC0f7F9C4Eea0506122F88",
        deployedAddress,
        181358
      );
      //Check owner of the NFT
      expect(await NFTMultiple.ownerOf(181358)).to.equal(deployedAddress);

      const withdrawParams = {
        idBet: "181358",
        totalFeeAmount: "100", // 0.001 USDC
        quoteTimestamp: Math.floor(Date.now() / 1000),
        exclusivityDeadline: Math.floor(Date.now() / 1000) + 3600, // 1 hour from now
        exclusivityRelayer: account2.address as `0x${string}`,
        isMultipleBet: true,
        onlyWithdraw: false,
        sentinelAddress: deployedAddress,
      };
      // Create and sign the message
      const messageHash = await createControllerSignature(withdrawParams);
      const signature = await account1.signMessage(
        hre.ethers.getBytes(messageHash)
      );
      const initialUsdcBalance = await usdc.balanceOf(deployedAddress);
      //Operator calls handleWithdrawOperator
      await deployedSentinel
        .connect(account2)
        .handleWithdrawOperator(
          withdrawParams.idBet,
          withdrawParams.totalFeeAmount,
          withdrawParams.quoteTimestamp,
          withdrawParams.exclusivityDeadline,
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          signature
        );
      //Check balance of USDC
      expect(await usdc.balanceOf(deployedAddress)).greaterThan(
        initialUsdcBalance
      );
    });
  });
  it("Should fail when signature is from wrong wallet", async function () {
    const {
      deployedSentinel,
      deployedAddress,
      account1,
      account2,
      NFTSingle,
    } = await loadFixture(deploySentinelFixture);

    // Setup NFT transfer
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xfA6a2662aF427b4645254293adE248285B72AA29"],
    });
    const expressSigner = await hre.ethers.getSigner(
      "0xfA6a2662aF427b4645254293adE248285B72AA29"
    );

    await NFTSingle.connect(expressSigner).transferFrom(
      "0xfA6a2662aF427b4645254293adE248285B72AA29",
      deployedAddress,
      327075
    );

    const withdrawParams = {
      idBet: "327075",
      totalFeeAmount: "1000000",
      quoteTimestamp: Math.floor(Date.now() / 1000),
      exclusivityDeadline: Math.floor(Date.now() / 1000) + 3600,
      exclusivityRelayer: account2.address as `0x${string}`,
      isMultipleBet: false,
      onlyWithdraw: true,
      sentinelAddress: deployedAddress,
    };

    // Create signature with wrong account (account2 instead of controller account1)
    const messageHash = await createControllerSignature(withdrawParams);
    const wrongSignature = await account2.signMessage(
      hre.ethers.getBytes(messageHash)
    );

    // Should fail when using wrong signature
    await expect(
      deployedSentinel
        .connect(account2)
        .handleWithdrawOperator(
          withdrawParams.idBet,
          withdrawParams.totalFeeAmount,
          withdrawParams.quoteTimestamp,
          withdrawParams.exclusivityDeadline,
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          wrongSignature
        )
    ).to.be.revertedWithCustomError(deployedSentinel, "InvalidSignature");
  });

  it("Should fail when parameters don't match signature", async function () {
    const {
      deployedSentinel,
      deployedAddress,
      account1,
      account2,
      NFTSingle,
    } = await loadFixture(deploySentinelFixture);

    // Setup NFT transfer
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xfA6a2662aF427b4645254293adE248285B72AA29"],
    });
    const expressSigner = await hre.ethers.getSigner(
      "0xfA6a2662aF427b4645254293adE248285B72AA29"
    );

    await NFTSingle.connect(expressSigner).transferFrom(
      "0xfA6a2662aF427b4645254293adE248285B72AA29",
      deployedAddress,
      327075
    );

    const withdrawParams = {
      idBet: "327075",
      totalFeeAmount: "1000000",
      quoteTimestamp: Math.floor(Date.now() / 1000),
      exclusivityDeadline: Math.floor(Date.now() / 1000) + 3600,
      exclusivityRelayer: account2.address as `0x${string}`,
      isMultipleBet: false,
      onlyWithdraw: true,
      sentinelAddress: deployedAddress,
    };

    // Create valid signature
    const messageHash = await createControllerSignature(withdrawParams);
    const signature = await account1.signMessage(
      hre.ethers.getBytes(messageHash)
    );

    // Try to execute with different parameters than what was signed
    const differentAmount = "2000000"; // Different amount than what was signed
    await expect(
      deployedSentinel
        .connect(account2)
        .handleWithdrawOperator(
          withdrawParams.idBet,
          differentAmount, // Using different amount
          withdrawParams.quoteTimestamp,
          withdrawParams.exclusivityDeadline,
          withdrawParams.exclusivityRelayer,
          withdrawParams.isMultipleBet,
          withdrawParams.onlyWithdraw,
          signature
        )
    ).to.be.revertedWithCustomError(deployedSentinel, "InvalidSignature");
    */
  });
});

