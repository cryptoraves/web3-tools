// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./WalletFull.sol";
import "./TransactionManagement.sol";

contract UserManagement is AdministrationContract {
    
    using SafeMath for uint256;
    using Address for address;
    
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
    event HandleChange(uint256 _userId, string _handle);
    event ImageChange(uint256 _userId, string imageUrl);
    event LoopErr(string functionName, address addrAttempted, bytes reason);
    
    //maps platform user id to User object
    mapping(uint256 => User) public users;
    
    //for looking up user from account address
    mapping(address => uint256) public userAccounts;

    //for looking up platform ID from handle
    mapping(string => uint256) public userIDs;
    
    constructor() public {
        //default administrators include parent contract and ValidatorInterfaceContract Owner
        _administrators[msg.sender] = true;
        _administrators[tx.origin] = true;
    }
    
    function getUserId(address _account) public view returns(uint256) {
        return userAccounts[_account];
    }
    
    function getUserAccount(uint256 _userId) public view returns(address) {
        return users[_userId].account;
    }

    function getTransactionManagerAddress() public returns(address) {
        return _findTransactionManagementAddress();
    }
    
    function changeTransactionManagerAddress(address _newAddr) public onlyAdmin{
        //TODO: _transactionManagementAddress = _newAddr;
    }
    
    function launchL2Account(uint256 _userId, string memory _twitterHandleFrom, string memory _imageUrl) public onlyAdmin returns (address) {
        //launch a managed wallet
        WalletFull receiver = new WalletFull(getTransactionManagerAddress());
        
         //create a new user
        User memory user;

        user.account = address(receiver);
        user.imageUrl = _imageUrl;
        user.twitterHandle = _twitterHandleFrom;
        user.isManaged = true;
        user.isUser = true;
        
        users[_userId] = user;
        
        userAccounts[address(receiver)] = _userId;
        userIDs[_twitterHandleFrom] = _userId;
        
        emit NewUser(_userId, address(receiver), _imageUrl);
        
        return address(receiver);
    }
    
    function userAccountCheck(uint256 _platformUserId, string memory _twitterHandle, string memory _imageUrl) public onlyAdmin returns (address) {
        //create a new user
        if (isUser(_platformUserId)){
            //check if handle has changed
            if(!_stringsMatch(_twitterHandle, users[_platformUserId].twitterHandle)){
                //update user handle if no match
                users[_platformUserId].twitterHandle = _twitterHandle;
                userIDs[_twitterHandle] = _platformUserId;
                emit HandleChange(_platformUserId, _twitterHandle);
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
    
    function userHasL1AddressMapped(address _userCryptoravesAddr) public view returns(bool){
        address _l1 = WalletFull(_userCryptoravesAddr).getLayerOneAccount();
        if(_l1 == address(0)){
            return false;
        }
        return true;
    }
    
    function getL1AddressMapped(address _userCryptoravesAddr) public view returns(address){
       return WalletFull(_userCryptoravesAddr).getLayerOneAccount();
    }
    
    function isUser (uint256 _userId) public view onlyAdmin returns(bool) {
      if (users[_userId].isUser) {
          return true;
      } else {
          return false;
      }
    }

    function getUser (uint256 _userId) public view onlyAdmin returns(User memory) {
      return users[_userId];
    }

    function getUserIdByPlatformHandle (string memory _platformHandle) public view onlyAdmin returns(uint256) {
      return userIDs[_platformHandle];
    }
    
    function dropState (uint256 _platformUserId) public view returns(bool) {
      // can we pull from a Chainlink mapping?
      if (users[_platformUserId].dropped) {
          return true;
      } else {
          return false;
      }
    }
    
    function setDropState(uint256 _platformUserId) public onlyAdmin returns (address) {
        users[_platformUserId].dropped = true;
    }
    /*
    * Admin Address Looper for hook functionality
    */ 
    function _findTransactionManagementAddress() internal onlyAdmin returns(address){
        require(_administratorList.length < 1000, 'List of administrators is too damn long!');
        
        for (uint i=0; i<_administratorList.length; i++) {
            
            try TransactionManagement(_administratorList[i]).testForTransactionManagementAddressUniquely() {
                return _administratorList[i];
            } catch (bytes memory reason) {
                emit LoopErr('_findTransactionManagementAddress', _administratorList[i], reason);
            }
        }
        
        revert('No TransactionManagementAddress found!');
    }
    
    function _stringsMatch (string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }
}
