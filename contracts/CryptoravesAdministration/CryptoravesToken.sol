// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./AdministrationContract.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/ERC1155.sol";

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
    
    function checkHeldToken(address _addr, uint256 _tokenId) public {
        if(!_findHeldToken(_addr, _tokenId)){
            heldTokenIds[_addr].push(_tokenId);
        }
    }
    
    /*
    *  For after each transfer or burn. Remove held token id from account portfolio after checking balance == 0
    */
    function pruneHeldToken(address _addr, uint256 _1155tokenId) private onlyAdmin {
        
        for(uint i=0; i < heldTokenIds[_addr].length; i++){
            if(_1155tokenId == heldTokenIds[_addr][i]){
                delete heldTokenIds[_addr][i];
            }
        }
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
    
    //override function
    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal override{ 
        if(to != address(0)){
            //this is a burn or transfer to
            for(uint i=0; i < ids.length; i++){
                if(balanceOf(to, ids[i]) + amounts[i] > 0){
                    checkHeldToken(to, ids[i]);
                }
            }
        }
        if(from != address(0)){
            //this is a mint or tranfer from
            for(uint i=0; i < ids.length; i++){
                if(balanceOf(from, ids[i]) - amounts[i] == 0){
                    pruneHeldToken(from, ids[i]);
                }
            }
        }
        operator; data;
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
