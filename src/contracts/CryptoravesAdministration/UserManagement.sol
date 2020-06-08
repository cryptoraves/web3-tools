pragma solidity ^0.6.0;

import "./WalletFull.sol";

contract UserManagement {
    struct User {
        address account;
        bool isManaged;
        bool isUser;
        bool dropped;
        uint256 tokenId;
    }
    
    //maps platform user id to User object
    mapping(uint256 => User) public users;
    
    //for looking up user from account address
    mapping(address => uint256) public userAccounts;
    
    
    function getUserAccount(uint256 _userId) public view returns(address) {
        
        return users[_userId].account;
    }
    
    function _launchL2Account(uint256 _userId) internal returns (address) {
        //launch a managed wallet
        WalletFull receiver = new WalletFull(address(this));
        
         //create a new user
        User memory user;

        user.account = address(receiver);
        user.isManaged = true;
        user.isUser = true;
        users[_userId] = user;
        
        userAccounts[address(receiver)] = _userId;
        
        return address(receiver);
    }
    
    function _userAccountCheck(uint256 _platformUserId) internal returns (address) {
        //create a new user
        if (_isUser(_platformUserId)){
            return users[_platformUserId].account;
        } else {
            return _launchL2Account(_platformUserId);
        }
    }
    
    function _isUser (uint256 _userId) internal view returns(bool) {
      // can we pull from a Chainlink mapping?
      if (users[_userId].isUser) {
          return true;
      } else {
          return false;
      }
    }
}