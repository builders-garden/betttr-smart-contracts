// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// ======================== Imports ========================
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./azuro-protocol/ILP.sol";
import "./azuro-protocol/IBet.sol";
import "./azuro-protocol/ICoreBase.sol";

// ======================== Contract Definition ========================
/**
 * @title AzuroHandler
 * @notice This contract handles betting operations using Azuro Protocol taking an optional protocol and referrer fee
 */
contract AzuroHandler is Pausable {
  using SafeERC20 for IERC20;

  // ======================== Events ========================
  event BetPlaced(
    uint256 indexed idBet,
    address indexed bettorAddress,
    address indexed referrerAddress,
    uint256 amountIn,
    address poolAddress
  );
  event FeePaid(
    uint256 indexed idBet,
    address indexed bettorAddress,
    address indexed referrerAddress,
    uint256 amountIn,
    uint256 amountOut,
    uint256 protocolFee,
    uint256 referrerFee
  );

  // ======================== Custom Errors ========================
  error NotOperator(address operator);
  error PausedState();
  error InvalidOperatorAddress();  
  error InvalidProtocolFeeRecipientAddress();
  error InvalidAmount();
  error InvalidBetData();
  error InvalidFeePercentage();
  error DuplicateConditionIds();
  error InvalidReferralFeePercentage();
  error InvalidProtocolFeePercentage();
  error InvalidBettorAddress();

  // ======================== Constants ========================
  uint256 private constant BASIS_POINTS = 10000; // 100% (100 * 100 = 10000)
  uint64  private constant MIN_ODDS = 1000000000000; // min odds Azuro (1*10^12)
  uint256 private constant MAX_REFERRER_FEE_PERCENTAGE = 500; // 5%
  uint256 private constant MAX_PROTOCOL_FEE_PERCENTAGE = 500; // 5%
  address private constant WETH = 0x4200000000000000000000000000000000000006; 
  address private constant AZURO_CORE = 0xf5A6B7940cbdb80F294f1eAc59575562966aa3FC; 
  address private constant AZURO_EXPRESS = 0x4731Bb0D12c4f992Cf02BDc7A48e8656d0E382Ed; 
  address private constant AZURO_LP = 0xF22E9e29728d6592eB54b916Ba9f464d9F237dB1; 

  // ======================== State Variables ========================
  address public operator; // Operator address for privileged operations
  address public protocolFeeRecipient; // Address receiving protocol fees

  // ======================== Modifiers ========================
  /**
   * @notice Ensures caller is operator
   */
  modifier onlyOperator() {
    if (msg.sender != operator) revert NotOperator(msg.sender);
    _;
  }

  /**
   * @notice Ensures contract is not paused
   */
  modifier whenNotPausedOverride() {
    if (paused()) revert PausedState();
    _;
  }

  //======================= Constructor ========================
  constructor(
    address _operator,
    address _protocolFeeRecipient
  ) {
    if (_operator == address(0)) revert InvalidOperatorAddress();
    if (_protocolFeeRecipient == address(0)) revert InvalidProtocolFeeRecipientAddress();
    operator = _operator;
    protocolFeeRecipient = _protocolFeeRecipient;
  }

  // ======================== Pausable Functions ========================
  /**
   * @notice Pauses the contract, disabling certain functions
   * @dev Only callable by the owner or operator
   */
  function pause() external onlyOperator {
    _pause();
  }

  /**
   * @notice Unpauses the contract, enabling previously disabled functions
   * @dev Only callable by the owner or operator
   */
  function unpause() external onlyOperator {
    _unpause();
  }

  // ======================== Setter Functions ========================
  /**
   * @notice Sets a new operator address
   * @dev Only callable by the current operator
   * @param _operator New operator address
   */
  function setOperator(
    address _operator
  ) external onlyOperator {
    if (_operator == address(0)) revert InvalidOperatorAddress();
    operator = _operator;
  }

  /**
   * @notice Sets the protocol fee recipient address
   * @dev Only callable by the operator
   * @param _protocolFeeRecipient New fee recipient address
   */
  function setProtocolFeeRecipient(
    address _protocolFeeRecipient
  ) external onlyOperator {
    if (_protocolFeeRecipient == address(0)) revert InvalidProtocolFeeRecipientAddress();
    protocolFeeRecipient = _protocolFeeRecipient;
  }

  // ======================== Core Functions ========================

  /**
   * @notice Handles incoming bets from the source chain
   * @param bettorAddress Address of the bettor
   * @param amountIn Amount of tokens being sent
   * @param referrerAddress Address of the referrer
   * @param referrerFeePercentage Referrer fee percentage
   * @param minOdds Minimum odds
   * @param conditions Bet conditions
   * @param outcomes Bet outcomes
   */
  function handleBet(
    address bettorAddress,
    uint256 amountIn,
    address referrerAddress,
    uint256 referrerFeePercentage,
    uint256 protocolFeePercentage,
    uint64 minOdds,
    uint256[] memory conditions,
    uint64[] memory outcomes
  ) external whenNotPausedOverride returns (uint256 idBet) {
    // Validate amount
    if (amountIn == 0) revert InvalidAmount();
    // Validate bettor address
    if (bettorAddress == address(0)) revert InvalidBettorAddress();
    // Validate array lengths match
    if (conditions.length != outcomes.length || conditions.length == 0) revert InvalidBetData();
    // Validate protocol fee percentage
    if (protocolFeePercentage > MAX_PROTOCOL_FEE_PERCENTAGE) revert InvalidProtocolFeePercentage();
    // Validate referrer fee percentage only if referrer address is provided
    if (referrerAddress != address(0) && referrerFeePercentage > MAX_REFERRER_FEE_PERCENTAGE) 
      revert InvalidReferralFeePercentage();

    // Transfer the tokens to the contract
    IERC20(WETH).safeTransferFrom(msg.sender, address(this), amountIn);

    // handle protocol fee function
    uint256 amountInAfterProtocolFee = _handleProtocolFee(amountIn, protocolFeePercentage);
    uint256 amountInAfterReferrerFee = amountInAfterProtocolFee;

    if (referrerAddress != address(0)) {
      amountInAfterReferrerFee = _handleReferrerFee(
        referrerAddress,
        amountInAfterProtocolFee,
        referrerFeePercentage
      );
    }

    // Approve LP to spend swapped tokens
    IERC20(WETH).approve(AZURO_LP, amountInAfterReferrerFee);

    // Place bets for the player
    idBet = _bet(
      bettorAddress,
      referrerAddress,
      uint128(amountInAfterReferrerFee),
      conditions,
      outcomes,
      minOdds,
      conditions.length > 1 // isExpress = true if multiple bets
    );
    emit FeePaid(idBet, bettorAddress, referrerAddress, amountIn, amountInAfterReferrerFee, protocolFeePercentage, referrerFeePercentage);
  }

  // ======================== Internal Helper Functions ========================

  /**
   * @notice Places a bet on the Azuro protocol
   * @dev Constructs and submits bet data to the Azuro LP
   * @param amountOut Amount of tokens to bet
   * @param conditions Bet conditions
   * @param outcomes Bet outcomes
   * @param isMultiple Whether this is part of an express bet
   * @return idBet ID of the placed bet
   */
  function _bet(
    address bettorAddress,
    address referrerAddress,
    uint128 amountOut,
    uint256[] memory conditions,
    uint64[] memory outcomes,
    uint64 minOdds,
    bool isMultiple
  ) internal returns (uint256 idBet) {
    if (minOdds < MIN_ODDS) {
      minOdds = MIN_ODDS;
    }
    uint64 expiresAt = uint64(block.timestamp + 1800); // 30 minutes

    if (isMultiple) {
      // Create array of CoreBetData for multiple bets
      ICoreBase.CoreBetData[] memory subBets = new ICoreBase.CoreBetData[](
        conditions.length
      );

      // Fill the array with bet data
      for (uint256 i = 0; i < conditions.length; i++) {
        subBets[i] = ICoreBase.CoreBetData({
          conditionId: conditions[i],
          outcomeId: outcomes[i]
        });
      }
      // Encode the CoreBetData array
      bytes memory encodedBetData = abi.encode(subBets);
      // Create the BetData struct
      IBet.BetData memory betData = IBet.BetData({
        affiliate: protocolFeeRecipient,
        minOdds: minOdds,
        data: encodedBetData
      });
      // Place the bet for the bettor address on the express azuro contract (multiple bets)
      idBet = ILP(AZURO_LP).betFor(
        bettorAddress,
        AZURO_EXPRESS,
        amountOut,
        expiresAt,
        betData
      );
      emit BetPlaced(idBet, bettorAddress, referrerAddress, amountOut, AZURO_EXPRESS);
    } else {
      // Encode the bet data for the single bet
      bytes memory encodedBetData = abi.encode(conditions[0], outcomes[0]);
      // Single bet case remains unchanged
      IBet.BetData memory betData = IBet.BetData({
        affiliate: protocolFeeRecipient,
        minOdds: minOdds,
        data: encodedBetData
      });
      // Place the bet for the bettor address on the core azuro contract (single bet)
      idBet = ILP(AZURO_LP).betFor(
        bettorAddress,
        AZURO_CORE,
        amountOut,
        expiresAt,
        betData
      );
      emit BetPlaced(idBet, bettorAddress, referrerAddress, amountOut, AZURO_CORE);
    }
  }

  /**
   * @notice Handles protocol fee deduction
   * @param amount Amount to process
   * @return Amount after fee deduction
   */
  function _handleProtocolFee(
    uint256 amount,
    uint256 protocolFeePercentage
  ) internal returns (uint256) {
    uint256 protocolFee = _calculatePercentage(amount, protocolFeePercentage);
    if (protocolFee == 0) {
      return amount;
    }
    IERC20(WETH).safeTransfer(protocolFeeRecipient, protocolFee);
    uint256 amountAfterFee = amount - protocolFee;
    return amountAfterFee;
  }

  /**
   * @notice Handles referrer fee deduction
   * @param amount Amount to process
   * @return Amount after fee deduction
   */
  function _handleReferrerFee(
    address referrer,
    uint256 amount,
    uint256 referrerFeePercentage
  ) internal returns (uint256) {
    uint256 referrerFee = _calculatePercentage(amount, referrerFeePercentage);
    if (referrerFee == 0) {
      return amount;
    }
    IERC20(WETH).safeTransfer(referrer, referrerFee);
    uint256 amountAfterFee = amount - referrerFee;
    return amountAfterFee;
  }

  /**
   * @notice Calculates percentage of an amount using basis points
   * @dev Used for fee calculations
   * @param amount The amount to calculate the percentage of
   * @param basisPoints The basis points representing the percentage
   * @return The calculated percentage of the amount
   */
  function _calculatePercentage(
    uint256 amount,
    uint256 basisPoints
  ) internal pure returns (uint256) {
    if (basisPoints == 0 || amount == 0) {
      return 0;
    }
    if (basisPoints > BASIS_POINTS) revert InvalidFeePercentage();
    return (amount * basisPoints) / BASIS_POINTS;
  }
}

