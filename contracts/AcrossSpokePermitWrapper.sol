// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "./utils/ISignatureTransfer.sol";
import "./utils/V3SpokePoolInterface.sol";
import "./utils/ISwapRouter.sol";
import "./utils/IQuoter.sol";

/**
 * @title AcrossSpokePermitWrapper
 * @notice A wrapper contract that facilitates token deposits into Across Protocol's V3 SpokePool
 * with EIP-2612 permit functionality
 */
contract AcrossSpokePermitWrapper {
  // Custom errors to handle invalid input token and recipient addresses
  error InvalidInputToken(address providedToken);
  error InvalidRecipient(address providedRecipient);
  error InvalidAmountOutMin();

  // Interface to interact with the Across Protocol's V3 SpokePool
  V3SpokePoolInterface public spokePool;

  // Interface to interact with the Uniswap router
  ISwapRouter public swapRouter; // Uniswap router interface

  // Interface to interact with the Uniswap quoter
  IQuoter public quoter; // Uniswap quoter interface

  // Interface for Permit2 signature transfer functionality
  ISignatureTransfer public immutable permit2;

  // Contract configuration constants
  // USDC token address on the current chain
  address public constant USDC_ADDRESS =
    0x79A02482A880bCE3F13e09Da970dC34db4CD24d1;
  // Worldcoin token address on the current chain
  address public constant WLD_ADDRESS =
    0x2cFc85d8E48F8EAB294be644d9E25C3030863003;
  // Across Protocol handler address
  address public constant ACROSS_HANDLER_ADDRESS =
    0x924a9f036260DdD5808007E1AA95f08eD08aA569;
  // Across Protocol spoke pool address
  address public constant ACROSS_SPOKE_ADDRESS =
    0x09aea4b2242abC8bb4BB78D537A67a245A7bEC64;
  // Universal Permit2 contract address
  address public constant PERMIT2_ADDRESS =
    0x000000000022D47303072815b14704F0400E9014;
  // Uniswap router address
  address public constant SWAP_ROUTER_ADDRESS = 
    0x091AD9e2e6e5eD44c1c66dB50e49A601F9f36cF6;
  address public constant QUOTER_ADDRESS = //TODO To deploy
    0x000000000022D47303072815b14704F0400E9014;
  // Target chain ID for token bridging (137 = Polygon)
  uint256 public constant DESTINATION_CHAIN_ID = 137;
  uint24 public constant POOL_FEE = 10000; //1% fee

  /**
   * @notice Contract constructor
   */
  constructor() {
    spokePool = V3SpokePoolInterface(ACROSS_SPOKE_ADDRESS);
    permit2 = ISignatureTransfer(PERMIT2_ADDRESS);
    swapRouter = ISwapRouter(SWAP_ROUTER_ADDRESS);
    quoter = IQuoter(QUOTER_ADDRESS);
  }

  /**
   * @notice Struct containing parameters for deposit
   * @param depositor Address initiating the deposit
   * @param recipient Address receiving tokens on destination chain
   * @param inputToken Address of the input token
   * @param outputToken Address of the output token
   * @param inputAmount Amount of input tokens to deposit
   * @param outputAmount Expected amount of output tokens to receive
   * @param exclusiveRelayer Address of the relayer with exclusive rights to fill
   * @param quoteTimestamp Timestamp when the quote was generated
   * @param fillDeadline Deadline by which the deposit must be filled
   * @param exclusivityDeadline Deadline for exclusive relayer's rights
   * @param message Additional data to be passed with the deposit
   */
  struct DepositParams {
    address depositor;
    address recipient;
    address inputToken;
    address outputToken;
    uint256 inputAmount;
    uint256 outputAmount;
    address exclusiveRelayer;
    uint32 quoteTimestamp;
    uint32 fillDeadline;
    uint32 exclusivityDeadline;
    bytes message;
  }

  /**
   * @notice Deposits tokens into the SpokePool using EIP-2612 permit
   * @dev This function handles deposits using the traditional EIP-2612 permit mechanism
   * @param params Struct containing deposit parameters
   * @param v ECDSA signature parameter v
   * @param r ECDSA signature parameter r
   * @param s ECDSA signature parameter s
   * @param permitDeadline Deadline for the permit signature
   */
  function depositV3Permit(
    DepositParams calldata params,
    uint8 v,
    bytes32 r,
    bytes32 s,
    uint256 permitDeadline
  ) external payable {
    // Approve spending using permit
    IERC20Permit(params.inputToken).permit(
      msg.sender,
      address(this),
      params.inputAmount,
      permitDeadline,
      v,
      r,
      s
    );
    //Check if inputToken is USDC or WLD
    if (params.inputToken != USDC_ADDRESS && params.inputToken != WLD_ADDRESS) {
      revert InvalidInputToken(params.inputToken);
    }
    //Check if recipient is ACROSS_HANDLER
    if (params.recipient != ACROSS_HANDLER_ADDRESS) {
      revert InvalidRecipient(params.recipient);
    }

    // Transfer tokens from user to this contract
    IERC20(params.inputToken).transferFrom(
      msg.sender,
      address(this),
      params.inputAmount
    );

    uint256 amountToDeposit = params.inputAmount;
    // If token is WLD, swap it to USDC before depositing
    if (params.inputToken == WLD_ADDRESS) {
      amountToDeposit = _swap(WLD_ADDRESS, USDC_ADDRESS, params.inputAmount);
    }

    // Approve SpokePool to spend the tokens
    IERC20(USDC_ADDRESS).approve(address(spokePool), amountToDeposit);

    // Deposit tokens into the SpokePool
    spokePool.depositV3(
      params.depositor,
      params.recipient,
      USDC_ADDRESS,
      params.outputToken,
      amountToDeposit,
      params.outputAmount,
      DESTINATION_CHAIN_ID,
      params.exclusiveRelayer,
      params.quoteTimestamp,
      params.fillDeadline,
      params.exclusivityDeadline,
      params.message
    );
  }

  /**
   * @notice Internal function to swap WLD to USDC
   * @param tokenIn Address of the input token
   * @param tokenOut Address of the output token
   * @param amount Amount of WLD to swap
   * @return amountOut The amount of USDC received after the swap
   */
  function _swap(address tokenIn, address tokenOut, uint256 amount) internal returns (uint256 amountOut) {
    bytes memory path = abi.encodePacked(tokenIn, POOL_FEE, tokenOut);
    uint256 amountOutMin = quoter.quoteExactInput(path, amount);
    if (amount == 0) {
      revert InvalidAmountOutMin();
    }

    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams({
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        fee: POOL_FEE,
        recipient: address(this),
        //deadline: block.timestamp + 1800, // 30 minutes
        amountIn: amount,
        amountOutMinimum: amountOutMin,
        sqrtPriceLimitX96: 0
      });

    // Execute the swap
    amountOut = swapRouter.exactInputSingle(params);
  }

  /**
   * @notice Deposits tokens into the SpokePool using Permit2
   * @dev This function handles deposits using the more gas-efficient Permit2 mechanism
   * @param params Struct containing deposit parameters
   * @param permitTransfer Permit2 transfer parameters including token, amount, and nonce
   * @param signature User signature authorizing the transfer
   */
  function depositV3Permit2(
    DepositParams calldata params,
    ISignatureTransfer.PermitTransferFrom calldata permitTransfer,
    bytes calldata signature
  ) external payable {
    // Ensure input token is valid
    if (params.inputToken != USDC_ADDRESS && params.inputToken != WLD_ADDRESS) {
      revert InvalidInputToken(params.inputToken);
    }

    // Ensure recipient is ACROSS_HANDLER
    if (params.recipient != ACROSS_HANDLER_ADDRESS) {
      revert InvalidRecipient(params.recipient);
    }

    // Approve and transfer tokens using Permit2 SignatureTransfer
    ISignatureTransfer.SignatureTransferDetails
      memory transferDetails = ISignatureTransfer.SignatureTransferDetails({
        to: address(this),
        requestedAmount: permitTransfer.permitted.amount
      });
    permit2.permitTransferFrom(
      permitTransfer,
      transferDetails,
      msg.sender,
      signature
    );

    uint256 amountToDeposit = params.inputAmount;
    // If token is WLD, swap it to USDC before depositing
    if (params.inputToken == WLD_ADDRESS) {
        amountToDeposit = _swap(WLD_ADDRESS, USDC_ADDRESS, params.inputAmount);
    }

    // Approve SpokePool to spend the tokens
    IERC20(USDC_ADDRESS).approve(address(spokePool), amountToDeposit);

    // Deposit tokens into the SpokePool
    spokePool.depositV3(
      params.depositor,
      ACROSS_HANDLER_ADDRESS,
      USDC_ADDRESS,
      params.outputToken,
      amountToDeposit,
      params.outputAmount,
      DESTINATION_CHAIN_ID,
      params.exclusiveRelayer,
      params.quoteTimestamp,
      params.fillDeadline,
      params.exclusivityDeadline,
      params.message
    );
  }
}
