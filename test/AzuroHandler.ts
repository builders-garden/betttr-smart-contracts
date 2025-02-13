import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ERC20ABI } from "./ERC20ABI";
import { HardhatEthersSigner } from "@nomicfoundation/hardhat-ethers/signers";

describe("AzuroHandler", function () {
  async function deployAzuroHandlerFixture() {
    const [account1, account2] = await hre.ethers.getSigners();
    const WETH = "0x4200000000000000000000000000000000000006";
    const ADDRESS_TO_IMPERSONATE = "0xecbf6e57d9430b8F79927e6109183846fab55D25";

    // Deploy AzuroHandler
    const AzuroHandler = await hre.ethers.getContractFactory("AzuroHandler");
    const azuroHandler = await AzuroHandler.connect(account2).deploy(
      account1.address,
      account1.address,
      10
    );
    const weth = await hre.ethers.getContractAt("IERC20", WETH);

    return {
      AzuroHandler,
      azuroHandler,
      account1,
      account2,
      weth,
      ADDRESS_TO_IMPERSONATE,
    };
  }

  describe("Deployment", function () {
    it("Should set correct operator and controller", async function () {
      const { azuroHandler, account1, account2 } = await loadFixture(
        deployAzuroHandlerFixture
      );

      expect(await azuroHandler.operator()).to.equal(account1.address);
      expect(await azuroHandler.protocolFeeRecipient()).to.equal(
        account1.address
      );
    });

    it("Should execute handleBet successfully", async function () {
      const { azuroHandler, account1, account2, weth, ADDRESS_TO_IMPERSONATE } =
        await loadFixture(deployAzuroHandlerFixture);

      const betParams = {
        conditions: ["100610060000000000265432240000000000000445516243"],
        outcomes: ["29"],
        referrer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
        amount: "1000000000000000", // 0.001 WETH
      };
      // Get initial balances
      const initialProtocolBalance = await weth.balanceOf(ADDRESS_TO_IMPERSONATE);
      console.log(initialProtocolBalance, "initialProtocolBalance");

      // Impersonate acrossGenericHandler
      await hre.network.provider.request({
        method: "hardhat_impersonateAccount",
        params: [ADDRESS_TO_IMPERSONATE],
      });

      const impersonatedSigner = await hre.ethers.getSigner(
        ADDRESS_TO_IMPERSONATE
      );

      await weth
        .connect(impersonatedSigner)
        .approve(azuroHandler, betParams.amount);
      console.log("approve");

      // Execute handleBet with the properly formatted signature
      await azuroHandler
        .connect(impersonatedSigner)
        .handleBet(
          ADDRESS_TO_IMPERSONATE,
          BigInt(betParams.amount),
          account2.address,
          10,
          1,
          betParams.conditions,
          betParams.outcomes
        );
      console.log("handleBet");

      expect(await weth.balanceOf(ADDRESS_TO_IMPERSONATE)).to.equal(
        initialProtocolBalance - BigInt(betParams.amount)
      );

      await hre.network.provider.request({
        method: "hardhat_stopImpersonatingAccount",
        params: [ADDRESS_TO_IMPERSONATE],
      });
    });
    it("Should execute handleBet for multiple bets successfully", async function () {
        const { azuroHandler, account1, account2, weth, ADDRESS_TO_IMPERSONATE } =
          await loadFixture(deployAzuroHandlerFixture);
  
        const betParams = {
          conditions: ["100110010000000016041637470000000000000482029026","100610060000000000265432240000000000000445516243", "100610060000000000265432220000000000000445489762", "100610060000000000265432230000000000000447416988", "100610060000000000265496110000000000000438244136", "100610060000000000265432210000000000000445507486"],
          outcomes: ["6984","29", "29", "29", "29", "55"],
          referrer: "0x216BeA48DE17eba784027a591DBD2866EF606EC6",
          amount: "1000000000000000", // 0.001 WETH
        };
  
        // Get initial balances
        const initialProtocolBalance = await weth.balanceOf(ADDRESS_TO_IMPERSONATE);
        console.log(initialProtocolBalance, "initialProtocolBalance");
  
        // Impersonate acrossGenericHandler
        await hre.network.provider.request({
          method: "hardhat_impersonateAccount",
          params: [ADDRESS_TO_IMPERSONATE],
        });
  
        const impersonatedSigner = await hre.ethers.getSigner(
          ADDRESS_TO_IMPERSONATE
        );
  
        await weth
          .connect(impersonatedSigner)
          .approve(azuroHandler, betParams.amount);
        console.log("approve");
  
        // Execute handleBet with the properly formatted signature
        await azuroHandler
          .connect(impersonatedSigner)
          .handleBet(
            ADDRESS_TO_IMPERSONATE,
            BigInt(betParams.amount),
            account2.address,
            10,
            1,
            betParams.conditions,
            betParams.outcomes
          );
        console.log("handleBet");
  
        expect(await weth.balanceOf(ADDRESS_TO_IMPERSONATE)).to.equal(
          initialProtocolBalance - BigInt(betParams.amount)
        );
  
        await hre.network.provider.request({
          method: "hardhat_stopImpersonatingAccount",
          params: [ADDRESS_TO_IMPERSONATE],
        });
      });
  });
});
