// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {NormalNFT} from "../src/ERC721.sol";
import {Azuki} from "../src/ERC721A.sol";

contract ERC721Test is Test{

    address user1 = makeAddr("user1");
    address user2 = makeAddr("user2");

    NormalNFT erc721;
    Azuki erc721a;

    function setUp() public {
        erc721 = new NormalNFT("ERC721", "ERC721");
        erc721a = new Azuki("ERC721A", "ERC721A");
    }

    function testERC721Enumerable() public{
        vm.startPrank(user1);
        erc721.mint(user1, 100);
        erc721.transferFrom(user1, user2, 1);
        erc721.approve(user2, 0);
        vm.stopPrank();
    }

    function testERC721A() public{
        vm.startPrank(user1);
        erc721a.mint(user1, 100);
        erc721a.transferFrom(user1, user2, 1);
        erc721a.approve(user2, 0);
        vm.stopPrank();
    }
}