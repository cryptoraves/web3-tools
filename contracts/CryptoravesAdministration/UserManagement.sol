// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./WalletFull.sol";

contract UserManagement is AdministrationContract {

    using SafeMath for uint256;
    using Address for address;

    struct User {
        uint256 twitterUserId;
        address cryptoravesAddress;
        string twitterHandle;
        string imageUrl;
        bool isManaged;
        bool isUser;
        bool dropped;
        uint256 tokenId;
    }

    event UserData(User);
    event UsernameChange(address _cryptoravesAddress, string _handle);
    event ImageChange(address _cryptoravesAddress, string imageUrl);
    event HeresMyAddress(address _layer1Address, address _cryptoravesAddress, uint256 _tweetId);

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
        //default administrator
        setAdministrator(msg.sender);
    }

    function getUserId(address _account) public view returns(uint256) {
        return userAccounts[_account];
    }



    function getUserAccount(uint256 _platformUserId) public view returns(address) {
        return users[_platformUserId].cryptoravesAddress;
    }
    function isUser (uint256 _userId) public view onlyAdmin returns(bool) {
      return users[_userId].isUser;
    }
    function dropState (uint256 _platformUserId) public view returns(bool) {
        // can we pull from a Chainlink mapping?
        return users[_platformUserId].dropped;
    }


    function getUserStruct(uint256 _platformUserId) public view returns(User memory) {
        return users[_platformUserId];
    }

    function launchL2Account(uint256 _userId, string memory _twitterHandleFrom, string memory _imageUrl) public onlyAdmin returns (User memory) {
        //launch a managed wallet
        WalletFull receiver;
        address receiverAddress;
        if(_userId == 0){
          receiverAddress = address(0);
        } else {
          receiver = new WalletFull(getTransactionManagerAddress());
          receiverAddress = address(receiver);
        }

         //create a new user
        User memory user;
        user.twitterUserId = _userId;
        user.cryptoravesAddress = receiverAddress;
        user.imageUrl = _imageUrl;
        user.twitterHandle = _twitterHandleFrom;
        user.isManaged = true;
        user.isUser = true;

        users[_userId] = user;

        userAccounts[receiverAddress] = _userId;
        userIDs[_twitterHandleFrom] = _userId;

        emit UserData(user);

        return user;
    }

    function mapLayerOneAccount(address _l2Addr, address _l1Addr, uint256 _tweetId) public onlyAdmin {

        require(layerOneAccounts[_l2Addr] == address(0), "User already mapped an L1 account");

        WalletFull l2Wallet = WalletFull(_l2Addr);
        l2Wallet.setAdministrator(_l1Addr);

        //set L1 account as 1155 operator for this wallet
        address _TokenManagerAddress = ITransactionManager(getTransactionManagerAddress()).tokenManagementContractAddress();
        address _cryptoravesTokenAddress = ITokenManager(_TokenManagerAddress).cryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_l1Addr, true);

        //set l1 address
        layerOneAccounts[_l2Addr] = _l1Addr;
        layerTwoAccounts[_l1Addr] = _l2Addr;

        emit HeresMyAddress(_l1Addr, _l2Addr, _tweetId);
    }

    function getLayerOneAccount(address _l2Addr) public view returns(address){
        return layerOneAccounts[_l2Addr];
    }

    function getLayerTwoAccount(address _l1Addr) public view returns(address){
        return layerTwoAccounts[_l1Addr];
    }

    function userAccountCheck(uint256 _platformUserId, string memory _twitterHandle, string memory _imageUrl) public onlyAdmin returns (User memory) {
        //create a new user
        if (isUser(_platformUserId)){
            //check if handle has changed
            if(!AdminToolsLibrary._stringsMatch(_twitterHandle, users[_platformUserId].twitterHandle)){
                //update user handle if no match
                users[_platformUserId].twitterHandle = _twitterHandle;
                userIDs[_twitterHandle] = _platformUserId;
                emit UsernameChange(users[_platformUserId].cryptoravesAddress, _twitterHandle);
            }
            //check if imageUrl has changed
            if(!AdminToolsLibrary._stringsMatch(_imageUrl, users[_platformUserId].imageUrl)){
                //make sure imageUrl isn't empty
                if(!AdminToolsLibrary._stringsMatch(_imageUrl, '')){
                    users[_platformUserId].imageUrl = _imageUrl;
                    emit ImageChange(users[_platformUserId].cryptoravesAddress, _imageUrl);
                }
            }
            return users[_platformUserId];
        } else {
            return launchL2Account(_platformUserId, _twitterHandle, _imageUrl);
        }
    }

    function userHasL1AddressMapped(address _userCryptoravesAddr) public view returns(bool){
        address _l1 = layerOneAccounts[_userCryptoravesAddr];
        return _l1 != address(0);
    }

    function getUserIdByPlatformHandle (string memory _platformHandle) public view onlyAdmin returns(uint256) {
      return userIDs[_platformHandle];
    }

    //user service function: for resetting dropstate upon request
    function setDropState(uint256 _platformUserId, bool _state) public onlyAdmin returns (address) {
        users[_platformUserId].dropped = _state;
    }

    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        return true;
    }
}
