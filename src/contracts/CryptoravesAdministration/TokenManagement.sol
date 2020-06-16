pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./UserManagement.sol";
import "./ERCDepositable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

//can manage tokens for any Cryptoraves-native address
contract TokenManagement is ERC1155, ERCDepositable, UserManagement, IERC721Receiver {
    
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
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _token);
    
    event CryptoDropped(address user, uint256 tokenId);

    constructor(string memory _uri) ERC1155(_uri) public {
        _manager = msg.sender;
        
    }
     /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterIds [0] = twitterIdFrom, [1] = twitterIdTo, [2] = twitterIdThirdParty
    * @param _twitterNames [0] = twitterHandleFrom, [1] = twitterHandleTo, [2] = thirdPartyName
    * @param _fromImgUrl The Twitter img of initiating user
    * @param _isLaunch launch indicator
    * @param _value amount or id of token to transfer
    */ 
        
    function initCommand(
        uint256[] memory _twitterIds,
        string[] memory _twitterNames,
        string memory _fromImageUrl,
        bool _isLaunch, 
        uint256 _value,
        bytes memory _data
    ) onlyManager public returns(bool){
        
        //launch criteria
        if(_isLaunch){
            initCryptoDrop(_twitterIds[0], _twitterNames[0], _fromImageUrl);
        }else{
            
            require(_isUser(_twitterIds[0]), 'Initiating Twitter user is not a Cryptoraves user');
            
            //get addresses
            address _fromAddress = _userAccountCheck(_twitterIds[0], _twitterNames[0], _fromImageUrl);
            address _toAddress = _userAccountCheck(_twitterIds[1], _twitterNames[1], '');
            
            uint256 _tokenId;
            address _userAccount;
            
            //transfer type check
            if(_twitterIds[2] == 0){
                
                _userAccount = getUserAccount(_twitterIds[0]);
                
                //check if a ticker is being used
                bytes memory ticker = bytes(_twitterNames[2]); // Uses memory
                if (ticker.length != 0) {
                    
                    //get token by ticker name
                    address _addr = tokenAddressesByTicker[_twitterNames[2]];
                    _tokenId = managedTokenListByAddress[_addr].managedTokenId;
                    
                    
                } else {
                    //No third party given, user transfer using thier dropped tokens
                    _tokenId = _getManagedTokenIdByAddress(_userAccount);
                }
                
                
                
            } else {
                
                //user transfer using non-cryptoraves tokens
                _userAccount = getUserAccount(_twitterIds[2]);
                
                require(_userAccount!=address(0), 'Third party token given--with username method--does not exist in system');
                    //not a dropped token attempted to be transferred. Check for 
                _tokenId = _getManagedTokenIdByAddress(_userAccount);
                
            }
            
            _managedTransfer(_fromAddress, _toAddress, _tokenId, _value, _data);
        }
    }
    
    function initCryptoDrop(uint256 _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl) onlyManager public returns(address) {
        //init account
        address _userAddress = _userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);
        
        //check if user already dropped
        require(!users[_platformUserId].dropped, 'User already dropped their crypto.');
        
        _addTokenToManagedTokenList(_userAddress);
        
        uint256 _tokenId = _getManagedTokenIdByAddress(_userAddress);
        
        _mint(_userAddress, _tokenId, _standardMintAmount, '');
        
        users[_platformUserId].dropped = true;
        
        emit CryptoDropped(_userAddress, _tokenId);
        
        return _userAddress;
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
        emit Transfer(address(this), msg.sender, _tokenId, _1155tokenId); 
    }
    
    function withdrawERC721(uint256 _tokenId, address _token) public payable {
        
        _withdrawERC721(_tokenId, _token);
        
        uint256 _1155tokenId = _getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, _tokenId);
        
        //must be last to execute for web3 processing
        emit Transfer(msg.sender, address(this), _tokenId, _1155tokenId); 
    }
    
    function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {
        return _getManagedTokenIdByAddress(getUserAccount(_platformId));
    }
    
    function managedTokenCount() public view returns(uint) {
        return tokenListById.length; 
    }
    
    function _addTokenToManagedTokenList(address _token) internal {
        tokenListById.push(_token);
        
        ManagedToken memory _mngTkn;
        
        _mngTkn.managedTokenId = tokenListById.length - 1;
        _mngTkn.isManagedToken = true;
        
        managedTokenListByAddress[_token] = _mngTkn;
    }
    
    function _getManagedTokenIdByAddress(address _tokenOriginAddr) public view returns(uint256) {
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenId;
    }
    
    function _managedTransfer(address _from, address _to, uint256 _tokenId,  uint256 _val, bytes memory _data) internal {
        WalletFull(_from).managedTransfer(_from, _to, _tokenId, _val, _data);
        emit Transfer(_from, _to, _val, _tokenId);
    }
    
    //required for use with safeTransfer in ERC721
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
