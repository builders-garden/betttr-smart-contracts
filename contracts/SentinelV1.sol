// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//TODO: change factory address as const
//NOTES:
//deploy quoter contract on worldchain

// ======================== Imports ========================
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./utils/ISwapRouter.sol";
import "./azuro-protocol/ILP.sol";
import "./utils/V3SpokePoolInterface.sol";
import "./utils/IQuoter.sol";
import "./azuro-protocol/IAzuroBet.sol";
import "./azuro-protocol/IBet.sol";
import "./azuro-protocol/ICoreBase.sol";

// ======================== Contract Definition ========================
/**
 * @title Sentinel
 * @notice This contract handles cross-chain sports betting operations using Azuro Protocol and Across Bridge
 * @dev Acts as a destination chain contract that receives bets and processes withdrawals
 */
contract SentinelV1 is ReentrancyGuard, Pausable, IERC721Receiver {
  using SafeERC20 for IERC20;

  // ======================== Events ========================
  event BetPlaced(uint256 indexed idBet, bool isMultipleBet);
  event WithdrawBet(uint256 indexed idBet, bool isMultipleBet, bool onlyWithdraw);
  event OperatorChanged(
    address indexed oldOperator,
    address indexed newOperator
  );
  event ProtocolFeeRecipientChanged(
    address indexed oldRecipient,
    address indexed newRecipient
  );
  event ProtocolFeePercentageChanged(uint256 oldFee, uint256 newFee);
  event ReferralFeePercentageChanged(uint256 oldFee, uint256 newFee);
  event CoreBaseChanged(
    address indexed oldCoreBase,
    address indexed newCoreBase
  );
  event QuoterChanged(address indexed oldQuoter, address indexed newQuoter);
  event PoolFeeChanged(uint24 oldFee, uint24 newFee);
  event DestinationChainIdChanged(uint256 oldChainId, uint256 newChainId);
  event ProtocolInitialized();
  event CoreInitialized();
  event EmergencyWithdraw(address indexed token, uint256 amount);

  // ======================== Custom Errors ========================
  error AlreadyInitialized(address controller);
  error AlreadyProtocolInitialized();
  error NotAcrossHandler(address acrossGenericHandler);
  error NotOperator(address operator);
  error NotController(address controller);
  error NotSentinel();
  error NotControllerOrOperator(address controller);
  error NotFactory(address factory);
  error InvalidControllerAddress();
  error InvalidAmountOutMin();
  error InvalidAmountForAcross();
  error InvalidExpressAddress();
  error InvalidOperatorAddress();
  error InvalidSwapRouterAddress();
  error InvalidLPAddress();
  error InvalidAzuroBetAddress();
  error InvalidUSDCAddress();
  error InvalidUSDTAddress();
  error InvalidAcrossHandlerAddress();
  error InvalidAcrossSpokePoolAddress();
  error InvalidQuoterAddress();
  error InvalidPoolFee();
  error InvalidDestinationChainId();
  error InvalidProtocolFeePercentage();
  error InvalidProtocolFeeRecipientAddress();
  error InvalidReferralFeePercentage();
  error InvalidCoreBaseAddress();
  error InvalidTokenAddress();
  error InvalidAmount();
  error PausedState();
  error ArrayLengthsMismatch();
  error EmptyBetArrays();
  error DuplicateConditionIds();
  error InvalidSignatureLength();
  error InvalidSignatureS();
  error InvalidSignatureV();
  error InvalidSignature();
  error InvalidSigner();
  error NonceAlreadyUsed(bytes32 nonce);

  // ======================== Constants ========================
  uint256 private constant BASIS_POINTS = 10000; // 100% (100 * 100 = 10000)
  uint256 private constant USDC_DECIMALS = 6; // 1 USDC = 10^6 USDC
  address private constant FACTORY = 0x0000000000000000000000000000000000000000; //TODO

  // ======================== State Variables ========================
  // Access Control
  address public operator; // Operator address for privileged operations
  address public controller; // Controller address for privileged operations

  // Protocol Configuration
  address public protocolFeeRecipient; // Address receiving protocol fees
  uint256 public protocolFeeBetPercentage; // Fee percentage in basis points
  uint256 public protocolFeeWithdrawPercentage; // Fee percentage in basis points
  uint256 public referralFeePercentage; // Referral fee percentage in basis points
  uint256 public destinationChainId; // Target chain ID for cross-chain operations

  // Protocol Addresses
  address public acrossGenericHandler; // Across bridge handler address
  address public acrossSpokePool; // Across spoke pool address
  address public coreBase; // Azuro core contract address
  address public azuroBet; // Azuro bet interface
  address public expressAddress; // Express address for multiple bets
  address public quoter; // Uniswap quoter address
  address public usdcAddress; // USDC token address
  address public usdcAddressDestination; // USDC token address on destination chain
  address public usdtAddress; // USDT token address
  uint24 public poolFee; // Uniswap pool fee

  // Protocol Interfaces
  ISwapRouter public swapRouter; // Uniswap router interface
  ILP public lp; // Azuro liquidity pool interface
  bool public initialized; // Initialization status
  bool public protocolInitialized; // Protocol initialization status

  // Domain Separator for EIP-712
  bytes32 private DOMAIN_SEPARATOR;

  // Add nonce mapping
  mapping(bytes32 => bool) public usedBetNonces;
  mapping(bytes32 => bool) public usedWithdrawNonces;

  // Update type hashes to include nonce
  bytes32 private constant BET_TYPEHASH =
    keccak256(
      "Bet(address tokenIn,address tokenOut,uint256 amountIn,bytes32 betHash,address verifyingContract,bytes32 nonce)"
    );

  bytes32 private constant WITHDRAW_TYPEHASH =
    keccak256(
      "Withdraw(uint256 idBet,uint256 amountOut,uint32 quoteTimestamp,uint32 exclusivityDeadline,address exclusivityRelayer,bool isMultipleBet,bool onlyWithdraw,address verifyingContract,bytes32 nonce)"
    );

  // ======================== Modifiers ========================

  /**
   * @notice Ensures caller is operator
   */
  modifier onlyOperator() {
    if (msg.sender != operator) {
      revert NotOperator(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures caller is controller
   */
  modifier onlyController() {
    if (msg.sender != controller) {
      revert NotController(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures caller is factory
   */
  modifier onlyFactory() {
    if (msg.sender != FACTORY) {
      revert NotFactory(msg.sender);
    }
    _;
  }

  /**
   * @notice Ensures contract is not paused
   */
  modifier whenNotPausedOverride() {
    if (paused()) {
      revert PausedState();
    }
    _;
  }

  // ======================== Initialization Functions ========================

  /**
   * @notice First phase initialization with core parameters
   */
  function initializeCore(
    address _owner,
    address _operator,
    ISwapRouter _swapRouter,
    ILP _lp,
    address _azuroBet,
    address _usdcAddress,
    address _usdcAddressDestination,
    address _usdtAddress
  ) external onlyFactory {
    _initializeCore(
      _owner,
      _operator,
      _swapRouter,
      _lp,
      _azuroBet,
      _usdcAddress,
      _usdcAddressDestination,
      _usdtAddress
    );
  }

  /**
   * @notice Second phase initialization with protocol parameters
   */
  function initializeProtocol(
    address _acrossGenericHandler,
    address _acrossSpokePool,
    address _protocolFeeRecipient,
    uint256 _protocolFeeBetPercentage,
    uint256 _protocolFeeWithdrawPercentage,
    uint256 _referralFeePercentage,
    address _coreBase,
    address _expressAddress,
    address _quoter,
    uint24 _poolFee,
    uint256 _destinationChainId
  ) external onlyFactory {
    _initializeProtocol(
      _acrossGenericHandler,
      _acrossSpokePool,
      _protocolFeeRecipient,
      _protocolFeeBetPercentage,
      _protocolFeeWithdrawPercentage,
      _referralFeePercentage,
      _coreBase,
      _expressAddress,
      _quoter,
      _poolFee,
      _destinationChainId
    );
  }

  /**
   * @dev Internal function to initialize core contract state
   */
  function _initializeCore(
    address _controller,
    address _operator,
    ISwapRouter _swapRouter,
    ILP _lp,
    address _azuroBet,
    address _usdcAddress,
    address _usdcAddressDestination,
    address _usdtAddress
  ) private {
    if (initialized) {
      revert AlreadyInitialized(controller);
    }
    if (_controller == address(0)) revert InvalidControllerAddress();
    if (_operator == address(0)) revert InvalidOperatorAddress();
    if (address(_swapRouter) == address(0)) revert InvalidSwapRouterAddress();
    if (address(_lp) == address(0)) revert InvalidLPAddress();
    if (address(_azuroBet) == address(0)) revert InvalidAzuroBetAddress();
    if (_usdcAddress == address(0)) revert InvalidUSDCAddress();
    if (_usdcAddressDestination == address(0)) revert InvalidUSDCAddress();
    if (_usdtAddress == address(0)) revert InvalidUSDTAddress();

    operator = _operator;
    controller = _controller;
    swapRouter = _swapRouter;
    lp = _lp;
    azuroBet = _azuroBet;
    usdcAddress = _usdcAddress;
    usdcAddressDestination = _usdcAddressDestination;
    usdtAddress = _usdtAddress;
    initialized = true;

    emit CoreInitialized();
  }

  /**
   * @dev Internal function to initialize protocol parameters
   */
  function _initializeProtocol(
    address _acrossGenericHandler,
    address _acrossSpokePool,
    address _protocolFeeRecipient,
    uint256 _protocolFeeBetPercentage,
    uint256 _protocolFeeWithdrawPercentage,
    uint256 _referralFeePercentage,
    address _coreBase,
    address _expressAddress,
    address _quoter,
    uint24 _poolFee,
    uint256 _destinationChainId
  ) private {
    if (protocolInitialized) {
      revert AlreadyProtocolInitialized();
    }
    if (_protocolFeeBetPercentage == 0) revert InvalidProtocolFeePercentage();
    if (_protocolFeeWithdrawPercentage == 0) revert InvalidProtocolFeePercentage();
    if (_acrossGenericHandler == address(0))
      revert InvalidAcrossHandlerAddress();
    if (_acrossSpokePool == address(0)) revert InvalidAcrossSpokePoolAddress();
    if (_protocolFeeRecipient == address(0))
      revert InvalidProtocolFeeRecipientAddress();
    if (_referralFeePercentage == 0) revert InvalidReferralFeePercentage();
    if (_coreBase == address(0)) revert InvalidCoreBaseAddress();
    if (_expressAddress == address(0)) revert InvalidExpressAddress();
    if (_quoter == address(0)) revert InvalidQuoterAddress();
    if (_poolFee == 0) revert InvalidPoolFee();
    if (_destinationChainId == 0) revert InvalidDestinationChainId();

    acrossGenericHandler = _acrossGenericHandler;
    acrossSpokePool = _acrossSpokePool;
    protocolFeeRecipient = _protocolFeeRecipient;
    protocolFeeBetPercentage = _protocolFeeBetPercentage;
    protocolFeeWithdrawPercentage = _protocolFeeWithdrawPercentage;
    referralFeePercentage = _referralFeePercentage;
    coreBase = _coreBase;
    expressAddress = _expressAddress;
    quoter = _quoter;
    poolFee = _poolFee;
    destinationChainId = _destinationChainId;
    protocolInitialized = true;

    DOMAIN_SEPARATOR = keccak256(
      abi.encode(
        keccak256(
          "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        ),
        keccak256("BetVerifier"),
        keccak256("1"),
        block.chainid,
        address(this)
      )
    );

    emit ProtocolInitialized();
  }

  // ======================== Setter Functions ========================

  /**
   * @notice Sets a new operator address
   * @dev Only callable by the current operator
   * @param _operator New operator address
   */
  function setOperator(
    address _operator
  ) external onlyOperator whenNotPausedOverride {
    if (_operator == address(0)) revert InvalidOperatorAddress();
    address oldOperator = operator;
    operator = _operator;
    emit OperatorChanged(oldOperator, _operator);
  }

  /**
   * @notice Sets the protocol fee recipient address
   * @dev Only callable by the operator
   * @param _protocolFeeRecipient New fee recipient address
   */
  function setProtocolFeeRecipient(
    address _protocolFeeRecipient
  ) external onlyOperator whenNotPausedOverride {
    if (_protocolFeeRecipient == address(0))
      revert InvalidProtocolFeeRecipientAddress();
    address oldRecipient = protocolFeeRecipient;
    protocolFeeRecipient = _protocolFeeRecipient;
    emit ProtocolFeeRecipientChanged(oldRecipient, _protocolFeeRecipient);
  }

  /**
   * @notice Sets the protocol fee percentage
   * @dev Only callable by the operator
   * @param _protocolFeePercentage New fee percentage in basis points (max 1000 = 10%)
   * @param forBet If true, set protocol fee percentage for bet, otherwise set for withdraw
   */
  function setProtocolFeePercentage(
    uint256 _protocolFeePercentage,
    bool forBet
  ) external onlyOperator whenNotPausedOverride {
    if (_protocolFeePercentage == 0) revert InvalidProtocolFeePercentage();
    if (forBet) {
      uint256 oldFee = protocolFeeBetPercentage;
      protocolFeeBetPercentage = _protocolFeePercentage;
      emit ProtocolFeePercentageChanged(oldFee, _protocolFeePercentage);
    } else {
      uint256 oldFee = protocolFeeWithdrawPercentage;
      protocolFeeWithdrawPercentage = _protocolFeePercentage;
      emit ProtocolFeePercentageChanged(oldFee, _protocolFeePercentage);
    }
  }

  /**
   * @notice Sets the referral fee percentage
   * @dev Only callable by the operator
   * @param _referralFeePercentage New fee percentage in basis points (max 1000 = 10%)
   */
  function setReferralFeePercentage(
    uint256 _referralFeePercentage
  ) external onlyOperator whenNotPausedOverride {
    if (_referralFeePercentage == 0) revert InvalidReferralFeePercentage();
    uint256 oldFee = referralFeePercentage;
    referralFeePercentage = _referralFeePercentage;
    emit ReferralFeePercentageChanged(oldFee, _referralFeePercentage);
  }

  /**
   * @notice Updates the Uniswap pool fee
   * @dev Only callable by the operator
   * @param _poolFee New pool fee
   */
  function setPoolFee(
    uint24 _poolFee
  ) external onlyOperator whenNotPausedOverride {
    if (_poolFee == 0) revert InvalidPoolFee();
    uint24 oldFee = poolFee;
    poolFee = _poolFee;
    emit PoolFeeChanged(oldFee, _poolFee);
  }

  // ======================== Core Functions ========================

  /**
   * @notice Handles incoming bets from the source chain
   * @param tokenIn Source token address
   * @param tokenOut Destination token address
   * @param amountIn Amount of tokens being sent
   * @param bet Encoded bet data (array of condition, outcome, referrer)
   */
  function handleBet(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    bytes memory bet,
    bytes memory signature,
    bytes32 nonce
  ) external nonReentrant whenNotPausedOverride {
    if (tokenIn == address(0) || tokenOut == address(0)) {
      revert InvalidTokenAddress();
    }
    if (amountIn == 0) {
      revert InvalidAmount();
    }
    if (msg.sender != controller) {
      // Verify controller signature
      _verifyControllerSignatureBet(
        tokenIn,
        tokenOut,
        amountIn,
        bet,
        signature,
        nonce
      );
    }

    IERC20(tokenIn).safeTransferFrom(
      acrossGenericHandler,
      address(this),
      amountIn
    );

    // handle protocol fee function
    uint256 amountInAfterProtocolFee = _handleProtocolFee(amountIn, tokenIn, true);

    // Decode bet data
    (
      uint256[] memory conditions,
      uint64[] memory outcomes,
      address referrer
    ) = abi.decode(bet, (uint256[], uint64[], address));

    // Validate array lengths match
    require(conditions.length == outcomes.length, "Array lengths mismatch");
    require(conditions.length > 0, "Empty bet arrays");

    uint256 referralFees = 0;

    if (referrer != address(0)) {
      referralFees = _calculatePercentage(
        amountInAfterProtocolFee,
        referralFeePercentage
      );
      if (referralFees != 0) {
        IERC20(tokenIn).safeTransfer(referrer, referralFees);
      }
    }

    uint256 amountInAfterReferralFees = amountInAfterProtocolFee - referralFees;

    // Approve swapRouter to spend tokens
    IERC20(tokenIn).forceApprove(
      address(swapRouter),
      amountInAfterReferralFees
    );

    uint256 amountOut = _swap(tokenIn, tokenOut, amountInAfterReferralFees);

    // Approve LP to spend swapped tokens
    IERC20(tokenOut).forceApprove(address(lp), amountOut);

    // Place bets for the player
    (uint256 idBet, bool isMultipleBet) = _bet(
      uint128(amountOut),
      conditions,
      outcomes,
      conditions.length > 1 // isExpress = true if multiple bets
    );
    emit BetPlaced(idBet, isMultipleBet);
  }

  /**
   * @notice Processes bet withdrawals and sends funds back across the bridge
   * @dev Only callable by the owner or operator
   * @param idBet Bet ID to withdraw
   * @param totalFeeAmount Amount to withdraw
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
   */
  function handleWithdraw(
    uint256 idBet,
    uint256 totalFeeAmount,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw,
    bytes memory signature,
    bytes32 nonce
  ) external nonReentrant whenNotPausedOverride {
    if (msg.sender != controller) {
      // Verify controller signature
      _verifyControllerSignatureWithdraw(
        idBet,
        totalFeeAmount,
        quoteTimestamp,
        exclusivityDeadline,
        exclusivityRelayer,
        isMultipleBet,
        onlyWithdraw,
        signature,
        nonce
      );
    }
    _handleWithdraw(
      idBet,
      totalFeeAmount,
      quoteTimestamp,
      exclusivityDeadline,
      exclusivityRelayer,
      isMultipleBet,
      onlyWithdraw
    );
    emit WithdrawBet(idBet, isMultipleBet, onlyWithdraw);
  }

  // ======================== Emergency Functions ========================

  /**
   * @notice Allows controller to withdraw tokens to owner's wallet
   * @param token Token address
   * @param amount Amount of tokens to withdraw
   */
  function emergencyWithdraw(
    address token,
    uint256 amount
  ) external onlyController {
    if (token == address(0)) {
      revert InvalidTokenAddress();
    }
    IERC20(token).safeTransfer(controller, amount);
    emit EmergencyWithdraw(token, amount);
  }

  // ======================== Pausable Functions ========================

  /**
   * @notice Pauses the contract, disabling certain functions
   * @dev Only callable by the owner or operator
   */
  function pause() external onlyOperator {
    _pause();
    emit Paused(msg.sender);
  }

  /**
   * @notice Unpauses the contract, enabling previously disabled functions
   * @dev Only callable by the owner or operator
   */
  function unpause() external onlyOperator {
    _unpause();
    emit Unpaused(msg.sender);
  }

  // ======================== Internal Helper Functions ========================

  /**
   * @notice Performs token swap using Uniswap V3
   * @dev Uses the quoter to determine minimum output amount
   * @param tokenIn Input token address
   * @param tokenOut Output token address
   * @param amountIn Amount of input tokens
   * @return amountOut Amount of output tokens received
   */
  function _swap(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) internal returns (uint256 amountOut) {
    bytes memory path = abi.encodePacked(tokenIn, poolFee, tokenOut);
    uint256 amountOutMin = IQuoter(quoter).quoteExactInput(path, amountIn);
    if (amountOutMin == 0) {
      revert InvalidAmountOutMin();
    }

    ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
      .ExactInputSingleParams({
        tokenIn: tokenIn,
        tokenOut: tokenOut,
        fee: poolFee,
        recipient: address(this),
        //deadline: block.timestamp + 1800, // 30 minutes
        amountIn: amountIn,
        amountOutMinimum: amountOutMin,
        sqrtPriceLimitX96: 0
      });

    // Execute the swap
    amountOut = swapRouter.exactInputSingle(params);
  }

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
    uint128 amountOut,
    uint256[] memory conditions,
    uint64[] memory outcomes,
    bool isMultiple
  ) internal returns (uint256 idBet, bool isMultipleBet) {
    uint64 minOdds = 1;
    uint64 expiresAt = uint64(block.timestamp + 1800); // 30 minutes

    if (conditions.length != outcomes.length) {
      revert ArrayLengthsMismatch();
    }
    if (conditions.length == 0) {
      revert EmptyBetArrays();
    }

    if (isMultiple) {
      // Create array of CoreBetData for multiple bets
      ICoreBase.CoreBetData[] memory subBets = new ICoreBase.CoreBetData[](
        conditions.length
      );

      // Fill the array with bet data
      for (uint256 i = 0; i < conditions.length; i++) {
        // Validate unique condition IDs
        for (uint256 j = 0; j < i; j++) {
          if (conditions[i] == conditions[j]) {
            revert DuplicateConditionIds();
          }
        }

        subBets[i] = ICoreBase.CoreBetData({
          conditionId: conditions[i],
          outcomeId: outcomes[i]
        });
      }

      // Encode the CoreBetData array
      bytes memory encodedBetData = abi.encode(subBets);

      // Create the BetData struct
      IBet.BetData memory betData = IBet.BetData({
        affiliate: address(0),
        minOdds: 1,
        data: encodedBetData
      });

      // Place the bet directly without try-catch
      idBet = lp.bet(expressAddress, amountOut, expiresAt, betData);
      isMultipleBet = true;
    } else {
      // Single bet case remains unchanged
      IBet.BetData memory betData = IBet.BetData({
        affiliate: address(0), // affiliate
        minOdds: minOdds,
        data: abi.encode(conditions[0], outcomes[0])
      });
      idBet = lp.bet(address(coreBase), amountOut, expiresAt, betData);
      isMultipleBet = false;
    }
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
    if (basisPoints > BASIS_POINTS) {
      revert InvalidReferralFeePercentage();
    }
    return (amount * basisPoints) / BASIS_POINTS;
  }

  /**
   * @notice Handles protocol fee deduction and approval for Across
   * @param amount Amount to process
   * @return Amount after fee deduction
   */
  function _handleProtocolFee(
    uint256 amount,
    address token,
    bool isBet
  ) internal returns (uint256) {
    uint256 protocolFee = _calculatePercentage(amount, isBet ? protocolFeeBetPercentage : protocolFeeWithdrawPercentage);
    if (protocolFee == 0) {
      return amount;
    }
    IERC20(token).safeTransfer(protocolFeeRecipient, protocolFee);
    uint256 amountAfterFee = amount - protocolFee;
    return amountAfterFee;
  }

  /**
   * @notice Initiates the cross-chain transfer via Across bridge
   * @param amountIn Amount of tokens to send
   * @param amountOut Amount of tokens expected on the destination chain
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   */
  function _sendToAcross(
    uint256 amountIn,
    uint256 amountOut,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer
  ) internal {
    V3SpokePoolInterface(acrossSpokePool).depositV3(
      address(this),
      controller,
      usdcAddress,
      usdcAddressDestination,
      amountIn,
      amountOut, //amount out is calculated as input amount - relayer fees
      destinationChainId,
      exclusivityRelayer,
      quoteTimestamp,
      uint32(block.timestamp + 18000), // 5 hours
      exclusivityDeadline,
      ""
    );
  }

  /**
   * @notice Internal function to process bet withdrawals
   * @dev Handles payout retrieval, swaps, and bridge transfer
   * @param idBet Bet ID to withdraw
   * @param totalFeeAmount Amount to withdraw
   * @param quoteTimestamp Timestamp for exclusivity
   * @param exclusivityDeadline Deadline for exclusivity
   * @param exclusivityRelayer Relayer address
   * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
   */
  function _handleWithdraw(
    uint256 idBet,
    uint256 totalFeeAmount,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw
  ) internal {
    // Step 1: Handle payout based on bet type
    uint256 amountPayout;
    if (isMultipleBet) {
      // Multiple bet case
      if (IERC721(expressAddress).ownerOf(idBet) != address(this)) {
        revert NotSentinel();
      }
      amountPayout = lp.withdrawPayout(expressAddress, idBet);
    } else {
      // Single bet case
      if (IERC721(azuroBet).ownerOf(idBet) != address(this)) {
        revert NotSentinel();
      }
      amountPayout = lp.withdrawPayout(coreBase, idBet);
    }

    if (!onlyWithdraw) {
      // Continue with swap and bridge operations
      IERC20(usdtAddress).forceApprove(address(swapRouter), amountPayout);
      uint256 amountOutAfterSwap = _swap(
        usdtAddress,
        usdcAddress,
        amountPayout
      );

      // Step 2: Handle protocol fee and prepare for Across
      uint256 amountForAcross = _handleProtocolFee(
        amountOutAfterSwap,
        usdcAddress,
        false
      );

      IERC20(usdcAddress).forceApprove(acrossSpokePool, amountForAcross);

      // Check on the amount for across
      if (totalFeeAmount >= amountForAcross) {
        revert InvalidAmountForAcross();
      }
      uint256 amountOut = amountForAcross - totalFeeAmount;
      // Step 3: Call Across
      _sendToAcross(
        amountForAcross,
        amountOut,
        quoteTimestamp,
        exclusivityDeadline,
        exclusivityRelayer
      );
    }
  }

  // ======================== Signature Verification ========================
  function _verifyControllerSignatureBet(
    address tokenIn,
    address tokenOut,
    uint256 amountIn,
    bytes memory bet,
    bytes memory signature,
    bytes32 nonce
  ) internal {
    // Expecting a standard 65-byte signature
    if (signature.length != 65) revert InvalidSignatureLength();

    // Compute the typed hash as before
    bytes32 betHash = keccak256(bet);
    bytes32 structHash = keccak256(
        abi.encode(
            BET_TYPEHASH,
            tokenIn,
            tokenOut,
            amountIn,
            betHash,
            address(this),
            nonce
        )
    );
    bytes32 digest = keccak256(
        abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
    );

    // Recover the signer using ECDSA
    address recoveredSigner = ECDSA.recover(digest, signature);

    // Check if nonce has been used
    if (usedBetNonces[nonce]) revert NonceAlreadyUsed(nonce);
    usedBetNonces[nonce] = true;

    if (recoveredSigner == address(0)) revert InvalidSignature();
    if (recoveredSigner != controller) revert InvalidSigner();
  }

  function _verifyControllerSignatureWithdraw(
    uint256 idBet,
    uint256 amountOut,
    uint32 quoteTimestamp,
    uint32 exclusivityDeadline,
    address exclusivityRelayer,
    bool isMultipleBet,
    bool onlyWithdraw,
    bytes memory signature,
    bytes32 nonce
  ) internal {
    // Expecting a standard 65-byte signature
    if (signature.length != 65) revert InvalidSignatureLength();

    // Check if nonce has been used
    if (usedWithdrawNonces[nonce]) revert NonceAlreadyUsed(nonce);
    usedWithdrawNonces[nonce] = true;

    // Build the struct hash using the type hash and parameters
    bytes32 structHash = keccak256(
      abi.encode(
        WITHDRAW_TYPEHASH,
        idBet,
        amountOut,
        quoteTimestamp,
        exclusivityDeadline,
        exclusivityRelayer,
        isMultipleBet,
        onlyWithdraw,
        address(this),
        nonce
      )
    );

    // Compute the digest per EIP-712: "\x19\x01" || DOMAIN_SEPARATOR || structHash
    bytes32 digest = keccak256(
      abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, structHash)
    );

    // Recover the signer using the ECDSA library
    address recoveredSigner = ECDSA.recover(digest, signature);

    if (recoveredSigner == address(0)) revert InvalidSignature();
    if (recoveredSigner != controller) revert InvalidSigner();
  }

  /**
   * @notice Implementation of IERC721Receiver
   */
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes calldata data
  ) external override returns (bytes4) {
    return this.onERC721Received.selector;
  }
}
