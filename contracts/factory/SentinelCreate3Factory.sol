// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {CREATE3} from "../utils/Create3.sol";

/// @title Factory for deploying contracts to deterministic addresses via CREATE3
/// @notice The reference implementation is from zefram.eth
contract SentinelCreate3Factory {

    error AlreadyDeployed(address controller);
    event SentinelDeployed(address deployed, address controller);

    mapping(address => address) public deployedControllers;

    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function deploy(bytes32 salt, bytes memory creationCode, address controller)
        external
        payable 
        onlyOwner
        returns (address deployed)
    {
        if (deployedControllers[controller] != address(0)) {
            revert AlreadyDeployed(controller);
        }

        // hash salt with the deployer address to give each deployer its own namespace
        salt = keccak256(abi.encodePacked(msg.sender, salt));

        deployed = CREATE3.deploy(salt, creationCode, msg.value);
        deployedControllers[controller] = deployed;

        //TODO:Initialize the contract -> creationCode

        emit SentinelDeployed(deployed, controller);

        return deployed;
    }

    function getDeployed(address deployer, bytes32 salt)
        external
        view
        returns (address deployed)

    {
        // hash salt with the deployer address to give each deployer its own namespace
        salt = keccak256(abi.encodePacked(deployer, salt));
        return CREATE3.getDeployed(salt);
    }

    function setOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

}