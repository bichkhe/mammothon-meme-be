// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MemeCoin} from "../contracts/MemeContract.sol";
import "forge-std/console.sol";
contract InteractMeme is Script {
    function run() external {
        vm.rpcUrl("https://base-sepolia.infura.io/v3/e11fea93e1e24107aa26935258904434");
        vm.startBroadcast();
        address factoryAddress = address(0xD295179D0265a0170af78565b7EDE98CA5678F0B);
        MemeCoin meme = MemeCoin(payable(factoryAddress));
        uint256 cost = 0.001 ether;
        meme.buy{value:cost}();
        // uint256 balance = meme.getContractBalance();
        // console.log("Balance of this contract:", balance);
        // uint256 w = cost * 1 ether;
        // console.log("Cost:", w);
        // uint256 coin = meme.getCurrentPrice();
        // console.log("curent price:", coin);
        // uint256 balance = meme.balanceOf(address(0xCD86599DedD1A8E9d87dcEC37Dc8bE479e78cc30));
        // console.log("Address:", address(0xCD86599DedD1A8E9d87dcEC37Dc8bE479e78cc30));
        // console.log("Balance of this contract:", balance);
        //meme.sell(140000000);
        vm.stopBroadcast();
    }
}