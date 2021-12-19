// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "../ERC20.sol";

contract ERC20Mintable is ERC20 {
    constructor(string memory name_, string memory symbol_)
        ERC20(name_, symbol_)
    {}

    function mint(uint256 amount) public {
        _mint(msg.sender, amount);
    }
}
