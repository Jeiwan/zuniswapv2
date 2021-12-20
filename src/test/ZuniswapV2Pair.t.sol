// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "ds-test/test.sol";
import "../ZuniswapV2Pair.sol";
import "../mocks/ERC20Mintable.sol";

interface Vm {
    function expectRevert(bytes calldata) external;

    function prank(address) external;

    function load(address c, bytes32 loc) external returns (bytes32);
}

contract ZuniswapV2PairTest is DSTest {
    Vm vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

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

    function _assertReserves(
        ZuniswapV2Pair _pair,
        uint112 expectedReserve0,
        uint112 expectedReserve1
    ) internal {
        (uint112 reserve0, uint112 reserve1, ) = _pair.getReserves();
        assertEq(reserve0, expectedReserve0, "reserve0 doesn't match");
        assertEq(reserve1, expectedReserve1, "reserve1 doesn't match");
    }

    function testMintBootstrap() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();

        assertEq(pair.balanceOf(address(this)), 999999999999999000);
        _assertReserves(pair, 1 ether, 1 ether);
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
        _assertReserves(pair, 1.5 ether, 1.5 ether);
        assertEq(pair.totalSupply(), 1500000000000000000);
    }

    function testMintLiquidityUnderflow() public {
        // 0x11: If an arithmetic operation results in underflow or overflow outside of an unchecked { ... } block.
        vm.expectRevert(
            hex"4e487b710000000000000000000000000000000000000000000000000000000000000011"
        );
        pair.mint();
    }

    function testMintZeroLiquidity() public {
        token0.transfer(address(pair), 1000);
        token1.transfer(address(pair), 1000);

        vm.expectRevert(hex"d226f9d4"); // InsufficientLiquidityMinted()
        pair.mint();
    }

    function testBurn() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);

        pair.mint();

        pair.burn();

        assertEq(pair.balanceOf(address(this)), 0);
        _assertReserves(pair, 1000, 1000);
        assertEq(pair.totalSupply(), 1000);
    }

    function testBurnZeroTotalSupply() public {
        // 0x12; If you divide or modulo by zero.
        vm.expectRevert(
            hex"4e487b710000000000000000000000000000000000000000000000000000000000000012"
        );
        pair.burn();
    }

    function testBurnZeroLiquidity() public {
        // Transfer and mint as a normal user.
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 1 ether);
        pair.mint();

        // Burn as a user who hasn't provided liquidity.
        bytes memory prankData = abi.encodeWithSignature("burn()");

        vm.prank(address(0xdeadbeef));
        vm.expectRevert(hex"749383ad"); // InsufficientLiquidityBurned()
        pair.burn();
    }

    function testReservesPacking() public {
        token0.transfer(address(pair), 1 ether);
        token1.transfer(address(pair), 2 ether);
        pair.mint();

        bytes32 val = vm.load(address(pair), bytes32(uint256(8)));
        assertEq(
            val,
            hex"000000000000000000001bc16d674ec800000000000000000de0b6b3a7640000"
        );
    }
}
