// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./ERCDepositable.sol";
import "./CryptoravesToken.sol";

contract TokenManagement is  ERCDepositable {
    
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
        string symbol;
        string emoji;
    }
    mapping(address => ManagedToken) public managedTokenListByAddress;

    //find tokenId by symbol or emoji
    mapping(string => uint256) public symbolAndEmojiLookupTable;

    //list of held 1155 token ids
    mapping(address => uint256[]) public heldTokenIds;
    
    event Deposit(address indexed _from, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId, uint _ercType);
    event Withdraw(address indexed _to, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId);
    event CryptoDropped(address user, uint256 tokenId);
    
    constructor(string memory _uri) public {
        
        setAdministrator(msg.sender);
        CryptoravesToken newCryptoravesToken = new CryptoravesToken(_uri);
        _cryptoravesTokenAddr = address(newCryptoravesToken);
    }
    
    function getCryptoravesTokenAddress() public view returns(address) {
        return _cryptoravesTokenAddr;
    }
    
    function setCryptoravesTokenAddress(address newAddr) public onlyAdmin {
        _cryptoravesTokenAddr = newAddr;
    }

    /* 
        Soleley for DropMyCrypto function. As it designates each new token as non-3rd party 
    
        Turn this public and make it free if through social media.   Charge fee if not. 
        This will reduce false account creation attacks, while allowing dapp-only launches
        
    */
    function dropCrypto(string memory _twitterHandleFrom, address account, uint256 amount, uint256 _totalSupply, bytes memory data) public virtual onlyAdmin {
        
        if(!managedTokenListByAddress[account].isManagedToken) {
            _addTokenToManagedTokenList(account, 1155, _totalSupply);
        }

        uint256 _1155tokenId = getManagedTokenIdByAddress(account);
        
        //add username as symbol
        _checkTickerAddress(_twitterHandleFrom, account);

        _mint(account, _1155tokenId, amount, data);
        
        managedTokenListByAddress[account].symbol = _twitterHandleFrom;
        symbolAndEmojiLookupTable[_twitterHandleFrom] = _1155tokenId;
        
        emit CryptoDropped(account, _1155tokenId);
        
    }
    function getL2AddressForManagedDeposit() private view returns(address){
        //check if existing user:
        ITransactionManager iTxnMgmt = ITransactionManager(getTransactionManagerAddress());
        //1. lookup msg.sender's L2 account 
        address _l2Addr = iTxnMgmt.getUserL2AccountFromL1Account(msg.sender);
        //2. require they are mapped to an L2 account
        require(_l2Addr != address(0), 'Depositor\'s L1 account not mapped to cryptoraves (L2) account');
        return _l2Addr;
    }
    
    function deposit(uint256 _amountOrId, address _token, uint _ercType, bool _managedTransfer) public payable returns(uint256){
        
        uint256 _amount;
        address _mintTo;
        if(_ercType == 20){
            _depositERC20(_amountOrId, _token);
            _amount = _amountOrId;
        } else {
            _depositERC721(_amountOrId, _token);
            _amount = 1;
        }

        if(!managedTokenListByAddress[_token].isManagedToken) {
            _addTokenToManagedTokenList(_token, _ercType, 0);
        }
        
        if(_token != address(0)){ //clause for ETH
            managedTokenListByAddress[_token].totalSupply = getTotalSupplyOf3rdPartyToken(_token);
        } else {
            if (!AdminToolsLibrary._stringsMatch(managedTokenListByAddress[_token].symbol , 'ETH')) {
                managedTokenListByAddress[_token].symbol = 'ETH';
            }
        }
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        
        if(_managedTransfer){
            _mintTo = getL2AddressForManagedDeposit();
        } else {
            _mintTo = msg.sender;
        }
        
        _mint(_mintTo, _1155tokenId, _amount, '');
        
        emit Deposit(_mintTo, _amountOrId, _token, _1155tokenId, _ercType);
        
        return _1155tokenId;
    }

    
    function withdrawERC20(uint256 _amount, address _token) public payable returns(uint256){
        _withdrawERC20(_amount, _token);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, _amount);
        
        Withdraw(msg.sender, _amount, _token, _1155tokenId);
        
        return _1155tokenId;

    }
    
    function withdrawERC721(uint256 _tokenId, address _token) public payable returns(uint256){
        _withdrawERC721(_tokenId, _token);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_token);
        _burn(msg.sender, _1155tokenId, 1);
        
        Withdraw(msg.sender, _tokenId, _token, _1155tokenId);
        
        return _1155tokenId;
        
    }
    
    function getTotalSupply(uint256 _tokenId) public view  returns(uint256){
        address _tokenAddr = tokenListById[_tokenId];
        return managedTokenListByAddress[_tokenAddr].totalSupply;
    }
    
    function getSymbol(uint256 _tokenId) public view  returns(string memory){
        address _tokenAddr = tokenListById[_tokenId];
        return managedTokenListByAddress[_tokenAddr].symbol;
    }
    function setSymbol(uint256 _tokenId, string memory _symbol) public onlyAdmin {
        address _tokenAddr = tokenListById[_tokenId];
        managedTokenListByAddress[_tokenAddr].symbol = _symbol;
        symbolAndEmojiLookupTable[_symbol] = _tokenId;
    }
    function getEmoji(uint256 _tokenId) public view  returns(string memory){
        address _tokenAddr = tokenListById[_tokenId];
        return managedTokenListByAddress[_tokenAddr].emoji;
    }
    function setEmoji(uint256 _tokenId, string memory _emoji) public onlyAdmin {
        address _tokenAddr = tokenListById[_tokenId];
        managedTokenListByAddress[_tokenAddr].emoji = _emoji;
        symbolAndEmojiLookupTable[_emoji] = _tokenId;
    }
    
    //for adjusting incoming human-typed values to smart contract uint values
    function adjustValueByUnits(uint256 _tokenId, uint256 _value, uint256 _decimalPlace) public view onlyAdmin returns(uint256){
        address _tokenAddr = tokenListById[_tokenId];
        ManagedToken memory _tknData = managedTokenListByAddress[_tokenAddr];
        if(_tknData.ercType == 721){
            require(_decimalPlace == 0, 'Attempted to send NFT with fractional value');
            return _value;
        }
        if(_tknData.ercType == 20){
            //check decimals value
            IERCuni _token = IERCuni(_tokenAddr);
            
            uint256 decimals = _token.decimals() - _decimalPlace;
            
            return _value * 10**decimals;
        }
    }
    
    function subtractFromTotalSupply(uint256 _tokenId, uint256 _amount) public onlyAdmin {
        address _tokenAddr = tokenListById[_tokenId];
        managedTokenListByAddress[_tokenAddr].totalSupply = managedTokenListByAddress[_tokenAddr].totalSupply - _amount;
    }
    
    function isManagedToken(address _token) public view returns(bool) {
        return managedTokenListByAddress[_token].isManagedToken;
    }
    
    function setIsManagedToken(address _token, bool _state) public onlyAdmin {
        managedTokenListByAddress[_token].isManagedToken = _state;
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
        
        if(ercType == 20 || ercType == 721){
            //need clause for ETH
            if(address(0) != _token){
                _mngTkn.totalSupply = getTotalSupplyOf3rdPartyToken(_token);
                string memory symbol = getSymbolOf3rdPartyToken(_token);
                _mngTkn.symbol = symbol;
                symbolAndEmojiLookupTable[symbol] = _mngTkn.managedTokenId;
            }
        } else {
            //assign symbol of erc1155
            
            
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
    
    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        IDownStream _downstream = IDownStream(getCryptoravesTokenAddress());
        return _downstream.testDownstreamAdminConfiguration();
    }
}
