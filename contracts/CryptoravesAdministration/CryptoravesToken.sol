// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./UserManagement.sol";
import "./ERCDepositable.sol";

import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract CryptoravesToken is ERC1155Burnable, ERCDepositable, IERC721Receiver {
    
    address private _managementContract;
    
    //Token id list
    address[] public tokenListById;
    
    //mapping for token ids and their origin addresses
    struct ManagedToken {
        uint256 managedTokenId;
        bool isManagedToken;
    }
    mapping(address => ManagedToken) public managedTokenListByAddress;
    
    /**
    * @notice Emits when a deposit is made.
    */
    event Deposit(address indexed _from, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    /**
    * @notice Emits when a withdrawal is made.
    */
    event Withdraw(address indexed _to, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    
    event Deploy(address indexed _managementAddress, address indexed _contractAddress);
    
    modifier onlyManagement () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _managementContract, 'Sender is not the manager contract.');
      _;
    }

    constructor(string memory _uri) ERC1155(_uri) public {
        _managementContract = msg.sender;
        emit Deploy(msg.sender, address(this));
    }
    
    function mint(address account, uint256 id, uint256 amount, bytes memory data) public virtual onlyManagement {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _mint(account, id, amount, data);
    }

    function mintBatch(address account, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual onlyManagement {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _mintBatch(account, ids, amounts, data);
    }
    
    function depositERC20(uint256 _amount, address _token) public payable returns(uint256){
        
        _depositERC20(_amount, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            addTokenToManagedTokenList(_token);
        }
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        _mint(msg.sender, _1155tokenId, _amount, '');
        
        emit Deposit(msg.sender, _amount, _token, _1155tokenId);
        
        return _1155tokenId;

    }
    
    function withdrawERC20(uint256 _amount, address _token) public payable returns(uint256){

        _withdrawERC20(_amount, _token);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, _amount);
        
        Withdraw(msg.sender, _amount, _token, _1155tokenId);
        
        return _1155tokenId;

    }
    function depositERC721(uint256 _tokenId, address _token) public payable returns(uint256){
        
       _depositERC721(_tokenId, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            addTokenToManagedTokenList(_token);
        }
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
       _mint(msg.sender, _1155tokenId, _tokenId, '');
       
       emit Deposit(msg.sender, _tokenId, _token, _1155tokenId);
       
       return _1155tokenId;
        
    }
    
    function withdrawERC721(uint256 _tokenId, address _token) public payable returns(uint256){
        _withdrawERC721(_tokenId, _token);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, _tokenId);
        
        Withdraw(msg.sender, _tokenId, _token, _1155tokenId);
        
        return _1155tokenId;
        
    }
    
    function isManagedToken(address _token) public view returns(bool) {
        return managedTokenListByAddress[_token].isManagedToken;
    }

    function getManagedTokenIdByAddress(address _tokenOriginAddr) public view returns(uint256) {
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenId;
    }
    
    function addTokenToManagedTokenList(address _token) public {
        tokenListById.push(_token);
        
        ManagedToken memory _mngTkn;
        
        _mngTkn.managedTokenId = tokenListById.length - 1;
        _mngTkn.isManagedToken = true;
        
        managedTokenListByAddress[_token] = _mngTkn;
    }
    
    //required for use with safeTransfer in ERC721
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}