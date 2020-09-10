// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./AdministrationContract.sol";

interface ITransactionManager {
    function testForTransactionManagementAddressUniquely() external pure returns(bool);
    function getUserL1AccountFromL2Account(address _l2) external view returns(address);
    function getUserL2AccountFromL1Account(address _l1) external view returns(address);
}

contract AdministrationContract {

    /*
    * Legit list of admin addresses & loopable array
    */
    mapping(address => bool) private _administrators;
    address [] internal _administratorList;
    
    event NewAdministrator(address indexed _newAdminAddr, address indexed _fromContractAddr);
    event RemovedAdministrator(address indexed _oldAdminAddr, address indexed _fromContractAddr);
    event ErrorHandled(string reason);
    
    constructor() public {
        //default validator is set to sender
        _administrators[msg.sender] = true;
        _administratorList.push(msg.sender);
    }
    
    /*
    * Require msg.sender to be administrator
    */
    modifier onlyAdmin () {
      // can we pull from a Chainlink mapping?
      require(_administrators[msg.sender], 'Sender is not the parent contract nor an admin.');
      _;
    }
    
    /*
    * Return admin flag of sender
    */
    function isAdministrator() public view returns(bool) {
        return _administrators[msg.sender];
    }
    
    /*
    * Add an admin to the list
    * @param _newAdmin The address of the new admin
    */
    function setAdministrator(address _newAdmin) public onlyAdmin {
        _administrators[_newAdmin] = true;
        _administratorList.push(_newAdmin);
        emit NewAdministrator(_newAdmin, address(this));
    }
    
    /*
    * de-authorize an admin
    * @param oldAdmin The address of the admin to remove access
    */
    function unsetAdministrator(address _oldAdmin) public onlyAdmin {
        _administrators[_oldAdmin] = false;
        emit RemovedAdministrator(_oldAdmin, address(this));
    }
    
    /*
    * For checking if contract is launched
    */
    function isAvailable() public pure returns(bool) {
        return true;
    }
    
    /*
    * Admin Address Looper for hook functionality
    */ 
    function getTransactionManagerAddress() public view returns(address) {
        require(_administratorList.length < 1000, 'List of administrators is too damn long!');
        
        for (uint i=0; i<_administratorList.length; i++) {
            //first, ensure _administrator is set to true 
            if(_administrators[_administratorList[i]]){
                //check if address is a contract
                if( isContract(_administratorList[i])){
                    //first instantiate existing contract
                    ITransactionManager iTxnMgmt = ITransactionManager(_administratorList[i]);    
                    //then try to run its function
                    try iTxnMgmt.testForTransactionManagementAddressUniquely() {
                        return _administratorList[i];
                    } catch {}
                }
            }
        }
        
        revert('No TransactionManagementAddress found!');
    }
    //for checking if address is a contract or not
    function isContract(address _addr) private view returns (bool){
      uint32 size;
      assembly {
        size := extcodesize(_addr)
      }
      return (size > 0);
    }
    function _stringsMatch (string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
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