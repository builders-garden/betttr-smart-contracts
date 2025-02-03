// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./V3SpokePoolInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

/**
 * @title AcrossSpokePermitWrapper
 * @notice A wrapper contract that facilitates token deposits into Across Protocol's V3 SpokePool
 * with EIP-2612 permit functionality
 */
contract AcrossSpokePermitWrapper {
  // Reference to the main SpokePool contract
  V3SpokePoolInterface public spokePool;

  // Token configuration
  address public inputToken; // Token being deposited
  address public outputToken; // Token to receive on the destination chain
  uint256 public destinationChainId; // Target chain ID for the bridge transfer

  /**
   * @notice Contract constructor
   * @param _spokePool Address of the V3SpokePool contract
   */
  constructor(address _spokePool) {
    spokePool = V3SpokePoolInterface(_spokePool);
  }

  /**
   * @notice Struct containing parameters for deposit
   * @param depositor Address initiating the deposit
   * @param recipient Address receiving tokens on destination chain
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
    IERC20Permit(inputToken).permit(
      msg.sender,
      address(this),
      params.inputAmount,
      permitDeadline,
      v,
      r,
      s
    );

    // Transfer tokens from user to this contract
    IERC20(inputToken).transferFrom(
      msg.sender,
      address(this),
      params.inputAmount
    );

    // Approve SpokePool to spend the tokens
    IERC20(inputToken).approve(address(spokePool), params.inputAmount);

    // Deposit tokens into the SpokePool
    spokePool.depositV3(
      params.depositor,
      params.recipient,
      inputToken,
      outputToken,
      params.inputAmount,
      params.outputAmount,
      destinationChainId,
      params.exclusiveRelayer,
      params.quoteTimestamp,
      params.fillDeadline,
      params.exclusivityDeadline,
      params.message
    );
  }
}
