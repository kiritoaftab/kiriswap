// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Exchange} from "../src/Exchange.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockToken is ERC20 {
    constructor() ERC20("MockToken","MTK"){
        _mint(msg.sender,100000 ether);
    }
}

contract ExchangeTest is Test {

    Exchange public exchange;
    MockToken public token;
    address public alice;
    address public deployer;

    function setUp() public{
        alice = address(0xA11CE);
        deployer = address(0xAF177);
        vm.deal(alice,10000 ether);
        vm.deal(deployer,20000 ether);

        token = new MockToken();
        exchange = new Exchange(address(token));
        token.transfer(alice, 2000 ether);
        token.transfer(deployer, 5000 ether);
        vm.prank(alice);
        token.approve(address(exchange), 2000 ether);
        vm.prank(deployer);
        token.approve(address(exchange), 5000 ether);
    }

    function test_AddLiquidity() public {
        vm.prank(alice);

        exchange.addLiquidity{value : 100 ether}(200 ether);

        assertEq(address(exchange).balance, 100 ether);
        assertEq(exchange.getReserve(), 200 ether);
    }

    function test_getPrice() public {
        vm.prank(alice);
        exchange.addLiquidity{value: 1000 ether}(2000 ether);

        uint256 tokenReserve = exchange.getReserve();
        uint256 etherReserve = address(exchange).balance;

        assertEq(exchange.getPrice(etherReserve,tokenReserve), 500);
        assertEq(exchange.getPrice(tokenReserve,etherReserve), 2000);
    }

    function test_GetTokenAmount() public {
        vm.prank(alice);
        exchange.addLiquidity{ value: 1000 ether }(2000 ether);

        uint256 tokensOut = exchange.getTokenAmount(1 ether);

        assertApproxEqAbs(tokensOut, 1.998001998001998001 ether, 1e12);
    }

    function test_GetEthAmount() public {
        vm.prank(alice);
        exchange.addLiquidity{ value: 1000 ether }(2000 ether);

        uint256 ethOut = exchange.getEthAmount(2 ether);

        assertApproxEqAbs(ethOut, 0.999000999000999 ether, 1e12);
    }

    function test_SlippageTokenAmount() public {
        vm.prank(alice);
        exchange.addLiquidity{ value: 1000 ether }(2000 ether); 

        uint256 tokensOut = exchange.getTokenAmount(1 ether);
        assertApproxEqAbs(tokensOut, 1.998001998001998001 ether, 1e12);

        tokensOut = exchange.getTokenAmount(100 ether);
        assertApproxEqAbs(tokensOut, 181.818181818181818181 ether, 1e12);

        tokensOut = exchange.getTokenAmount(1000 ether);
        assertApproxEqAbs(tokensOut, 1000 ether,1e12);
    }

    function test_SlippageEthAmount() public {
        vm.prank(alice);
        exchange.addLiquidity{ value: 1000 ether }(2000 ether);

        uint256 ethOut = exchange.getEthAmount(2 ether);
        assertApproxEqAbs(ethOut, 0.999000999000999 ether, 1e12);

        ethOut = exchange.getEthAmount(100 ether);
        assertApproxEqAbs(ethOut, 47.619047619047619047 ether, 1e12);

        ethOut = exchange.getEthAmount(2000 ether);
        assertApproxEqAbs(ethOut,500 ether,1e12);
    }

    function test_AddLiquidity_LPtokens() public {
        vm.prank(alice);
        uint256 liquidityRecieved = exchange.addLiquidity{ value: 100 ether }(200 ether); // 100 ETH --> 200 MTK , ratio set as 0.5 || 1 ETH --> 2 MTK 
        assertEq(liquidityRecieved, 100 ether);  // test if recieves 100 ether 
        
        uint256 aliceLPBalance = exchange.balanceOf(alice);
        assertEq(aliceLPBalance,100 ether);

    }

    function test_EthToTokenSwap_ShouldTransferTokens() public {
        vm.prank(deployer);
        exchange.addLiquidity{value: 100 ether}(200 ether);

        uint256 minTokens = 18 ether;
        uint256 tokenBalanceBefore = token.balanceOf(alice);

        vm.prank(alice);
        exchange.ethToTokenSwap{ value: 10 ether }(minTokens); // Swapping 10 ethers for atleast 18 MTK

        uint256 tokenBalanceAfter = token.balanceOf(alice);
        uint256 tokensReceived = tokenBalanceAfter - tokenBalanceBefore;

        assertGe(tokensReceived, 18 ether);
    }

    function test_TokenToEthSwap_ShouldTransferTokens() public {
        vm.prank(deployer);
        exchange.addLiquidity{value: 100 ether}(200 ether); // setting ratio as 0.5 ==> 1ETH --> 2 MTK

        uint256 minEth = 4 ether;
        uint256 ethBalanceBefore = address(alice).balance;

        vm.prank(alice);
        exchange.tokenToEthSwap(10 ether,minEth); // Swapping 10 MTK for atleast 4 ETH

        uint256 ethBalanceAfter = address(alice).balance;
        uint256 ethRecieved = ethBalanceAfter - ethBalanceBefore;

        assertGe(ethRecieved, minEth);
    }

    function test_RemoveLiquidity() public {
        vm.prank(deployer); 
        exchange.addLiquidity{value: 100 ether}(200 ether); // setting ratio as 0.5 , gives 100 ETH, 200 MTK , gets 100 LP-tokens

        vm.prank(alice);
        exchange.ethToTokenSwap{value:10 ether}(18 ether); // performing swap for alice, by giving 10 ETH for atleast 18 MTK 

        vm.prank(deployer);

        uint256 ethRecieved;
        uint256 tokenReceived;
        (ethRecieved, tokenReceived) = exchange.removeLiquidity(100 ether); // burn 100 LP token in return for liquidity provided --> (ETH, MTK)
        console.log(ethRecieved,tokenReceived); // gets 109.9 ETH, 181.98 MTK, in short made a profit

    }

}
