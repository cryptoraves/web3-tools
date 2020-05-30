pragma solidity ^0.6.0;

import "./WalletFull.sol";

//can manage tokens for any Cryptoraves-native address
contract TokenManager is ERC1155{
    
    struct User {
        address account;
        bool isManaged;
        bool isUser;
        bool dropped;
        uint256 tokenId;
    }
    
    mapping(uint256 => User) public users;
    mapping(address => uint256) public userAccounts;
    
    //the address of the contract launcher is _manager by default
    address private _manager;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18 decimal adjusted standard amount (1 billion)
    
    modifier onlyManager () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _manager, 'Sender is not the manager.');
      _;
    }
    
    /** 
    * @notice Emits when a deposit is made.
    */
    event Deposit(address indexed _from, uint _value, address indexed _token);
    /**
    * @notice Emits when a withdrawal is made.
    */
    event Withdraw(address indexed _to, uint _value, address indexed _token);
    /**
    * @notice Emits when a Transfer is made.
    */
    event Transfer(address indexed _from, address indexed _to, uint _value, uint256 _token);


    constructor() ERC1155() public {
        _manager = msg.sender;
        
    }
    
    function getUserAccount(uint256 _userId) onlyManager public view returns(address) {
        
        return users[_userId].account;
    }
    
    function initCryptoDrop(uint256 _platformUserId) onlyManager public returns(address) {
        //init account
        address _userAddress = _userAccountCheck(_platformUserId);
        
        //check if user already dropped
        require(!users[_platformUserId].dropped, 'User already dropped their crypto.');
        
        _mint(_userAddress, _platformUserId, _standardMintAmount, '');
        
        users[_platformUserId].dropped = true;
        
        return _userAddress;
    }
    
    function initManagedTransfer(
        uint256 _fromPlatformId,  
        uint256 _toPlatformId, 
        uint256 _tokenId,  
        uint256 _val,
        bytes memory _data
    ) onlyManager public {
        require(_isUser(_fromPlatformId), '_fromPlatformId is not a user');
        
        address _fromAddress = users[_fromPlatformId].account;
        address _toAddress = _userAccountCheck(_toPlatformId);
        
        _managedTransfer(_fromAddress, _toAddress, _tokenId, _val, _data);
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
    
    function _managedTransfer(address _from, address _to, uint256 _tokenId,  uint256 _val, bytes memory _data) internal {
        WalletFull(_from).managedTransfer(_from, _to, _tokenId, _val, _data);
        emit Transfer(_from, _to, _val, _tokenId);
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
