// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../src/ZuniswapV2Library.sol";
import "../src/ZuniswapV2Factory.sol";
import "../src/ZuniswapV2Pair.sol";
import "./mocks/ERC20Mintable.sol";

contract ZuniswapV2LibraryTest is Test {
    ZuniswapV2Factory factory;

    ERC20Mintable tokenA;
    ERC20Mintable tokenB;

    ZuniswapV2Pair pair;

    function encodeError(string memory error)
        internal
        pure
        returns (bytes memory encoded)
    {
        encoded = abi.encodeWithSignature(error);
    }

    function setUp() public {
        factory = new ZuniswapV2Factory();

        tokenA = new ERC20Mintable("TokenA", "TKNA");
        tokenB = new ERC20Mintable("TokenB", "TKNB");

        tokenA.mint(10 ether, address(this));
        tokenB.mint(10 ether, address(this));

        address pairAddress = factory.createPair(
            address(tokenA),
            address(tokenB)
        );
        pair = ZuniswapV2Pair(pairAddress);
    }

    function testGetReserves() public {
        tokenA.transfer(address(pair), 1.1 ether);
        tokenB.transfer(address(pair), 0.8 ether);

        ZuniswapV2Pair(address(pair)).mint(address(this));

        (uint256 reserve0, uint256 reserve1) = ZuniswapV2Library.getReserves(
            address(factory),
            address(tokenA),
            address(tokenB)
        );

        assertEq(reserve0, 1.1 ether);
        assertEq(reserve1, 0.8 ether);
    }

    function testQuote() public {
        uint256 amountOut = ZuniswapV2Library.quote(1 ether, 1 ether, 1 ether);
        assertEq(amountOut, 1 ether);

        amountOut = ZuniswapV2Library.quote(1 ether, 2 ether, 1 ether);
        assertEq(amountOut, 0.5 ether);

        amountOut = ZuniswapV2Library.quote(1 ether, 1 ether, 2 ether);
        assertEq(amountOut, 2 ether);
    }

    function testPairFor() public {
        address pairAddress = ZuniswapV2Library.pairFor(
            address(factory),
            address(tokenA),
            address(tokenB)
        );

        assertEq(pairAddress, factory.pairs(address(tokenA), address(tokenB)));
    }

    function testPairForTokensSorting() public {
        address pairAddress = ZuniswapV2Library.pairFor(
            address(factory),
            address(tokenB),
            address(tokenA)
        );

        assertEq(pairAddress, factory.pairs(address(tokenA), address(tokenB)));
    }

    function testPairForNonexistentFactory() public {
        address pairAddress = ZuniswapV2Library.pairFor(
            address(0xaabbcc),
            address(tokenB),
            address(tokenA)
        );

        assertEq(pairAddress, 0x8BbD00dFF82468090E7D720E9fB3a6529C73Ff9e);
    }

    function testGetAmountOut() public {
        uint256 amountOut = ZuniswapV2Library.getAmountOut(
            1000,
            1 ether,
            1.5 ether
        );
        assertEq(amountOut, 1495);
    }

    function testGetAmountOutZeroInputAmount() public {
        vm.expectRevert(encodeError("InsufficientAmount()"));
        ZuniswapV2Library.getAmountOut(0, 1 ether, 1.5 ether);
    }

    function testGetAmountOutZeroInputReserve() public {
        vm.expectRevert(encodeError("InsufficientLiquidity()"));
        ZuniswapV2Library.getAmountOut(1000, 0, 1.5 ether);
    }

    function testGetAmountOutZeroOutputReserve() public {
        vm.expectRevert(encodeError("InsufficientLiquidity()"));
        ZuniswapV2Library.getAmountOut(1000, 1 ether, 0);
    }
}
