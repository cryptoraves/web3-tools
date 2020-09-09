// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./TokenManagement.sol";
import "./UserManagement.sol";

contract TxnManagementPublicViewsLibrary {
    
    using SafeMath for uint256;
    using Address for address;
    
    address internal _tokenManagementContractAddress;
    address internal _userManagementContractAddress;
    uint256 internal _standardMintAmount = 1000000000000000000000000000; //18-decimal adjusted standard amount (1 billion)
    
    //unique function for identifying this contract
    function testForTransactionManagementAddressUniquely() public pure returns(bool){
        return true;
    }
    
    function getTokenManagementAddress() public view returns(address) {
        return _tokenManagementContractAddress;
    }
    
    function getUserManagementAddress() public view returns(address){
        return _userManagementContractAddress;
    } 
    
    function getCryptoravesTokenAddress() public view returns(address){
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
        return _tokenManagement.getCryptoravesTokenAddress();
    }
    
     function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {
        
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
        
        address _userAccount = _userManagement.getUserAccount(_platformId);

        require(_userAccount != address(0), 'User account does not exist');

        return _tokenManagement.getManagedTokenIdByAddress(
            _userAccount
        );
    }
    
    function getUserL1AccountFromL2Account(address _l2) public view returns(address) {
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        return _userManagement.getLayerOneAccount(_l2);
    }
    
    function getUserL2AccountFromL1Account(address _l1) public view returns(address) {
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        return _userManagement.getLayerTwoAccount(_l1);
    }
    
    //conversion functions
    function _stringToBytes( string memory s) public pure returns (bytes memory){
        bytes memory b3 = bytes(s);
        return b3;
    }
    
    function parseAddr(string memory _a) public pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}