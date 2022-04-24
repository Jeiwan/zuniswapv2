test:
	forge test -vvv
codehash:
	cat out/ZuniswapV2Pair.sol/ZuniswapV2Pair.json | jq -r .bytecode.object | xargs cast keccak