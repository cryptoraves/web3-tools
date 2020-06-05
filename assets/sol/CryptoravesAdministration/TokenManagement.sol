pragma solidity ^0.6.0;

import "./UserManagement.sol";
import "./ERC20Depositable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

//can manage tokens for any Cryptoraves-native address
contract TokenManagement is ERC1155, ERC20Depositable, UserManagement, IERC721Receiver {
    
    //Token id list
    address[] public tokenListById;
    
    //mapping for token ids and their origin addresses
    struct ManagedToken {
        uint256 managedTokenId;
        bool isManagedToken;
    }
    mapping(address => ManagedToken) public managedTokenListByAddress;
    
    
    //the address of the contract launcher is _manager by default
    address private _manager;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18 decimal adjusted standard amount (1 billion)
    
    modifier onlyManager () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _manager, 'Sender is not the manager.');
      _;
    }
    
    event Transfer(address indexed _from, address indexed _to, uint _value, uint256 _token);


    constructor(string memory _uri) ERC1155(_uri) public {
        _manager = msg.sender;
        
    }
    
    function initCryptoDrop(uint256 _platformUserId) onlyManager public returns(address) {
        //init account
        address _userAddress = _userAccountCheck(_platformUserId);
        
        //check if user already dropped
        require(!users[_platformUserId].dropped, 'User already dropped their crypto.');
        
        _addTokenToManagedTokenList(_userAddress);
        
        _mint(_userAddress, _getManagedTokenIdByAddress(_userAddress), _standardMintAmount, '');
        
        users[_platformUserId].dropped = true;
        
        return _userAddress;
    }
    
    function initManagedTransfer(
        uint256 _fromPlatformId,  
        uint256 _toPlatformId, 
        uint256 _platformId,  
        uint256 _val,
        bytes memory _data
    ) onlyManager public {
        require(_isUser(_fromPlatformId), '_fromPlatformId is not a user');
        
        address _fromAddress = users[_fromPlatformId].account;
        address _toAddress = _userAccountCheck(_toPlatformId);
        address _userAccount = getUserAccount(_platformId);
        
        _managedTransfer(_fromAddress, _toAddress, _getManagedTokenIdByAddress(_userAccount), _val, _data);
    }
    
    function depositERC20(uint256 _amount, address _token) public payable {
        
        _depositERC20(_amount, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            _addTokenToManagedTokenList(_token);
        }
        
        uint256 _tokenId = _getManagedTokenIdByAddress(_token);
        _mint(msg.sender, _tokenId, _amount, '');
        
        //must be last to execute for web3 processing
        emit Transfer(address(this), msg.sender, _amount, _tokenId); 
    }
    
    function withdrawERC20(uint256 _amount, address _token) public payable {
        
        _withdrawERC20(_amount, _token);
        
        uint256 _tokenId = _getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _tokenId, _amount);
        
        //must be last to execute for web3 processing
        emit Transfer(msg.sender, address(this), _amount, _tokenId); 
    }
    function depositERC721(uint256 _tokenId, address _token) public payable {
        
        _depositERC721(_tokenId, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            _addTokenToManagedTokenList(_token);
        }
        
        uint256 _1155tokenId = _getManagedTokenIdByAddress(_token);
        _mint(msg.sender, _1155tokenId, _tokenId, '');
        
        //must be last to execute for web3 processing
        emit Transfer(address(this), msg.sender, _1155tokenId, _tokenId); 
    }
    
    function withdrawERC721(uint256 _tokenId, address _token) public payable {
        
        _withdrawERC721(_tokenId, _token);
        
        uint256 _1155tokenId = _getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, _tokenId);
        
        //must be last to execute for web3 processing
        emit Transfer(msg.sender, address(this), _1155tokenId, _tokenId); 
    }
    
    function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {
        _getManagedTokenIdByAddress(getUserAccount(_platformId));
    }
    
    function _addTokenToManagedTokenList(address _token) internal {
        tokenListById.push(_token);
        managedTokenListByAddress[_token].managedTokenId = _getLatestManagedTokenId();
        managedTokenListByAddress[_token].isManagedToken = true;
    }
    
    function _getLatestManagedTokenId() internal view returns(uint256) {
        return tokenListById.length - 1;
    }
    
    function _getManagedTokenIdByAddress(address _tokenOriginAddr) internal view returns(uint256) {
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenId;
    }
    
    function _managedTransfer(address _from, address _to, uint256 _tokenId,  uint256 _val, bytes memory _data) internal {
        WalletFull(_from).managedTransfer(_from, _to, _tokenId, _val, _data);
        emit Transfer(_from, _to, _val, _tokenId);
    }
    
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
