// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "solmate/tokens/ERC20.sol";

contract ERC20Mintable is ERC20 {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_, 18)
    {}

    function mint(uint256 amount, address to) public {
        _mint(to, amount);
    }
}
