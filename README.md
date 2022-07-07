# ZUniswapV2, a clone of UniswapV2 made in educational purposes

## Using this repo

1. `git clone git@github.com:Jeiwan/zuniswapv2.git`
1. Ensure you have installed Rust and Cargo: [Install Rust](https://www.rust-lang.org/tools/install)
1. Install Foundry:
   `cargo install --git https://github.com/gakonst/foundry --bin forge --locked`
1. Install dependency contracts:
   `git submodule update --init --recursive`
1. Run tests:
   `forge test`

## Blog posts

1. [Part 1](https://jeiwan.net/posts/programming-defi-uniswapv2-1/), architecture of UniswapV2, adding liquidity, first tests in Solidity, removing liquidity.
1. [Part 2](https://jeiwan.net/posts/programming-defi-uniswapv2-2/), tokens swapping, re-entrancy attacks and protection,
   price oracle, integer overflow and underflow, safe transfer.
1. [Part 3](https://jeiwan.net/posts/programming-defi-uniswapv2-3/), factory contract, CREATE2 opcode, Router contract, Library contract
1. [Part 4](https://jeiwan.net/posts/programming-defi-uniswapv2-4/), LP-tokens burning bug, liquidity removal, output amount calculation, swapExactTokensForTokens, swapTokensForExactTokens, fixing swap fee bug, flash loans, fixing re-entrancy vulnerability, protocol fees