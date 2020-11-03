// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./AdministrationContract.sol";
import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract CryptoravesToken is ERC1155, AdministrationContract {
    
    using SafeMath for uint256;
    using Address for address;
    
    //list of held 1155 token ids
    mapping(address => uint256[]) public heldTokenIds;
    
    constructor(string memory _uri) ERC1155(_uri) public {
        //default managers include parent contract and ValidatorInterfaceContract Owner
        setAdministrator(tx.origin);
        setAdministrator(msg.sender);
    }
    
    function _findHeldToken(address _addr, uint256 _tokenId) internal view returns(bool){
        for(uint i=0; i < heldTokenIds[_addr].length; i++){
            if (heldTokenIds[_addr][i] == _tokenId){
                return true;
            }
        }
        return false;
    }
    
    function checkHeldToken(address _addr, uint256 _tokenId) public onlyAdmin {
        if(!_findHeldToken(_addr, _tokenId)){
            heldTokenIds[_addr].push(_tokenId);
        }
    }
    
    /*
    *  For after each transfer or burn. Remove held token id from account portfolio if no balance remains
    */
    function pruneHeldToken(address _addr, uint256 _1155tokenId) public onlyAdmin returns(bool) {
        
        if(balanceOf(_addr, _1155tokenId) == 0){
            for(uint i=0; i < heldTokenIds[_addr].length; i++){
                if(_1155tokenId == heldTokenIds[_addr][i]){
                    delete heldTokenIds[_addr][i];
                    return true;
                }
            }
        }
        return false;
    }
    
    function getHeldTokenIds(address _addr) public view returns(uint256[] memory){
        return heldTokenIds[_addr];
    }
    
    function getHeldTokenBalances(address _addr) public view returns(uint256[] memory){
        address[] memory _accounts = new address[](heldTokenIds[_addr].length);

        for(uint i=0; i < heldTokenIds[_addr].length; i++){
          _accounts[i] = _addr;  
            
        }
        return balanceOfBatch(
            _accounts,
            heldTokenIds[_addr]
        );
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
}
