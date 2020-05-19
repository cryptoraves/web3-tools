pragma solidity ^0.6.2;

import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/token/ERC721/ERC721.sol"; //release-v3.0.0
import "https://raw.githubusercontent.com/OpenZeppelin/openzeppelin-contracts/master/contracts/utils/Counters.sol"; //release-v3.0.0

contract ERC721Full is IERC721Metadata, IERC721Enumerable,  ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    constructor(address userAddress, string memory name, string memory symbol) ERC721(name, symbol) public {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(userAddress, newItemId);
    }
    
    function mint(address to, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}