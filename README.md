## ERC721

The ERC-721 introduces a standard for NFT, in other words, this type of Token is unique and can have different value than another Token from the same Smart Contract

It only provides functionalities like to transfer tokens from one account to another, to get the current token balance of an account, to get the owner of a specific token and also the total supply of the token available on the network. 

Besides these it also has some other functionalities like to approve that an amount of token from an account can be moved by a third party account.

However, it cannot get token lists of an account, and that is the reason why contracts require to inherit ERC721 Enumerable from Openzepplin.

```
    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;
```

[ERC721 standard](https://ethereum.org/zh-tw/developers/docs/standards/tokens/erc-721/)

[ERC721 illustration in openzeppelin](https://docs.openzeppelin.com/contracts/4.x/api/token/erc721)

[ERC721 contract code](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC721/ERC721.sol)

## ERC721 Enumerable

This contract use lots of mapping to record the relationship between tokenIds and accounts; therefore, this will cause hefty increase in mint process.

```
    // Mapping from owner to list of owned token IDs
    mapping(address => mapping(uint256 => uint256)) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;
```
[ERC721 Enumerable contract code](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC721/extensions/ERC721Enumerable.sol)

## ERC721A

A standard which was published by Azuki community is used to decrease the gas usage in mint process.

There are three main optimizations to improve:

1. Removing duplicate storage from OpenZeppelin’s (OZ) ERC721Enumerable.
   
   - ERC721 Enumerable
     ```
      uint256[] private _allTokens;

      function totalSupply() public view virtual override returns (uint256) {
        return _allTokens.length;
      }
     ```
     
   - ERC721A
     ```
     // The next token ID to be minted.
     uint256 private _currentIndex;
     // The number of tokens burned.
     uint256 private _burnCounter;
     // always start from 0
     function _startTokenId() internal view virtual returns (uint256) {
        return 0;
     }
     function totalSupply() public view virtual override returns (uint256) {
        // Counter underflow is impossible as _burnCounter cannot be incremented
        // more than `_currentIndex - _startTokenId()` times.
        unchecked {
            return _currentIndex - _burnCounter - _startTokenId();
        }
      }
     ```
     
2. updating the owner’s balance once per batch mint request, instead of per minted NFT
   
   - ERC721 - only can mint one token at a time, or use for loop to mint several tokens which will cost more gas fees.
   
   ```
   function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
   ```
   
   - ERC721A
     
  ```
  function _safeMint(address to, uint256 quantity) internal virtual {
        _safeMint(to, quantity, '');
    }
  ```

3. updating the owner data once per batch mint request, instead of per minted NFT

   - ERC721 Enumerable

     ![storage situation](https://github.com/Rita94105/ERC721A/blob/main/img/ERC-721%20storage.png)

   - ERC721 A
     ![improve storage](https://github.com/Rita94105/ERC721A/blob/main/img/ERC-721A%20storage.png)
     ![storage slots situation](https://github.com/Rita94105/ERC721A/blob/main/img/ERC-721A%20storage%20slots.png)
     * transfer slots situation
     ![ERC721A transfer](https://github.com/Rita94105/ERC721A/blob/main/img/ERC-721A%20transfer.png)

 **References:**
    1. [Azuki](https://www.azuki.com/erc721a)
    2. [csdn.net](https://blog.csdn.net/sitebus/article/details/124252119)

## Practice

**observe the difference of gas usage between ERC721 Enumberable and ERC721A from mint(), transfer() and approve() functions.**

1. ERC721.sol : inherit ERC721 Enumerable and implement for loop to mint several tokens at a time.

2. ERC721A.sol : inherit ERC721A and implement mint().

3. ERC721.t.sol: test the gas usage situation in two test function with mint(), transfer() and approve() in ERC721 and ERC721A, respectively.

### Environment

- [foundry](https://book.getfoundry.sh/)

### Build

1. download foundry
```
curl -L https://foundry.paradigm.xyz | bash
```
2. install or update foundry
```
foundryup
```
3. create new project
```
forge init [project name]
```
4. install openzepplin
```
forge install openzeppelin/openzeppelin-contracts --no-commit
```
5. install ERC721A
```
forge install chiru-labs/ERC721A --no-commit
```
6. add dependencies and path
```
forge remappings > remappings.txt
```
### Test

1. download the git
```
git clone https://github.com/Rita94105/ERC721A.git
```

2. adjust the path
```
cd ERC721A
```
3. build project
```
forge build
```
4. generate gas report
```
forge test --gas-report
```

## Result
1. mint only 3 tokens, transfer tokenId=1 to user2, and approve tokenId=0 to user2.
![test result](https://github.com/Rita94105/ERC721A/blob/main/img/gas%20usage%20-%20mint%20small%20number.png)

2. mint 100 tokens, transfer tokenId=50 to user2, and approve tokenId=75 to user2.
![test result](https://github.com/Rita94105/ERC721A/blob/main/img/gas%20usage%20-%20mint%20large%20number.png)

### Conclusion 
1. ERC721 Enumerable usually costs more gas than ERC721A in mint process because of for loop.
2. ERC721A usually costs more gas than ERC721 Enumerable in transfer and approve process, because by transferring a tokenID that does not have an owner address.

   The contract must create actions that include all tokenID’s in order to verify the original NFT owner. 

   This is because the original owner has the right to move the token and set it to a new entity.
   
   Below we present a graph associated with this:
   
   ![image](https://raw.githubusercontent.com/Rita94105/ERC721A/main/img/ERC-721A%20transfer%20costs.webp)

   The above results indicate that moving token IDs in the middle of a larger mint batch (i.e. t1, t2) costs more than moving token IDs at the end of the batch (i.e. t0, t4).

**Reference:**
[nextrope.com](https://nextrope.com/erc721-vs-erc721a-2/)
