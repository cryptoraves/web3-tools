// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./AdministrationContract.sol";

contract AdministrationContract {

    /*
    * Legit list of admin addresses & loopable array
    */
    mapping(address => bool) internal _administrators;
    address [] internal _administratorList;
    
    event NewAdministrator(address indexed _newAdminAddr, address indexed _fromContractAddr);
    event RemovedAdministrator(address indexed _oldAdminAddr, address indexed _fromContractAddr);
    
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
}