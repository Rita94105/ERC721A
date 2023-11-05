// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract NormalNFT is ERC721Enumerable {
    uint tokenId=0;
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}
    
    function mint(address to, uint256 quantity) public {
        for(uint256 i = 0; i < quantity; i++){
            _mint(to, tokenId);
            tokenId++;
        }
    }

    function getTokenId() public view returns(uint){
        return tokenId;
    }
}