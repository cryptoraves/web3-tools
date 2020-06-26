// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

import "./UserManagement.sol";
import "./ERCDepositable.sol";

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721Receiver.sol";

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
    
    constructor(string memory _uri) ERC1155(_uri) public {
        _managementContract = msg.sender;
    }
    
    modifier onlyManagement () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _managementContract, 'Sender is not the manager contract.');
      _;
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
    
    function depositERC20(uint256 _amount, address _token) public payable onlyManagement {
        
        _depositERC20(_amount, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            addTokenToManagedTokenList(_token);
            
        }
        
        uint256 _tokenId = _getManagedTokenIdByAddress(_token);
        mint(msg.sender, _tokenId, _amount, '');

    }
    
    function withdrawERC20(uint256 _amount, address _token) public payable onlyManagement {

        _withdrawERC20(_amount, _token);
        
        uint256 _tokenId = _getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _tokenId, _amount);

    }
    function depositERC721(uint256 _tokenId, address _token) public payable onlyManagement {
        
       _depositERC721(_tokenId, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            addTokenToManagedTokenList(_token);
        }
        
        uint256 _1155tokenId = _getManagedTokenIdByAddress(_token);
       _mint(msg.sender, _1155tokenId, _tokenId, '');
        
    }
    
    function withdrawERC721(uint256 _tokenId, address _token) public payable onlyManagement {
        _withdrawERC721(_tokenId, _token);
        
        uint256 _1155tokenId = _getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, _tokenId);
        
    }
    
    function isManagedToken(address _token) public view returns(bool) {
        return managedTokenListByAddress[_token].isManagedToken;
    }

    function _getManagedTokenIdByAddress(address _tokenOriginAddr) public view returns(uint256) {
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenId;
    }
    
    function addTokenToManagedTokenList(address _token) public onlyManagement {
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