// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {ContractFactory} from "../contracts/ContractFactory.sol";
contract CounterScript is Script {
    function run() external {
        vm.startBroadcast();
        bytes memory bytecode = type(ContractFactory).creationCode;
        bytes memory initCode = abi.encodePacked(
            bytecode,
            abi.encode(msg.sender)
        );
        bytes32 salt = keccak256(abi.encodePacked("FactoryV7"));
        address contractAddress;

        assembly {
            contractAddress := create2(
                0,
                add(initCode, 0x20),
                mload(initCode),
                salt
            )
            if iszero(contractAddress) {
                revert(0, 0)
            }
        }
        // Log the deployed contract address
        console.log("Factory Contract deployed at:", contractAddress);
        vm.stopBroadcast();
    }
}
