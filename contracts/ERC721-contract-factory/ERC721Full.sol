//SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol"; //release-v3.0.0
import "/home/cartosys/openzeppelin-contracts/contracts/utils/Counters.sol"; //release-v3.0.0

contract ERC721Full is IERC721Metadata, IERC721Enumerable,  ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    string private _strBaseUri;
    
    constructor(address userAddress, string memory name, string memory symbol, string memory _baseUri) ERC721(name, symbol) public {
        uint256 newItemId = _tokenIds.current();
        _safeMint(userAddress, newItemId);
        _strBaseUri = _baseUri;
    }
    
    function mint(address to, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _safeMint(to, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }

    function _baseURI() public view returns (string memory) {
        return _strBaseUri;
    }
}