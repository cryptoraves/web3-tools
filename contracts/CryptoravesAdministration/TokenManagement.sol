// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./ERCDepositable.sol";
import "./CryptoravesToken.sol";

contract TokenManagement is  ERCDepositable {

    using SafeMath for uint256;
    using Address for address;

    address private _cryptoravesTokenAddr;

    //Bytes-based token ID scheme
    uint256 numberOfTokens = 0;
    mapping(uint256 =>address) public tokenAddressByFullBytesId;
    mapping(address =>uint256) public tokenBaseBytesIdByAddress;

    mapping(uint256 => ManagedToken) public managedTokenByFullBytesId;

    //find tokenId by symbol or emoji
    mapping(string => uint256) public symbolAndEmojiLookupTable;

    event Deposit(address indexed _to, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId, uint _ercType);
    event Withdraw(address indexed _from, uint256 _value, address indexed _token, uint256 indexed cryptoravesTokenId, uint _ercType);
    event Token(ManagedToken);
    event Emoji(uint256 cryptoravesTokenId, string _emoji);
    event CryptoDropped(address user, uint256 tokenId);

    constructor(string memory _uri) public {

        setAdministrator(msg.sender);
        CryptoravesToken newCryptoravesToken = new CryptoravesToken(_uri);
        _cryptoravesTokenAddr = address(newCryptoravesToken);

        //must add fake token to zero spot
        tokenAddressByFullBytesId[numberOfTokens] = address(this);
        numberOfTokens++;
        //_addTokenToManagedTokenList(address(this), 1155, 0);
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

        if(!managedTokenByFullBytesId[tokenBaseBytesIdByAddress[account]].isManagedToken) {
            _addTokenToManagedTokenList(account, 1155, 0);
        }

        uint256 _1155tokenId = getManagedTokenBasedBytesIdByAddress(account);

        //add username as symbol
        _checkSymbolAddress(_twitterHandleFrom, _1155tokenId);

        _mint(account, _1155tokenId, amount, data);

        managedTokenByFullBytesId[tokenBaseBytesIdByAddress[account]].symbol = _twitterHandleFrom;
        symbolAndEmojiLookupTable[_twitterHandleFrom] = _1155tokenId;

        emit CryptoDropped(account, _1155tokenId);

    }

    function _checkSymbolAddress(string memory _sym, uint256 _tokenBaseBytesId) internal {
        //only adds ticker if not yet taken
        if(symbolAndEmojiLookupTable[_sym] == 0){
            symbolAndEmojiLookupTable[_sym] = _tokenBaseBytesId;
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

    function deposit(uint256 _amountOrId, address _tokenAddr, uint _ercType, bool _managedTransfer) public payable returns(uint256){

        if(!managedTokenByFullBytesId[tokenBaseBytesIdByAddress[_tokenAddr]].isManagedToken) {
            if( _ercType == 721 ){
                _addTokenToManagedTokenList(_tokenAddr, _ercType, _amountOrId);
            }else{
                _addTokenToManagedTokenList(_tokenAddr, _ercType, 0);
            }

        }

        uint256 _1155tokenId;
        _1155tokenId = getManagedTokenBasedBytesIdByAddress(_tokenAddr);

        address _mintTo;
        if(_managedTransfer){
            _mintTo = getL2AddressForManagedDeposit();
        } else {
            _mintTo = msg.sender;
        }

        uint256 _amount;
        if(_ercType == 20){
            _depositERC20(_amountOrId, _tokenAddr);
            _amount = _amountOrId;

        }
        if(_ercType == 721){
            _1155tokenId = _1155tokenId + _amountOrId;
            _depositERC721(_amountOrId, _tokenAddr);
            _amount = 1;
        }


        _mint(_mintTo, _1155tokenId, _amount, '');

        emit Deposit(_mintTo, _amountOrId, _tokenAddr, _1155tokenId, _ercType);

        return _1155tokenId;
    }


    function withdrawERC20(uint256 _amount, address _tokenAddr, bool _isManagedWithdraw) public payable returns(uint256){
        _withdrawERC20(_amount, _tokenAddr);

        uint256 _1155tokenId = getManagedTokenBasedBytesIdByAddress(_tokenAddr);
        address _burnAddr;
        if (_isManagedWithdraw) {
            _burnAddr = getL2AddressForManagedDeposit();
        } else {
            _burnAddr = msg.sender;
        }

        _burn(_burnAddr, _1155tokenId, _amount);
        emit Withdraw(_burnAddr, _amount, _tokenAddr, _1155tokenId, 20);

        return _1155tokenId;

    }

    function withdrawERC721(uint256 _tokenERC721Id, address _tokenAddr, bool _isManagedWithdraw) public payable returns(uint256){
        _withdrawERC721(_tokenERC721Id, _tokenAddr);

        uint256 _1155tokenId = getManagedTokenBasedBytesIdByAddress(_tokenAddr) + _tokenERC721Id;
        address _burnFromAddr;
        if (_isManagedWithdraw) {
            _burnFromAddr = getL2AddressForManagedDeposit();
        } else {
            _burnFromAddr = msg.sender;
        }

        _burn(_burnFromAddr, _1155tokenId, 1);
        emit Withdraw(msg.sender, _tokenERC721Id, _tokenAddr, _1155tokenId, 721);

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

        uint256 _1155tokenBaseBytesId = symbolAndEmojiLookupTable[_symbol];
        return tokenAddressByFullBytesId[_1155tokenBaseBytesId];
    }
    function getTotalSupply(uint256 _1155tokenId) public view  returns(uint256){
        return managedTokenByFullBytesId[_1155tokenId].totalSupply;
    }

    function getSymbol(uint256 _1155tokenId) public view  returns(string memory){
        return managedTokenByFullBytesId[_1155tokenId].symbol;
    }
    function setSymbol(uint256 _1155tokenId, string memory _symbol) public onlyAdmin {
        managedTokenByFullBytesId[_1155tokenId].symbol = _symbol;
        symbolAndEmojiLookupTable[_symbol] = _1155tokenId;
    }
    function getEmoji(uint256 _1155tokenId) public view  returns(string memory){
        return managedTokenByFullBytesId[_1155tokenId].emoji;
    }
    function setEmoji(uint256 _1155tokenId, string memory _emoji) public onlyAdmin {
        require(managedTokenByFullBytesId[_1155tokenId].ercType != 721, "Cannot set emoji for NFTs");
        managedTokenByFullBytesId[_1155tokenId].emoji = _emoji;
        symbolAndEmojiLookupTable[_emoji] = _1155tokenId;
        emit Emoji(_1155tokenId, _emoji);
    }

    function getERCtype(uint256 _1155tokenId) public view  returns(uint){
        return managedTokenByFullBytesId[_1155tokenId].ercType;
    }

    function getNextBaseId(uint256 _1155tokenId) public pure returns(uint256){
        return ((_1155tokenId >> 128) + 1) << 128;
    }
    //for adjusting incoming human-typed values to smart contract uint values
    function adjustValueByUnits(uint256 _1155tokenId, uint256 _value, uint256 _decimalPlace) public view onlyAdmin returns(uint256){
        address _tokenAddr = tokenAddressByFullBytesId[_1155tokenId];
        ManagedToken memory _tknData = managedTokenByFullBytesId[_1155tokenId];
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

    function subtractFromTotalSupply(uint256 _1155tokenId, uint256 _amount) public onlyAdmin {
        managedTokenByFullBytesId[_1155tokenId].totalSupply = managedTokenByFullBytesId[_1155tokenId].totalSupply - _amount;
    }

    function isManagedToken(address _tokenAddr) public view returns(bool) {
        return managedTokenByFullBytesId[tokenBaseBytesIdByAddress[_tokenAddr]].isManagedToken;
    }

    function setIsManagedToken(address _tokenAddr, bool _state) public onlyAdmin {
        managedTokenByFullBytesId[tokenBaseBytesIdByAddress[_tokenAddr]].isManagedToken = _state;
    }

    function getManagedTokenBasedBytesIdByAddress(address _tokenAddr) public view returns(uint256) {
        //split byte format
        return tokenBaseBytesIdByAddress[_tokenAddr];
    }

    function getTokenListCount() public view returns(uint count) {
        return numberOfTokens;
    }

    function _addTokenToManagedTokenList(address _tokenAddr, uint ercType, uint256 _erc721Id) private onlyAdmin{
        uint baseBytesId = numberOfTokens << 128;
        uint256 fullBytesId = baseBytesId + _erc721Id;

        tokenAddressByFullBytesId[fullBytesId] = _tokenAddr;


        ManagedToken memory _mngTkn;
        if(ercType == 20 || ercType == 721){
            //need clause for ETH?
            if(address(0) != _tokenAddr){
                _mngTkn = getERCspecs(_tokenAddr, ercType);
            }
            if(ercType == 721){
                //get baseUrl
                IERCuni _tkn = IERCuni(_tokenAddr);
                _mngTkn.tokenBrandImageUrl = _tkn.tokenURI(_erc721Id);
            }
        } else {
            //assign symbol of erc1155
        }
        _mngTkn.managedTokenBaseId = baseBytesId;
        //safety when dealing with ERC721's:
        if (tokenBaseBytesIdByAddress[_tokenAddr] == 0){
          tokenBaseBytesIdByAddress[_tokenAddr] = baseBytesId;
        }
        symbolAndEmojiLookupTable[_mngTkn.symbol] = baseBytesId;
        _mngTkn.isManagedToken = true;
        _mngTkn.ercType = ercType;

        _mngTkn.cryptoravesTokenId = fullBytesId;

        managedTokenByFullBytesId[fullBytesId] = _mngTkn;
        emit Token(_mngTkn);

        numberOfTokens++;
    }

    function _mint( address account, uint256 _1155tokenId, uint256 amount, bytes memory data) private {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.mint(account, _1155tokenId, amount, data);
    }

    function _burn( address account, uint256 _1155tokenId, uint256 amount) private {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.burn(account, _1155tokenId, amount);
    }

    /*****************************tokenId mgmt*************************
     *
     *
     *
     */

    function managedTransfer(address _from, address _to, uint256 _1155tokenId,  uint256 _val, bytes memory _data)  public onlyAdmin {
        CryptoravesToken instanceCryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
        instanceCryptoravesToken.safeTransferFrom(_from, _to, _1155tokenId, _val, _data);
    }


    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        IDownStream _downstream = IDownStream(getCryptoravesTokenAddress());
        return _downstream.testDownstreamAdminConfiguration();
    }
}
