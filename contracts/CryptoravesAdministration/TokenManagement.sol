// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./ERCDepositable.sol";
import "./CryptoravesToken.sol";

contract TokenManagement is  ERCDepositable {
    
    using SafeMath for uint256;
    using Address for address;
    
    address private _cryptoravesTokenAddr;
    
    //Inceremental base token id list
    address[] public tokenListByBaseId;
    
    
    mapping(address => ManagedToken) public managedTokenListByAddress;

    //find tokenId by symbol or emoji
    mapping(string => uint256) public symbolAndEmojiLookupTable;
    
    event Deposit(address indexed _from, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId, uint _ercType);
    event Withdraw(address indexed _to, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId, uint _ercType);
    event Token(ManagedToken);
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
    function dropCrypto(string memory _twitterHandleFrom, address account, uint256 amount, bytes memory data) public virtual onlyAdmin {
       
        if(!managedTokenListByAddress[account].isManagedToken) {
            _addTokenToManagedTokenList(account, 1155);
        }

        uint256 _1155tokenId = getManagedTokenIdByAddress(account);
        
        //add username as symbol
        _checkSymbolAddress(_twitterHandleFrom, _1155tokenId);

        _mint(account, _1155tokenId, amount, data);
        
        managedTokenListByAddress[account].symbol = _twitterHandleFrom;
        symbolAndEmojiLookupTable[_twitterHandleFrom] = _1155tokenId;
        
        emit CryptoDropped(account, _1155tokenId);
        
    }
    
    function _checkSymbolAddress(string memory _sym, uint256 _tokenId) internal {
        //only adds ticker if not yet taken
        if(symbolAndEmojiLookupTable[_sym] == 0){
            symbolAndEmojiLookupTable[_sym] = _tokenId;
        }
    }
    function getL2AddressForManagedDeposit() private view returns(address){
        //check if existing user:
        ITransactionManager iTxnMgmt = ITransactionManager(getTransactionManagerAddress());
        //1. lookup msg.sender's L2 account 
        address _l2Addr = iTxnMgmt.getUserL2AccountFromL1Account(msg.sender);
        //2. require they are mapped to an L2 account
        require(_l2Addr != address(0), 'Depositor/Withdrawer\'s L1 account not mapped to cryptoraves (L2) account');
        return _l2Addr;
    }
    
    function deposit(uint256 _amountOrId, address _contract, uint _ercType, bool _managedTransfer) public payable returns(uint256){
        
        if(!managedTokenListByAddress[_contract].isManagedToken) {
            _addTokenToManagedTokenList(_contract, _ercType);
        }
          
        uint256 _1155tokenId;
        
        address _mintTo;
        if(_managedTransfer){
            _mintTo = getL2AddressForManagedDeposit();
        } else {
            _mintTo = msg.sender;
        }
        
        uint256 _amount;
        if(_ercType == 20){
            _depositERC20(_amountOrId, _contract);
            _amount = _amountOrId;
            _1155tokenId = getManagedTokenIdByAddress(_contract);
        }
        if(_ercType == 721){
            _depositERC721(_amountOrId, _contract);
            _amount = 1;
            _1155tokenId = getManagedTokenIdByAddress(_contract) + _amountOrId;
        }
        
        _mint(_mintTo, _1155tokenId, _amount, '');
        
        emit Deposit(_mintTo, _amountOrId, _contract, _1155tokenId, _ercType);
        
        return _1155tokenId;
    }

    
    function withdrawERC20(uint256 _amount, address _contract, bool _isManagedWithdraw) public payable returns(uint256){
        _withdrawERC20(_amount, _contract);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_contract);
        address _burnAddr;
        if (_isManagedWithdraw) {
            _burnAddr = getL2AddressForManagedDeposit();
        } else {
            _burnAddr = msg.sender;   
        }

        _burn(_burnAddr, _1155tokenId, _amount);
        emit Withdraw(msg.sender, _amount, _contract, _1155tokenId, 20);
        
        return _1155tokenId;

    }
    
    function withdrawERC721(uint256 _tokenId, address _contract, bool _isManagedWithdraw) public payable returns(uint256){
        _withdrawERC721(_tokenId, _contract);
        
        uint256 _1155tokenId = getManagedTokenIdByAddress(_contract) + _tokenId;
        address _burnAddr;
        if (_isManagedWithdraw) {
            _burnAddr = getL2AddressForManagedDeposit();
        } else {
            _burnAddr = msg.sender;   
        }

        _burn(_burnAddr, _1155tokenId, 1);
        emit Withdraw(msg.sender, _tokenId, _contract, _1155tokenId, 721);

        return _1155tokenId;
        
    }
    /* 
    * executes deposit and withdraw functions via proxy. Thus eliminating Wallet Software adjustments for L2. See  https://github.com/uport-project/uport-identity/blob/develop/contracts/Proxy.sol
    * @param destination = Cryptoraves User Account Address
    * @param value = Ether value of transaction. Should be zero?
    * @param data = Data payload of transaction
    */
    function proxyDepositWithdraw(address destination, uint value, bytes memory data) public onlyAdmin returns (bool success){
        uint txGas = 0;
        assembly {
            success := call(txGas, destination, value, add(data, 0x20), mload(data), 0, 0)
        }
    }
    function getAddressBySymbol(string memory _symbol) public view returns (address) {
        
        uint256 _tokenId = symbolAndEmojiLookupTable[_symbol];
        return tokenListByBaseId[_tokenId >> 128];
    }
    function getTotalSupply(uint256 _tokenId) public view  returns(uint256){
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        return managedTokenListByAddress[_tokenAddr].totalSupply;
    }
    
    function getSymbol(uint256 _tokenId) public view  returns(string memory){
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        return managedTokenListByAddress[_tokenAddr].symbol;
    }
    function setSymbol(uint256 _tokenId, string memory _symbol) public onlyAdmin {
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        managedTokenListByAddress[_tokenAddr].symbol = _symbol;
        symbolAndEmojiLookupTable[_symbol] = _tokenId;
    }
    function getEmoji(uint256 _tokenId) public view  returns(string memory){
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        return managedTokenListByAddress[_tokenAddr].emoji;
    }
    function setEmoji(uint256 _tokenId, string memory _emoji) public onlyAdmin {
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        managedTokenListByAddress[_tokenAddr].emoji = _emoji;
        symbolAndEmojiLookupTable[_emoji] = _tokenId;
    }
    
    function getERCtype(uint256 _tokenId) public view  returns(uint){
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        return managedTokenListByAddress[_tokenAddr].ercType;
    }
    
    function getNextBaseId(uint256 _tokenId) public pure returns(uint256){
        return ((_tokenId >> 128) + 1) << 128;
    }
    //for adjusting incoming human-typed values to smart contract uint values
    function adjustValueByUnits(uint256 _tokenId, uint256 _value, uint256 _decimalPlace) public view onlyAdmin returns(uint256){
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
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
        
        return _value * 10**(18 - _decimalPlace);
    }
    
    function subtractFromTotalSupply(uint256 _tokenId, uint256 _amount) public onlyAdmin {
        address _tokenAddr = tokenListByBaseId[_tokenId >> 128];
        managedTokenListByAddress[_tokenAddr].totalSupply = managedTokenListByAddress[_tokenAddr].totalSupply - _amount;
    }
    
    function isManagedToken(address _token) public view returns(bool) {
        return managedTokenListByAddress[_token].isManagedToken;
    }
    
    function setIsManagedToken(address _token, bool _state) public onlyAdmin {
        managedTokenListByAddress[_token].isManagedToken = _state;
    }

    function getManagedTokenIdByAddress(address _tokenOriginAddr) public view returns(uint256) {
        //split byte format
        return managedTokenListByAddress[_tokenOriginAddr].managedTokenBaseId << 128;
    }
    
    function getTokenListCount() public view returns(uint count) {
        return tokenListByBaseId.length;
    }
    
    function _addTokenToManagedTokenList(address _token, uint ercType) private onlyAdmin{
        tokenListByBaseId.push(_token);
        
        ManagedToken memory _mngTkn;
        if(ercType == 20 || ercType == 721){
            //need clause for ETH?
            if(address(0) != _token){
                _mngTkn = getERCspecs(_token, ercType);
            }

        } else {
            //assign symbol of erc1155
        }

        _mngTkn.managedTokenBaseId = tokenListByBaseId.length - 1;
        symbolAndEmojiLookupTable[_mngTkn.symbol] = _mngTkn.managedTokenBaseId << 128;
        _mngTkn.isManagedToken = true;
        _mngTkn.ercType = ercType;
        
        managedTokenListByAddress[_token] = _mngTkn;
        emit Token(_mngTkn);
    }
    
    function _mint( address account, uint256 id, uint256 amount, bytes memory data) private {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.mint(account, id, amount, data);
    }
    
    function _burn( address account, uint256 id, uint256 amount) private {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.burn(account, id, amount);
    }
    
    /*****************************tokenId mgmt*************************
     * 
     * 
     * 
     */
    
    function managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data)  public onlyAdmin {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.safeTransferFrom(_from, _to, _id, _val, _data);
    }

    
    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        IDownStream _downstream = IDownStream(getCryptoravesTokenAddress());
        return _downstream.testDownstreamAdminConfiguration();
    }
}
