// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./UserManagement.sol";
import "./ERCDepositable.sol";

import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract CryptoravesToken is ERC1155Burnable, ERCDepositable, IERC721Receiver, AdministrationContract {
    
    //Token id list
    address[] public tokenListById;
    
    //mapping for token ids and their origin addresses
    struct ManagedToken {
        uint256 managedTokenId;
        bool isManagedToken;
        uint ercType;
    }
    mapping(address => ManagedToken) public managedTokenListByAddress;
    
    //list of held 1155 token ids
    mapping(address => uint256[]) public heldTokenIds;
    
    event Deposit(address indexed _from, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    event Withdraw(address indexed _to, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    event Deploy(address indexed _managementAddress, address indexed _contractAddress);
    event CryptoDropped(address user, uint256 tokenId);
    
    constructor(string memory _uri) ERC1155(_uri) public {
        //default managers include parent contract and ValidatorInterfaceContract Owner
        _administrators[msg.sender] = true;
        _administrators[tx.origin] = true;
        emit Deploy(msg.sender, address(this));
    }
    
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal override
    {
        for(uint i=0; i < ids.length; i++){
            if(amounts[i] > 0){
                if(from == address(0)){
                    _checkHeldToken(to, ids[i]);
                }else{
                    if(balanceOf(from, ids[i]) >= amounts[i]){
                        _checkHeldToken(to, ids[i]);
                    }
                }
            }
        }
        operator; 
        data;
    }
    
    // soleley for DropMyCrypto function. As it designates each new token as non-3rd party
    function mint(address account, uint256 amount, bytes memory data) public virtual onlyAdmin {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        if(!managedTokenListByAddress[account].isManagedToken) {
            _addTokenToManagedTokenList(account, 1155);
        }

        uint256 _1155tokenId = getManagedTokenIdByAddress(account);

        _mint(account, _1155tokenId, amount, data);
        
        emit CryptoDropped(account, _1155tokenId);
        
    }

    
    function mintBatch(address account, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual onlyAdmin {
        require(
            account == _msgSender() || isApprovedForAll(account, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        _mintBatch(account, ids, amounts, data);
    }
    
    function depositERC20(uint256 _amount, address _token) public payable returns(uint256){
        
        _depositERC20(_amount, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            _addTokenToManagedTokenList(_token, 20);
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
            _addTokenToManagedTokenList(_token, 721);
        }
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
       _mint(msg.sender, _1155tokenId, 1, '');
       
       emit Deposit(msg.sender, _tokenId, _token, _1155tokenId);
       
       return _1155tokenId;
        
    }
    
    function withdrawERC721(uint256 _tokenId, address _token) public payable returns(uint256){
        _withdrawERC721(_tokenId, _token);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, 1);
        
        Withdraw(msg.sender, _tokenId, _token, _1155tokenId);
        
        return _1155tokenId;
        
    }
    
    function isManagedToken(address _token) public view returns(bool) {
        return managedTokenListByAddress[_token].isManagedToken;
    }

    function getManagedTokenIdByAddress(address _tokenOriginAddr) public view returns(uint256) {
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenId;
    }
    
    function _addTokenToManagedTokenList(address _token, uint ercType) internal {
        tokenListById.push(_token);
        
        ManagedToken memory _mngTkn;
        
        _mngTkn.managedTokenId = tokenListById.length - 1;
        _mngTkn.isManagedToken = true;
        _mngTkn.ercType = ercType;
        
        managedTokenListByAddress[_token] = _mngTkn;
    }

    function getTokenListCount() public view returns(uint count) {
        return tokenListById.length;
    }
    
    /*****************************tokenId mgmt*************************
     * 
     * 
     * 
     */
    
    function _findHeldToken(address _addr, uint256 _tokenId) internal view returns(bool){
        for(uint i=0; i < heldTokenIds[_addr].length; i++){
            if (heldTokenIds[_addr][i] == _tokenId){
                return true;
            }
            /*move to a transfer function
            //maintenance. remove if empty
            if(balanceOf(_addr, _tokenId) == 0){
                _removeHeldToken(_addr, i);
            }*/
        }
        return false;
    }
    function _checkHeldToken(address _addr, uint256 _tokenId) internal {
        if(!_findHeldToken(_addr, _tokenId)){
            heldTokenIds[_addr].push(_tokenId);
        }
    }
    function _removeHeldToken(address _addr, uint index)  internal {
        require(index < heldTokenIds[_addr].length);
        heldTokenIds[_addr][index] = heldTokenIds[_addr][heldTokenIds[_addr].length-1];
        delete heldTokenIds[_addr][heldTokenIds[_addr].length-1];
    }
    function getHeldTokenIds(address _addr) public view returns(uint256[] memory){
        return heldTokenIds[_addr];
    }
    function getHeldTokenBalances(address _addr) public view returns(uint256[] memory){
        address[] memory _accounts = new address[](heldTokenIds[_addr].length);

        for(uint i=0; i < heldTokenIds[_addr].length; i++){
          _accounts[i] = _addr;  
            
        }
        return balanceOfBatch(
            _accounts,
            heldTokenIds[_addr]
        );
    }
    
    
    //required for use with safeTransfer in ERC721
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
