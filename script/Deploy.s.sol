// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/Factory.sol";
import "../src/Token.sol";

contract Deploy is Script {
    function run() external {
        vm.startBroadcast();

        // Deploy two mock tokens
        Token tokenA = new Token("Marhaba Token", "MTK",1000 ether); // sends 1000 MTK , 1000 KIRT to first address of foundry, during deployment
        Token tokenB = new Token("Kirito Token", "KIRT", 1000 ether);

        // Deploy the Factory
        Factory factory = new Factory();

        // (optional) create Exchange for tokenA
        address exchangeA = factory.createExchange(address(tokenA));

        vm.stopBroadcast();
    }
}
