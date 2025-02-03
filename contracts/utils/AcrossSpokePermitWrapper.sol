// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./V3SpokePoolInterface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

contract AcrossSpokePermitWrapper {
  V3SpokePoolInterface public spokePool;

  address public inputToken;
  address public outputToken;
  uint256 public destinationChainId;

  constructor(address _spokePool) {
    spokePool = V3SpokePoolInterface(_spokePool);
  }

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

  function depositV3Permit(
    DepositParams calldata params,
    uint8 v,
    bytes32 r,
    bytes32 s,
    uint256 permitDeadline
  ) external payable {
    //Permit approval
    IERC20Permit(inputToken).permit(
      msg.sender,
      address(this),
      params.inputAmount,
      permitDeadline,
      v,
      r,
      s
    );
    //Transfer the input token from the depositor to the contract
    IERC20(inputToken).transferFrom(
      msg.sender,
      address(this),
      params.inputAmount
    );
    //Approve the spoke pool to spend the input token
    IERC20(inputToken).approve(address(spokePool), params.inputAmount);
    //Deposit the input token into the spoke pool
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
