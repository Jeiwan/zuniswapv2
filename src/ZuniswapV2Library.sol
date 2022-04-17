// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "./interfaces/IZuniswapV2Factory.sol";
import "./interfaces/IZuniswapV2Pair.sol";
import {ZuniswapV2Pair} from "./ZuniswapV2Pair.sol";

library ZuniswapV2Library {
    error InsufficientAmount();
    error InsufficientLiquidity();
    error InvalidPath();

    function getReserves(
        address factoryAddress,
        address tokenA,
        address tokenB
    ) public returns (uint256 reserveA, uint256 reserveB) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        (uint256 reserve0, uint256 reserve1, ) = IZuniswapV2Pair(
            pairFor(factoryAddress, token0, token1)
        ).getReserves();
        (reserveA, reserveB) = tokenA == token0
            ? (reserve0, reserve1)
            : (reserve1, reserve0);
    }

    function quote(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256 amountOut) {
        if (amountIn == 0) revert InsufficientAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        return (amountIn * reserveOut) / reserveIn;
    }

    function sortTokens(address tokenA, address tokenB)
        internal
        pure
        returns (address token0, address token1)
    {
        return tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    function pairFor(
        address factoryAddress,
        address tokenA,
        address tokenB
    ) internal pure returns (address pairAddress) {
        (address token0, address token1) = sortTokens(tokenA, tokenB);
        pairAddress = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            hex"ff",
                            factoryAddress,
                            keccak256(abi.encodePacked(token0, token1)),
                            keccak256(type(ZuniswapV2Pair).creationCode)
                        )
                    )
                )
            )
        );
    }

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256) {
        if (amountIn == 0) revert InsufficientAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = (reserveIn * 1000) + amountInWithFee;

        return numerator / denominator;
    }

    function getAmountsOut(
        address factory,
        uint256 amountIn,
        address[] memory path
    ) public returns (uint256[] memory) {
        if (path.length < 2) revert InvalidPath();
        uint256[] memory amounts = new uint256[](path.length);
        amounts[0] = amountIn;

        for (uint256 i; i < path.length - 1; i++) {
            (uint256 reserve0, uint256 reserve1) = getReserves(
                factory,
                path[i],
                path[i + 1]
            );
            amounts[i + 1] = getAmountOut(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) public pure returns (uint256) {
        if (amountOut == 0) revert InsufficientAmount();
        if (reserveIn == 0 || reserveOut == 0) revert InsufficientLiquidity();

        uint256 numerator = reserveIn * amountOut * 1000;
        uint256 denominator = (reserveOut - amountOut) * 997;

        return (numerator / denominator) + 1;
    }

    function getAmountsIn(
        address factory,
        uint256 amountOut,
        address[] memory path
    ) public returns (uint256[] memory) {
        if (path.length < 2) revert InvalidPath();
        uint256[] memory amounts = new uint256[](path.length);
        amounts[amounts.length - 1] = amountOut;

        for (uint256 i = path.length - 1; i > 0; i--) {
            (uint256 reserve0, uint256 reserve1) = getReserves(
                factory,
                path[i - 1],
                path[i]
            );
            amounts[i - 1] = getAmountIn(amounts[i], reserve0, reserve1);
        }

        return amounts;
    }
}
