// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "ERC721A/ERC721A.sol";

contract Azuki is ERC721A {
    constructor(string memory name, string memory symbol) ERC721A(name, symbol) {}
    
    function mint(address to, uint256 quantity) public {
        _mint(to, quantity);
    }
}

