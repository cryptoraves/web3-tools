// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

import "./WalletFull.sol";

contract UserManagement {
    struct User {
        address account;
        string twitterHandle;
        string imageUrl;
        bool isManaged;
        bool isUser;
        bool dropped;
        uint256 tokenId;
    }
    
    event NewUser(uint256 _userId, address _address, string imageUrl);
    
    //maps platform user id to User object
    mapping(uint256 => User) public users;
    
    //for looking up user from account address
    mapping(address => uint256) public userAccounts;
    
    address private _userManager;
    
    modifier onlyUserManager () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _userManager, 'Sender is not the user manager.');
      _;
    }
    
    constructor() public {
        _userManager = msg.sender;
    }
    function getUserId(address _account) public view returns(uint256) {
        
        return userAccounts[_account];
    }
    function getUserAccount(uint256 _userId) public view returns(address) {
        
        return users[_userId].account;
    }
    
    function launchL2Account(uint256 _userId, string memory _twitterHandleFrom, string memory _imageUrl) public onlyUserManager returns (address) {
        //launch a managed wallet
        WalletFull receiver = new WalletFull(address(this));
        
         //create a new user
        User memory user;

        user.account = address(receiver);
        user.imageUrl = _imageUrl;
        user.twitterHandle = _twitterHandleFrom;
        user.isManaged = true;
        user.isUser = true;
        
        users[_userId] = user;
        
        userAccounts[address(receiver)] = _userId;
        
        emit NewUser(_userId, address(receiver), _imageUrl);
        
        return address(receiver);
    }
    
    function userAccountCheck(uint256 _platformUserId, string memory _twitterHandle, string memory _imageUrl) public onlyUserManager returns (address) {
        //create a new user
        if (_isUser(_platformUserId)){
            //check if handle has changed
            if(!_stringsMatch(_twitterHandle, users[_platformUserId].twitterHandle)){
                //update user handle if no match
                users[_platformUserId].twitterHandle = _twitterHandle;
            }
            //check if imageUrl has changed
            if(!_stringsMatch(_imageUrl, users[_platformUserId].imageUrl)){
                //make sure imageUrl isn't empty
                if(!_stringsMatch(_imageUrl, '')){
                    users[_platformUserId].imageUrl = _imageUrl;
                }
            }
            return users[_platformUserId].account;
        } else {
            return launchL2Account(_platformUserId, _twitterHandle, _imageUrl);
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
    
    function _stringsMatch (string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }
}
