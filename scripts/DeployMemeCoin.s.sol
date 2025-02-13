// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ContractFactory} from "../contracts/ContractFactory.sol";
import "forge-std/console.sol";
contract DeployMemeCoin is Script {
    function run(string memory name, string memory symbol, string memory metadata, uint256 initialPrice) external {
        vm.rpcUrl("https://base-sepolia.infura.io/v3/e11fea93e1e24107aa26935258904434");
        vm.startBroadcast();
        address factoryAddress = address(0x6fa62a5Df040e1Cc8C9F5A83Dc001cba6Eaed23e);
        bytes32 salt = keccak256(abi.encodePacked("MemeCoinv6"));
        ContractFactory factory = ContractFactory(factoryAddress);
        address addr = factory.createSimpleContract(name, symbol, metadata,initialPrice, salt);
        console.log("Contract deployed at:", addr);
        vm.stopBroadcast();
    }
}
