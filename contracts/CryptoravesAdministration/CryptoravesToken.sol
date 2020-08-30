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
    }
 /*   
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
        for(uint i=0; i < ids.length; i++){
            if(amounts[i] > 0){
                if(from == address(0)){
                    _checkHeldToken(to, ids[i]);
                }else{
                    if(balanceOf(from, ids[i]) >= amounts[i]){
                        _checkHeldToken(to, ids[i]);
                    }
                }
            }
        }
        operator; 
        data;
    }
*/
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
}
