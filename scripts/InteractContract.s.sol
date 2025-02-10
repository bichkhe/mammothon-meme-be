// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MemeCoin} from "../contracts/MemeContract.sol";
import "forge-std/console.sol";
contract InteractMeme is Script {
    function run() external {
        vm.rpcUrl("https://base-sepolia.infura.io/v3/e11fea93e1e24107aa26935258904434");
        vm.startBroadcast();
        address factoryAddress = address(0x4306d58cd98B40A61481932DA4cA9c9b68462e4D);
        MemeCoin meme = MemeCoin(payable(factoryAddress));
        uint256 balance = meme.balanceOf(address(this));
        console.log("Balance of this contract:", balance);
        vm.stopBroadcast();
    }
}