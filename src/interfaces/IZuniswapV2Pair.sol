// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

interface IZuniswapV2Pair {
    function initialize(address, address) external;

    function getReserves()
        external
        returns (
            uint112,
            uint112,
            uint32
        );

    function mint(address) external returns (uint256);

    function burn(address) external returns (uint256, uint256);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function swap(
        uint256,
        uint256,
        address,
        bytes calldata
    ) external;
}
