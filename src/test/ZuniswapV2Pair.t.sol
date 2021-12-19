// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../ZuniswapV2Pair.sol";
import "../mocks/ERC20Mintable.sol";

contract ZuniswapV2PairTest is DSTest {
    ERC20Mintable token0;
    ERC20Mintable token1;
    ZuniswapV2Pair pair;

    function setUp() public {
        token0 = new ERC20Mintable("Token A", "TKNA");
        token1 = new ERC20Mintable("Token B", "TKNB");
        pair = new ZuniswapV2Pair(address(token0), address(token1));

        token0.mint(10 ether);
        token1.mint(10 ether);
    }

    function testMintBootstrap() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();

        assertEq(pair.balanceOf(address(this)), 999999999999999000);
        assertEq(pair.reserve0(), 1 ether);
        assertEq(pair.reserve1(), 1 ether);
        assertEq(pair.totalSupply(), 1 ether);
    }

    function testMintWhenTheresLiquidity() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();

        token0.transfer(address(pair), 0.5 ether);
        token1.transfer(address(pair), 0.5 ether);

        uint256 balanceBefore = pair.balanceOf(address(this));

        pair.mint();

        uint256 balanceAfter = pair.balanceOf(address(this));
        uint256 balanceDiff = balanceAfter - balanceBefore;

        assertEq(balanceDiff, 500000000000000000);
        assertEq(pair.reserve0(), 1.5 ether);
        assertEq(pair.reserve1(), 1.5 ether);
        assertEq(pair.totalSupply(), 1500000000000000000);
    }
}
