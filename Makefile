test:
	forge test -vvv

codehash:
	forge inspect ZuniswapV2Pair bytecode| xargs cast keccak