// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./AdministrationContract.sol";
import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract CryptoravesToken is ERC1155, AdministrationContract {
    
    using SafeMath for uint256;
    using Address for address;
    
    constructor(string memory _uri) ERC1155(_uri) public {
        //default managers include parent contract and ValidatorInterfaceContract Owner
        setAdministrator(tx.origin);
        setAdministrator(msg.sender);
    }
    
    // General mint function
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public virtual onlyAdmin {
        _mint(account, id, amount, data);
    }
    
    function mintBatch(address account, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual onlyAdmin {
        _mintBatch(account, ids, amounts, data);
    }
    
    function burn(address account, uint256 id, uint256 value) public virtual {
        _burn(account, id, value);
    }

    function burnBatch(address account, uint256[] memory ids, uint256[] memory values) public virtual {
        _burnBatch(account, ids, values);
    }
    
    function setUri(string memory _newUri) public onlyAdmin{
        _setURI(_newUri);
    }
    
    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        return true;
    }
    
    
    
    
    //https://github.com/enjin/erc-1155/blob/master/contracts/ERC1155MixedFungible.sol
    //begin cut-an-pase from mixedFungible:
    
    
    
    // Use a split bit implementation.
    // Store the type in the upper 128 bits..
    uint256 constant TYPE_MASK = uint256(uint128(~0)) << 128;

    // ..and the non-fungible index in the lower 128
    uint256 constant NF_INDEX_MASK = uint128(~0);

    // The top bit is a flag to tell if this is a NFI.
    uint256 constant TYPE_NF_BIT = 1 << 255;

    mapping (uint256 => address) nfOwners;

    // Only to make code clearer. Should not be functions
    function isNonFungible(uint256 _id) public pure returns(bool) {
        return _id & TYPE_NF_BIT == TYPE_NF_BIT;
    }
    function isFungible(uint256 _id) public pure returns(bool) {
        return _id & TYPE_NF_BIT == 0;
    }
    function getNonFungibleIndex(uint256 _id) public pure returns(uint256) {
        return _id & NF_INDEX_MASK;
    }
    function getNonFungibleBaseType(uint256 _id) public pure returns(uint256) {
        return _id & TYPE_MASK;
    }
    function isNonFungibleBaseType(uint256 _id) public pure returns(bool) {
        // A base type has the NF bit but does not have an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK == 0);
    }
    function isNonFungibleItem(uint256 _id) public pure returns(bool) {
        // A base type has the NF bit but does has an index.
        return (_id & TYPE_NF_BIT == TYPE_NF_BIT) && (_id & NF_INDEX_MASK != 0);
    }
    function ownerOf(uint256 _id) public view returns (address) {
        return nfOwners[_id];
    }

    
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal override
    {
        require(ids.length == amounts.length, "Array length must match");

        for (uint256 i = 0; i < ids.length; ++i) {
            // Cache value to local variable to reduce read costs.
            uint256 id = ids[i];

            if (isNonFungible(id)) {
                require(nfOwners[id] == from);
                nfOwners[id] = to;
            }
        }
        operator; data;
    }

}
