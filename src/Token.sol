// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20{
    constructor(string memory name,string memory symbol,uint256 initialSupply) ERC20(name,symbol) {
        _mint(msg.sender,initialSupply);
    }
}

