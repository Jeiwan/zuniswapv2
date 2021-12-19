// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract ZuniswapV2Pair is ERC20 {
    address public token0;
    address public token1;
    uint256 public reserve0;
    uint256 public reserve1;

    constructor(address token0_, address token1_) {
        token0 = token0_;
        token1 = token1_;
    }

    function mint() public {}
}
