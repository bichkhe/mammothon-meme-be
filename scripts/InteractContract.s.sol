// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MemeCoin} from "../contracts/MemeContract.sol";
import "forge-std/console.sol";
contract InteractMeme is Script {
    function run() external {
        vm.rpcUrl("https://base-sepolia.infura.io/v3/e11fea93e1e24107aa26935258904434");
        vm.startBroadcast();
        address factoryAddress = address(0x30DcD8DEf4CC1cCd5EA88AF4B56c4c2dB47bd36D);
        MemeCoin meme = MemeCoin(factoryAddress);
        uint256 coinGet = meme.calculateToken(1);
        console.log("Coin get:", coinGet);  
        vm.stopBroadcast();
    }
}