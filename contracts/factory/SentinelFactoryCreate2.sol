// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/// @title Factory for deploying contracts to deterministic addresses via CREATE2
/// @notice The reference implementation is from zefram.eth
/// @dev This contract deploys and initializes Sentinel contracts at deterministic addresses
contract SentinelFactoryCreate2 {
  // Custom errors and events
  error AlreadyDeployed(address controller);
  event SentinelDeployed(address deployed, address controller);

  // State variables
  /// @notice Maps user addresses to their deployed controller addresses
  mapping(address => address) public deployedControllers;

  /// @notice Owner address with administrative privileges
  address public owner;

  /// @notice Bytecode of the contract to be deployed
  bytes public contractCode;

  /// @param _owner Address that will have administrative rights
  /// @param _contractCode Bytecode of the contract to be deployed
  constructor(address _owner, bytes memory _contractCode) {
    owner = _owner;
    contractCode = _contractCode;
  }

  /// @notice Restricts function access to contract owner
  modifier onlyOwner() {
    require(msg.sender == owner, "Only owner can call this function");
    _;
  }

  /// @notice Deploys and initializes a new Sentinel contract
  /// @param user Address of the user who will control the deployed contract
  /// @param initContractCore Parameters for core initialization
  /// @param initContractProtocol Parameters for protocol initialization
  /// @return Address of the deployed contract
  function deploy(
    address user,
    bytes memory initContractCore,
    bytes memory initContractProtocol
  ) external payable onlyOwner returns (address) {
    // Check if user already has a deployed controller
    if (deployedControllers[user] != address(0)) {
      revert AlreadyDeployed(user);
    }

    // Generate deterministic salt based on user address
    bytes32 _salt = getWalletNonce(user);

    // Deploy contract using CREATE2
    bytes memory bytecode = contractCode;
    address deployed;
    assembly {
      deployed := create2(0, add(bytecode, 0x20), mload(bytecode), _salt)
      if iszero(extcodesize(deployed)) {
        revert(0, 0)
      }
    }

    // Record the deployment
    deployedControllers[user] = deployed;

    // Initialize the contract core - using bytes directly as calldata
    (bool success, ) = deployed.call(initContractCore);
    require(success, "Failed to initialize contract core");

    // Initialize the contract protocol - using bytes directly as calldata
    (bool success2, ) = deployed.call(initContractProtocol);
    require(success2, "Failed to initialize contract protocol");

    emit SentinelDeployed(deployed, user);
    return deployed;
  }

  /// @notice Generates a unique salt for CREATE2 deployment
  /// @param user Address to generate the nonce for
  /// @return Unique hash combining user address and "nonce"
  function getWalletNonce(address user) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(user, "nonce"));
  }

  /// @notice Updates the owner address
  /// @param _owner New owner address
  function setOwner(address _owner) external onlyOwner {
    owner = _owner;
  }

  /// @notice Updates the contract bytecode
  /// @param _contractCode New contract bytecode
  function setContractCode(bytes memory _contractCode) external onlyOwner {
    contractCode = _contractCode;
  }
}
