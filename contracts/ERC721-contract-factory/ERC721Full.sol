//SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; //release-v3.0.0
import "@openzeppelin/contracts/utils/Counters.sol"; //release-v3.0.0

contract ERC721Full is IERC721Metadata, IERC721Enumerable,  ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor(address userAddress, string memory name, string memory symbol, string memory _baseUri) ERC721(name, symbol) public {
      _setBaseURI(_baseUri);
      uint newItemId = _tokenIds.current();
      _safeMint(userAddress, newItemId);
    }
    function mint(address to) public returns (uint) {
      _tokenIds.increment();
      uint newItemId = _tokenIds.current();
      _safeMint(to, newItemId);
      _setTokenURI(newItemId, newItemId.toString());
      return newItemId;
    }
}
