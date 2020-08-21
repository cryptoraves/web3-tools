// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./ERCDepositable.sol";
import "./CryptoravesToken.sol";
import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract TokenManagement is  ERCDepositable, IERC721Receiver {
    
    using SafeMath for uint256;
    using Address for address;
    
    address private _cryptoravesTokenAddr;
    
    //Token id list
    address[] public tokenListById;
    
    //mapping for token ids and their origin addresses
    struct ManagedToken {
        uint256 managedTokenId;
        bool isManagedToken;
        uint ercType;
        uint256 totalSupply;
    }
    mapping(address => ManagedToken) public managedTokenListByAddress;
    
    //list of held 1155 token ids
    mapping(address => uint256[]) public heldTokenIds;
    
    event Deposit(address indexed _from, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    event Withdraw(address indexed _to, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    event CryptoDropped(address user, uint256 tokenId);
    
    constructor(string memory _uri) public {
        //default managers include parent contract and ValidatorInterfaceContract Owner
        _administrators[msg.sender] = true;
        _administrators[tx.origin] = true;
        CryptoravesToken newCryptoravesToken = new CryptoravesToken(_uri);
        _cryptoravesTokenAddr = address(newCryptoravesToken);
    }
    
    function getCryptoravesTokenAddress() public view returns(address) {
        return _cryptoravesTokenAddr;
    }
    function changeCryptoravesTokenAddress(address newAddr) public onlyAdmin {
        _cryptoravesTokenAddr = newAddr;
    }

    /* 
        Soleley for DropMyCrypto function. As it designates each new token as non-3rd party 
    
        Turn this public and make it free if through social media.   Charge fee if not. 
        This will reduce false account creation attacks, while allowing dapp-only launches
        
    */
    function dropCrypto(address account, uint256 amount, uint256 _totalSupply, bytes memory data) public virtual onlyAdmin {
        
        if(!managedTokenListByAddress[account].isManagedToken) {
            _addTokenToManagedTokenList(account, 1155, _totalSupply);
        }

        uint256 _1155tokenId = getManagedTokenIdByAddress(account);

        _mint(account, _1155tokenId, amount, data);
        
        emit CryptoDropped(account, _1155tokenId);
        
    }
    
    function depositERC20(uint256 _amount, address _token) public payable returns(uint256){
      
        _depositERC20(_amount, _token);
        if(!managedTokenListByAddress[_token].isManagedToken) {
            _addTokenToManagedTokenList(_token, 20, 0);
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
            _addTokenToManagedTokenList(_token, 721, 0);
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
    
    function getTotalSupply(uint256 _tokenId) public view returns(uint256){
        address _tokenAddr = tokenListById[_tokenId];
        return managedTokenListByAddress[_tokenAddr].totalSupply;
    }
    
    function subtractFromTotalSupply(uint256 _tokenId, uint256 _amount) public onlyAdmin {
        address _tokenAddr = tokenListById[_tokenId];
        managedTokenListByAddress[_tokenAddr].totalSupply = managedTokenListByAddress[_tokenAddr].totalSupply - _amount;
    }
    
    function isManagedToken(address _token) public view returns(bool) {
        return managedTokenListByAddress[_token].isManagedToken;
    }

    function getManagedTokenIdByAddress(address _tokenOriginAddr) public view returns(uint256) {
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenId;
    }
    
    function getTokenListCount() public view returns(uint count) {
        return tokenListById.length;
    }
    
    function _addTokenToManagedTokenList(address _token, uint ercType, uint256 _totalSupply) private onlyAdmin{
        tokenListById.push(_token);
        
        ManagedToken memory _mngTkn;
        
        _mngTkn.managedTokenId = tokenListById.length - 1;
        _mngTkn.isManagedToken = true;
        _mngTkn.ercType = ercType;
        if(_totalSupply > 0){
            _mngTkn.totalSupply = _totalSupply;
        }
        
        managedTokenListByAddress[_token] = _mngTkn;
    }
    
    function _mint( address account, uint256 id, uint256 amount, bytes memory data) private onlyAdmin {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.mint(account, id, amount, data);
        _checkHeldToken(account, id);
    }
    
    function _burn( address account, uint256 id, uint256 amount) private onlyAdmin {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.burn(account, id, amount);
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
            /*move to a transfer function?
            //maintenance. remove if empty
            if(balanceOf(_addr, _tokenId) == 0){
                _removeHeldToken(_addr, i);
            }*/
        }
        return false;
    }
    
    function _checkHeldToken(address _addr, uint256 _tokenId) public onlyAdmin {
        if(!_findHeldToken(_addr, _tokenId)){
            heldTokenIds[_addr].push(_tokenId);
        }
    }
    
    function _removeHeldToken(address _addr, uint index) private onlyAdmin {
        require(index < heldTokenIds[_addr].length);
        heldTokenIds[_addr][index] = heldTokenIds[_addr][heldTokenIds[_addr].length-1];
        delete heldTokenIds[_addr][heldTokenIds[_addr].length-1];
    }
    
    function getHeldTokenIds(address _addr) public view returns(uint256[] memory){
        return heldTokenIds[_addr];
    }
    
    function getHeldTokenBalances(address _addr) public view returns(uint256[] memory){
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        address[] memory _accounts = new address[](heldTokenIds[_addr].length);

        for(uint i=0; i < heldTokenIds[_addr].length; i++){
          _accounts[i] = _addr;  
            
        }
        return instanceCryptoravesToken.balanceOfBatch(
            _accounts,
            heldTokenIds[_addr]
        );
    }
    
    //required for use with safeTransfer in ERC721
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
