// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//TODO: multiple bet, native token support (worldcoin)

// ======================== Imports ========================
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "./azuro-protocol/ILP.sol";
import "./utils/V3SpokePoolInterface.sol";
import "./utils/IQuoter.sol";
import "./azuro-protocol/IAzuroBet.sol";
import "./azuro-protocol/IBet.sol";
import "hardhat/console.sol";

// ======================== Contract Definition ========================
/**
 * @title Sentinel
 * @notice This contract handles cross-chain sports betting operations using Azuro Protocol and Across Bridge
 * @dev Acts as a destination chain contract that receives bets and processes withdrawals
 */
contract Sentinel is ReentrancyGuard, Pausable {
    using SafeERC20 for IERC20;

    // ======================== Events ========================
    event BetPlaced(uint256 indexed idBet);
    event WithdrawBet(uint256 indexed idBet);
    event OperatorChanged(address indexed oldOperator, address indexed newOperator);
    event ProtocolFeeRecipientChanged(address indexed oldRecipient, address indexed newRecipient);
    event ProtocolFeePercentageChanged(uint256 oldFee, uint256 newFee);
    event ReferralFeePercentageChanged(uint256 oldFee, uint256 newFee);
    event CoreBaseChanged(address indexed oldCoreBase, address indexed newCoreBase);
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
    error NotControllerOrOperator(address controller);
    error InvalidControllerAddress();
    error InvalidAmountOutMin();
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

    // ======================== Constants ========================
    uint256 private constant BASIS_POINTS = 10000; // 100% (100 * 100 = 10000)
    uint256 private constant USDC_DECIMALS = 6; // 1 USDC = 10^6 USDC

    // ======================== State Variables ========================
    // Access Control
    address public operator; // Operator address for privileged operations
    address public controller; // Controller address for privileged operations

    // Protocol Configuration
    address public protocolFeeRecipient; // Address receiving protocol fees
    uint256 public protocolFeePercentage; // Fee percentage in basis points
    uint256 public referralFeePercentage; // Referral fee percentage in basis points
    uint256 public destinationChainId; // Target chain ID for cross-chain operations

    // Protocol Addresses
    address public acrossGenericHandler; // Across bridge handler address
    address public acrossSpokePool; // Across spoke pool address
    address public coreBase; // Azuro core contract address
    address public quoter; // Uniswap quoter address
    address public usdcAddress; // USDC token address
    address public usdtAddress; // USDT token address
    uint24 public poolFee; // Uniswap pool fee

    // Protocol Interfaces
    ISwapRouter public swapRouter; // Uniswap router interface
    ILP public lp; // Azuro liquidity pool interface
    IAzuroBet public azuroBet; // Azuro bet interface

    bool public initialized; // Initialization status
    bool public protocolInitialized; // Protocol initialization status

    // ======================== Modifiers ========================

    /**
     * @notice Ensures caller is either owner or operator
     */
    modifier onlyControllerOrOperator() {
        if (msg.sender != controller && msg.sender != operator) {
            revert NotControllerOrOperator(msg.sender);
        }
        _;
    }

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
     * @notice Ensures contract is not paused
     */
    modifier whenNotPausedOverride() {
        if (paused()) {
            revert PausedState();
        }
        _;
    }

    // ======================== Constructor ========================
    /**
     * @notice Contract constructor
     * @param _owner Contract owner address
     * @param _operator Contract operator address
     * @param _swapRouter Uniswap V3 SwapRouter address
     * @param _lp Azuro liquidity pool address
     * @param _azuroBet Azuro bet contract address
     * @param _usdcAddress USDC token address
     * @param _usdtAddress USDT token address
     */
    constructor(
        address _owner,
        address _operator,
        ISwapRouter _swapRouter,
        ILP _lp,
        address _azuroBet,
        address _usdcAddress,
        address _usdtAddress
    ) {
        _initializeCore(
            _owner,
            _operator,
            _swapRouter,
            _lp,
            _azuroBet,
            _usdcAddress,
            _usdtAddress
        );
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
        address _usdtAddress
    ) external onlyOperator {
        _initializeCore(
            _owner,
            _operator,
            _swapRouter,
            _lp,
            _azuroBet,
            _usdcAddress,
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
        uint256 _protocolFeePercentage,
        uint256 _referralFeePercentage,
        address _coreBase,
        address _quoter,
        uint24 _poolFee,
        uint256 _destinationChainId
    ) external onlyOperator {
        _initializeProtocol(
            _acrossGenericHandler,
            _acrossSpokePool,
            _protocolFeeRecipient,
            _protocolFeePercentage,
            _referralFeePercentage,
            _coreBase,
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
        if (_usdtAddress == address(0)) revert InvalidUSDTAddress();

        operator = _operator;
        controller = _controller;
        swapRouter = _swapRouter;
        lp = _lp;
        azuroBet = IAzuroBet(_azuroBet);
        usdcAddress = _usdcAddress;
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
        uint256 _protocolFeePercentage,
        uint256 _referralFeePercentage,
        address _coreBase,
        address _quoter,
        uint24 _poolFee,
        uint256 _destinationChainId
    ) private {
        if (protocolInitialized) {
            revert AlreadyProtocolInitialized();
        }
        if (_protocolFeePercentage == 0) revert InvalidProtocolFeePercentage();

        if (_acrossGenericHandler == address(0))
            revert InvalidAcrossHandlerAddress();
        if (_acrossSpokePool == address(0)) revert InvalidAcrossSpokePoolAddress();
        if (_protocolFeeRecipient == address(0))
            revert InvalidProtocolFeeRecipientAddress();
        if (_referralFeePercentage == 0) revert InvalidReferralFeePercentage();
        if (_coreBase == address(0)) revert InvalidCoreBaseAddress();
        if (_quoter == address(0)) revert InvalidQuoterAddress();
        if (_poolFee == 0) revert InvalidPoolFee();
        if (_destinationChainId == 0) revert InvalidDestinationChainId();

        acrossGenericHandler = _acrossGenericHandler;
        acrossSpokePool = _acrossSpokePool;
        protocolFeeRecipient = _protocolFeeRecipient;
        protocolFeePercentage = _protocolFeePercentage;
        referralFeePercentage = _referralFeePercentage;
        coreBase = _coreBase;
        quoter = _quoter;
        poolFee = _poolFee;
        destinationChainId = _destinationChainId;
        protocolInitialized = true;

        emit ProtocolInitialized();
    }

    // ======================== Setter Functions ========================

    /**
     * @notice Sets a new operator address
     * @dev Only callable by the current operator
     * @param _operator New operator address
     */
    function setOperator(address _operator) external onlyController whenNotPausedOverride {
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
    function setProtocolFeeRecipient(address _protocolFeeRecipient) external onlyController whenNotPausedOverride {
        if (_protocolFeeRecipient == address(0)) revert InvalidProtocolFeeRecipientAddress();
        address oldRecipient = protocolFeeRecipient;
        protocolFeeRecipient = _protocolFeeRecipient;
        emit ProtocolFeeRecipientChanged(oldRecipient, _protocolFeeRecipient);
    }

    /**
     * @notice Sets the protocol fee percentage
     * @dev Only callable by the operator
     * @param _protocolFeePercentage New fee percentage in basis points (max 1000 = 10%)
     */
    function setProtocolFeePercentage(uint256 _protocolFeePercentage) external onlyController whenNotPausedOverride {
        if (_protocolFeePercentage == 0) revert InvalidProtocolFeePercentage();
        uint256 oldFee = protocolFeePercentage;
        protocolFeePercentage = _protocolFeePercentage;
        emit ProtocolFeePercentageChanged(oldFee, _protocolFeePercentage);
    }

    /**
     * @notice Sets the referral fee percentage
     * @dev Only callable by the operator
     * @param _referralFeePercentage New fee percentage in basis points (max 1000 = 10%)
     */
    function setReferralFeePercentage(uint256 _referralFeePercentage) external onlyController whenNotPausedOverride {
        if (_referralFeePercentage > 1000) revert InvalidReferralFeePercentage();
        uint256 oldFee = referralFeePercentage;
        referralFeePercentage = _referralFeePercentage;
        emit ReferralFeePercentageChanged(oldFee, _referralFeePercentage);
    }

    /**
     * @notice Updates the CoreBase address
     * @dev Only callable by the operator
     * @param _coreBase New CoreBase address
     */
    function setCoreBase(address _coreBase) external onlyController whenNotPausedOverride {
        if (_coreBase == address(0)) revert InvalidCoreBaseAddress();
        address oldCoreBase = coreBase;
        coreBase = _coreBase;
        emit CoreBaseChanged(oldCoreBase, _coreBase);
    }

    /**
     * @notice Updates the Quoter address
     * @dev Only callable by the operator
     * @param _quoter New Quoter address
     */
    function setQuoter(address _quoter) external onlyController whenNotPausedOverride {
        if (_quoter == address(0)) revert InvalidQuoterAddress();
        address oldQuoter = quoter;
        quoter = _quoter;
        emit QuoterChanged(oldQuoter, _quoter);
    }

    /**
     * @notice Updates the Uniswap pool fee
     * @dev Only callable by the operator
     * @param _poolFee New pool fee
     */
    function setPoolFee(uint24 _poolFee) external onlyController whenNotPausedOverride {
        if (_poolFee == 0) revert InvalidPoolFee();
        uint24 oldFee = poolFee;
        poolFee = _poolFee;
        emit PoolFeeChanged(oldFee, _poolFee);
    }

    /**
     * @notice Updates the destination chain ID
     * @dev Only callable by the operator
     * @param _destinationChainId New destination chain ID
     */
    function setDestinationChainId(uint256 _destinationChainId) external onlyController whenNotPausedOverride {
        if (_destinationChainId == 0) revert InvalidDestinationChainId();
        uint256 oldChainId = destinationChainId;
        destinationChainId = _destinationChainId;
        emit DestinationChainIdChanged(oldChainId, _destinationChainId);
    }

    // ======================== Core Functions ========================

    /**
     * @notice Handles incoming bets from the source chain
     * @dev Only callable by the Across handler
     * @param tokenIn Source token address
     * @param tokenOut Destination token address
     * @param amountIn Amount of tokens being sent
     * @param bet Encoded bet data (condition, outcome, referrer)
     */
    function handleBet(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        bytes memory bet
    ) external nonReentrant whenNotPausedOverride {
        if (msg.sender != acrossGenericHandler) {
            revert NotAcrossHandler(acrossGenericHandler);
        }
        if (tokenIn == address(0) || tokenOut == address(0)) {
            revert InvalidTokenAddress();
        }
        if (amountIn == 0) {
            revert InvalidAmount();
        }

        IERC20(tokenIn).safeTransferFrom(
            acrossGenericHandler,
            address(this),
            amountIn
        );
        

        uint256 protocolFee = _calculatePercentage(amountIn, protocolFeePercentage);
        IERC20(tokenIn).safeTransfer(protocolFeeRecipient, protocolFee);

        uint256 amountInAfterProtocolFee = amountIn - protocolFee;

        // Decode bet data
        (uint256 condition, uint64 outcome, address referrer) = abi.decode(
            bet,
            (uint256, uint64, address)
        );
        
        uint256 referralFees = 0;

        if (referrer != address(0)) {
            referralFees = _calculatePercentage(
                amountInAfterProtocolFee,
                referralFeePercentage
            );
            IERC20(tokenIn).safeTransfer(referrer, referralFees);
        }
          
        uint256 amountInAfterReferralFees = amountInAfterProtocolFee - referralFees;

        // Approve swapRouter to spend tokens
        IERC20(tokenIn).forceApprove(address(swapRouter), amountInAfterReferralFees);

        uint256 amountOut = _swap(tokenIn, tokenOut, amountInAfterReferralFees);

        // Approve LP to spend swapped tokens
        IERC20(tokenOut).forceApprove(address(lp), amountOut);

        // Place a bet for the player
        uint256 idBet = _bet(uint128(amountOut), condition, outcome);
        console.log(idBet, "idBet");
        emit BetPlaced(idBet);
    }

    /**
     * @notice Processes bet withdrawals and sends funds back across the bridge
     * @dev Only callable by the owner or operator
     * @param idBet Bet ID to withdraw
     * @param amountOut Amount to withdraw
     * @param quoteTimestamp Timestamp for exclusivity
     * @param exclusivityDeadline Deadline for exclusivity
     * @param exclusivityRelayer Relayer address
     * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
     */
    function handleWithdraw(
        uint256 idBet,
        uint256 amountOut,
        uint32 quoteTimestamp,
        uint32 exclusivityDeadline,
        address exclusivityRelayer,
        bool onlyWithdraw
    ) external onlyControllerOrOperator nonReentrant whenNotPausedOverride {
        _handleWithdraw(
            idBet,
            amountOut,
            quoteTimestamp,
            exclusivityDeadline,
            exclusivityRelayer,
            onlyWithdraw
        );
        emit WithdrawBet(idBet);
    }

    // ======================== Emergency Functions ========================

    /**
     * @notice Allows owner or operator to withdraw tokens to owner's wallet
     * @dev Only callable by the owner or operator
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
     * @param condition Bet condition
     * @param outcome Bet outcome
     * @return idBet ID of the placed bet
     */
    function _bet(
        uint128 amountOut,
        uint256 condition,
        uint64 outcome
    ) internal returns (uint256 idBet) {
        // Build the bet object
        uint64 minOdds = 1;
        IBet.BetData memory betData = IBet.BetData(
            address(0), // affiliate
            minOdds,
            abi.encode(condition, outcome) 
        );
        uint64 expiresAt = uint64(block.timestamp + 1800); // 30 minutes
        idBet = lp.bet(address(coreBase), amountOut, expiresAt, betData);
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
        if (basisPoints == 0) {
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
    function _handleProtocolFee(uint256 amount) internal returns (uint256) {
        uint256 protocolFee = _calculatePercentage(amount, protocolFeePercentage);
        IERC20(usdcAddress).safeTransfer(protocolFeeRecipient, protocolFee);
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
            usdtAddress,
            amountIn,
            amountOut,
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
     * @param amountOut Amount to withdraw
     * @param quoteTimestamp Timestamp for exclusivity
     * @param exclusivityDeadline Deadline for exclusivity
     * @param exclusivityRelayer Relayer address
     * @param onlyWithdraw If true, only withdraws from Azuro without swapping or bridging
     */
    function _handleWithdraw(
        uint256 idBet,
        uint256 amountOut,
        uint32 quoteTimestamp,
        uint32 exclusivityDeadline,
        address exclusivityRelayer,
        bool onlyWithdraw
    ) internal {
        // Check owner of the bet
        address betOwner = IAzuroBet(address(azuroBet)).ownerOf(idBet);
        if (betOwner != controller) {
            revert NotController(betOwner);
        }

        // Step 1: Handle payout
        uint256 amountPayout = lp.withdrawPayout(address(coreBase), idBet);

        if (!onlyWithdraw) {
            // Continue with swap and bridge operations
            IERC20(usdtAddress).forceApprove(address(swapRouter), amountPayout);
            uint256 amountOutAfterSwap = _swap(
                usdtAddress,
                usdcAddress,
                amountPayout
            );

            // Step 2: Handle protocol fee and prepare for Across
            uint256 amountForAcross = _handleProtocolFee(amountOutAfterSwap);

            IERC20(usdcAddress).forceApprove(acrossSpokePool, amountForAcross);

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
}
