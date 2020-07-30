// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./CryptoravesToken.sol";


//can manage tokens for any Cryptoraves-native address
contract TokenManagement is AdministrationContract {
    
    address private _cryptoravesContractAddress;
    address private _userManagementContractAddress;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18 decimal adjusted standard amount (1 billion)
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _tokenId);
    
    event CryptoravesTokenAddressChange(address _newContractAddr);
    event UserManagementAddressChange(address _newContractAddr);
    event HeresMyAddress(address _layer1Address, address _cryptoravesAddress);

    constructor(string memory _uri, address _cryptoravesTokenAddr, address _userManagementAddr) public {
        
        //default managers include parent contract and ValidatorInterfaceContract Owner
        _administrators[msg.sender] = true;
        _administrators[tx.origin] = true;
        
        if (_cryptoravesTokenAddr == address(0)){
            //launch new Cryptoraves Token contract
            CryptoravesToken _cryptoravesToken = new CryptoravesToken(_uri);
            _cryptoravesContractAddress = address(_cryptoravesToken);
        } else {
            CryptoravesToken _cryptoravesToken = CryptoravesToken(_cryptoravesTokenAddr);
            _cryptoravesContractAddress = address(_cryptoravesToken);
        }
        
        if (_userManagementAddr == address(0)){
            //launch new user management contract contract
            UserManagement _userManagement = new UserManagement();
            _userManagementContractAddress = address(_userManagement);
        } else {
            UserManagement _userManagement = UserManagement(_userManagementAddr);
            _userManagementContractAddress = address(_userManagement);
        }
    }
    
    function getCryptoravesTokenAddress() public view returns(address){
        return _cryptoravesContractAddress;
    } 

    function changeCryptoravesTokenAddress(address _newAddr) public onlyAdmin {
        _cryptoravesContractAddress = _newAddr;
        emit CryptoravesTokenAddressChange(_newAddr);
    } 
    
    function getUserManagementAddress() public view returns(address){
        return _userManagementContractAddress;
    } 

    function changeUserManagementAddress(address _newAddr) public onlyAdmin {
        _userManagementContractAddress = _newAddr;
        emit UserManagementAddressChange(_newAddr); 
    } 
    
     /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterIds [0] = twitterIdFrom, [1] = twitterIdTo, [2] = twitterIdThirdParty
    * @param _twitterNames [0] = twitterHandleFrom, [1] = twitterHandleTo, [2] = thirdPartyName
    * @param _fromImgUrl The Twitter img of initiating user
    * @param _txnType lstring indicating type of transaction:
            "launch" = new toke n launch
            "transfer" =  token transfer
    * @param _value amount or id of token to transfer
    */ 
        
    function initCommand(
        uint256[] memory _twitterIds,
        string[] memory _twitterNames,
        string memory _fromImageUrl,
        string memory _txnType, 
        uint256 _value,
        string memory _data
    ) onlyAdmin public returns(bool){
        
        //launch criteria
        if(keccak256(bytes(_txnType)) == keccak256(bytes("launch"))){
            _initCryptoDrop(_twitterIds[0], _twitterNames[0], _fromImageUrl);
        }
        
        //map layer 1 account
        if(keccak256(bytes(_txnType)) == keccak256(bytes("mapL1Account"))){
            UserManagement _userManagement = UserManagement(_userManagementContractAddress);
            address _fromAddress = _userManagement.userAccountCheck(_twitterIds[0], _twitterNames[0], _fromImageUrl);
            address _layer1Address = parseAddr(_data);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');
            WalletFull(_fromAddress).mapLayerOneAccount(_layer1Address);
            
            emit HeresMyAddress(_layer1Address, _fromAddress);
        }
        
        //transfers
        if(keccak256(bytes(_txnType)) == keccak256(bytes("transfer"))){
            
            UserManagement _userManagement = UserManagement(_userManagementContractAddress);
            
            require(_userManagement.isUser(_twitterIds[0]), 'Initiating Twitter user is not a Cryptoraves user');
            
            //get addresses
            address _fromAddress = _userManagement.userAccountCheck(_twitterIds[0], _twitterNames[0], _fromImageUrl);
            address _toAddress = _userManagement.userAccountCheck(_twitterIds[1], _twitterNames[1], '');
            
            uint256 _tokenId;
            address _userAccount;
            
            CryptoravesToken _cryptoravesToken = CryptoravesToken(_cryptoravesContractAddress);
            
            //transfer type check
            if(_twitterIds[2] == 0){
                
                _userAccount = _userManagement.getUserAccount(_twitterIds[0]);
                
                //check if a ticker is being used
                bytes memory ticker = bytes(_twitterNames[2]); // Uses memory
                
                if (ticker.length != 0) {
                    
                    
                    
                    //get token by ticker name
                    address _addr = _cryptoravesToken.getTickerAddress(_twitterNames[2]);
                    _tokenId = _cryptoravesToken.getManagedTokenIdByAddress(_addr);
                    
                    
                } else {
                    //No third party given, user transfer using thier dropped tokens
                    _tokenId = _cryptoravesToken.getManagedTokenIdByAddress(_userAccount);
                }
                
                
                
            } else {
                
                //user transfer using non-cryptoraves tokens
                _userAccount = _userManagement.getUserAccount(_twitterIds[2]);
                
                require(_userAccount!=address(0), 'Third party token given--with username method--does not exist in system');
                    //not a dropped token attempted to be transferred. Check for 
                _tokenId = _cryptoravesToken.getManagedTokenIdByAddress(_userAccount);
                
            }
            
            _managedTransfer(_fromAddress, _toAddress, _tokenId, _value, _stringToBytes(_data));
        }
    }
    
    function _initCryptoDrop(uint256 _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl) internal returns(address) {
        
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        
        //check if user already dropped
        require(!_userManagement.dropState(_platformUserId), 'User already dropped their crypto.');
        
        //init account
        address _userAddress = _userManagement.userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);
        
        CryptoravesToken _cryptoravesToken = CryptoravesToken(_cryptoravesContractAddress);
        
        _cryptoravesToken.mint(_userAddress, _standardMintAmount, '');
        
        _userManagement.setDropState(_platformUserId);
        
        return _userAddress;
    }

    function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {
        
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        CryptoravesToken _cryptoravesToken = CryptoravesToken(_cryptoravesContractAddress);
        
        address _userAccount = _userManagement.getUserAccount(_platformId);

        require(_userAccount != address(0), 'User account does not exist');

        return _cryptoravesToken.getManagedTokenIdByAddress(
            _userAccount
        );
    }
    
    function _managedTransfer(address _from, address _to, uint256 _tokenId,  uint256 _val, bytes memory _data) internal {
        WalletFull(_from).managedTransfer(_from, _to, _tokenId, _val, _data);
        emit Transfer(_from, _to, _val, _tokenId);
    }
    
    //conversion functions
    function _stringToBytes( string memory s) public pure returns (bytes memory){
        bytes memory b3 = bytes(s);
        return b3;
    }
    function parseAddr(string memory _a) public pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}
