// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MemeCoin} from "./MemeContract.sol";
import "forge-std/console.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract ContractFactory is Ownable {
    address[] public deployedContracts;
    bool public isActive = true;

    event ContractCreated(address contractAddress, address owner, bytes32 salt);
    event FactoryDisabled(address by);

    error DeploymentFailed(string reason);

    constructor(address initialOwner) Ownable(initialOwner) {
    }
    function createSimpleContract(
        string memory name,
        string memory symbol,
        string memory metadata,
        uint256 initialPrice,
        bytes32 _salt
    ) external onlyOwner() returns (address) {
        bytes memory bytecode = type(MemeCoin).creationCode;
        bytes memory initCode = abi.encodePacked(
            bytecode,
            abi.encode(name, symbol, metadata, initialPrice)
        );

        address contractAddress;
        assembly {
            contractAddress := create2(
                0,
                add(initCode, 0x20),
                mload(initCode),
                _salt
            )
        }

        if (contractAddress == address(0)) {
            revert DeploymentFailed("Contract deployment failed: create2 returned address(0)");
        }

        deployedContracts.push(contractAddress);
        emit ContractCreated(contractAddress, msg.sender, _salt);

        // ✅ Correct usage of `console.log()`
        console.log("Contract deployed at:", contractAddress);

        return contractAddress;
    }
    function getDeployedContracts() external view returns (address[] memory) {
        return deployedContracts;
    }
}
