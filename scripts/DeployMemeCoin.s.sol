// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ContractFactory} from "../contracts/ContractFactory.sol";
import "forge-std/console.sol";
contract DeployMemeCoin is Script {
    function run(string memory name, string memory symbol, string memory metadata, uint256 initialPrice) external {
        vm.rpcUrl("https://base-sepolia.infura.io/v3/e11fea93e1e24107aa26935258904434");
        vm.startBroadcast();
        address factoryAddress = address(0xf3DB161c2Af54157772e734fb17f6bC1217D36A5);
        address ownerAddress = address(0xCD86599DedD1A8E9d87dcEC37Dc8bE479e78cc30);
        bytes32 salt = keccak256(abi.encodePacked("MemeCoinv7"));
        ContractFactory factory = ContractFactory(factoryAddress);
        address addr = factory.createMemeContract(name, symbol, metadata, initialPrice, ownerAddress, salt);
        console.log("Contract deployed at:", addr);
        vm.stopBroadcast();
    }
}
