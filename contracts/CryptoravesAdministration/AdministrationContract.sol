// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdminToolsLibrary.sol";

interface ITransactionManager {
    function initCommand(uint256[] memory, string[] memory, uint256[] memory, string[] memory) external returns(bool);
    function testForTransactionManagementAddressUniquely() external pure returns(bool);
    function getUserL1AccountFromL2Account(address) external view returns(address);
    function getUserL2AccountFromL1Account(address) external view returns(address);
}

interface ITokenManager {
    function getCryptoravesTokenAddress() external view returns(address);
    function getUserManagementAddress() external view returns(address);
    function getAddressBySymbol(string memory) external view returns(address);
    function getManagedTokenBaseIdByAddress(address) external view returns(uint256);
    function dropCrypto(string memory, address, uint256, uint256, bytes memory) external;
    function _checkHeldToken(address, uint256) external;
    function setIsManagedToken(address, bool) external;
    function adjustValueByUnits(uint256, uint256, uint256) external view returns(uint256);
}

interface IUserManager {
    function getLayerOneAccount(address) external view returns(address);
    function getLayerTwoAccount(address) external view returns(address);
    function userHasL1AddressMapped(address) external view returns(bool);
    function getUserId(address) external view returns(uint256);
    function dropState (uint256) external view returns(bool);
    function userAccountCheck(uint256, string memory, string memory) external returns(address);
    function mapLayerOneAccount(address, address) external;
    function getUserAccount(uint256) external view returns(address);
    function isUser (uint256) external view  returns(bool);
    function setDropState(uint256, bool) external returns (address);
}

interface IDownStream {
    function testDownstreamAdminConfiguration() external view returns(bool);
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
    function isAdministrator(address _addr) public view returns(bool) {
        return _administrators[_addr];
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
                if(AdminToolsLibrary._isContract(_administratorList[i])){
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
    /*
    function testDownstreamAdminConfiguration(address [] memory _downstreamContracts) public view onlyAdmin returns(bool){
        require(_downstreamContracts.length < 3, 'List of _downstreamContracts is too damn long!');
        
        bool _cumulativeReseult;
        _cumulativeReseult = true;
        if(_downstreamContracts.length > 0){
            for (uint i=0; i<_downstreamContracts.length; i++) {
                _cumulativeReseult = _cumulativeReseult && IDownStream(_downstreamContracts[i]).testDownstreamAdminConfiguration();
            }
        }
        return _cumulativeReseult;
        
    }*/
}