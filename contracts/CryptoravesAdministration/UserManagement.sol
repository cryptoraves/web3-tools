// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./WalletFull.sol";

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
    
    //maps platform user id to User object
    mapping(uint256 => User) public users;
    
    //for looking up user from account address
    mapping(address => uint256) public userAccounts;
    
    //for getting users' Layer 1 accounts. L2 => L1
    mapping(address => address) public layerOneAccounts;

    //for getting users' Layer 2 account from Layer 1 account. L1 => L2
    mapping(address => address) public layerTwoAccounts;
    
    //for looking up platform ID from handle
    mapping(string => uint256) public userIDs;
    
    constructor() public {
        //default administrators include parent contract and ValidatorInterfaceContract Owner
        setAdministrator(tx.origin);
    }
    
    function getUserId(address _account) public view returns(uint256) {
        return userAccounts[_account];
    }
    
    function getUserAccount(uint256 _userId) public view returns(address) {
        return users[_userId].account;
    }
    
    function setTransactionManagerAddress(address _newAddr) public onlyAdmin{
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
    
    function mapLayerOneAccount(address _l2Addr, address _l1Addr) public onlyAdmin {
        
        require(layerOneAccounts[_l2Addr] == address(0), "User already mapped an L1 account");
        
        WalletFull l2Wallet = WalletFull(_l2Addr);
        l2Wallet.setAdministrator(_l1Addr);
        
        //set L1 account as 1155 operator for this wallet
        address _cryptoravesTokenAddress = ITokenManager(getTransactionManagerAddress()).getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_l1Addr, true);
        
        //set l1 address
        layerOneAccounts[_l2Addr] = _l1Addr;
        layerTwoAccounts[_l1Addr] = _l2Addr;
    }
    
    function getLayerOneAccount(address _l2Addr) public view returns(address){
        return layerOneAccounts[_l2Addr];
    }
    
    function getLayerTwoAccount(address _l1Addr) public view returns(address){
        return layerTwoAccounts[_l1Addr];
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
        address _l1 = layerOneAccounts[_userCryptoravesAddr];
        return _l1 != address(0);
    }
    
    function isUser (uint256 _userId) public view onlyAdmin returns(bool) {
      return users[_userId].isUser;
    }

    function getUser (uint256 _userId) public view onlyAdmin returns(User memory) {
      return users[_userId];
    }

    function getUserIdByPlatformHandle (string memory _platformHandle) public view onlyAdmin returns(uint256) {
      return userIDs[_platformHandle];
    }
    
    function dropState (uint256 _platformUserId) public view returns(bool) {
        // can we pull from a Chainlink mapping?
        return users[_platformUserId].dropped;
    }
    
    //user service function: for resetting dropstate upon request
    function setDropState(uint256 _platformUserId, bool _state) public onlyAdmin returns (address) {
        users[_platformUserId].dropped = _state;
    }
}
