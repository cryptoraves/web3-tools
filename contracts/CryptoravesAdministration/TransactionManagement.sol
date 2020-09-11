// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdministrationContract.sol";

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}

//can manage tokens for any Cryptoraves-native address
contract TransactionManagement is AdministrationContract {
    
    address private _tokenManagementContractAddress;
    address private _userManagementContractAddress;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18-decimal adjusted standard amount (1 billion)
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _tokenId);
    event TokenManagementAddressChange(address _newContractAddr);
    event UserManagementAddressChange(address _newContractAddr);
    event HeresMyAddress(address _layer1Address, address _walletContractAddress);

    constructor(address _tokenManagementAddr, address _userManagementAddr) public {
        
        //default administrator
        setAdministrator(msg.sender);
                
        setTokenManagementAddress(_tokenManagementAddr);
        setUserManagementAddress(_userManagementAddr);
    }
    //unique function for identifying this contract
    function testForTransactionManagementAddressUniquely() public pure returns(bool){
        return true;
    }
    
    function getTokenManagementAddress() public view returns(address) {
        return _tokenManagementContractAddress;
    }

    function setTokenManagementAddress(address _newAddr) public onlyAdmin {
        _tokenManagementContractAddress = _newAddr;
        emit TokenManagementAddressChange(_newAddr);
    } 
    
    function getUserManagementAddress() public view returns(address){
        return _userManagementContractAddress;
    } 

    function setUserManagementAddress(address _newAddr) public onlyAdmin {
        _userManagementContractAddress = _newAddr;
        emit UserManagementAddressChange(_newAddr); 
    } 
    
    function getCryptoravesTokenAddress() public view returns(address){
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        return _tokenManagement.getCryptoravesTokenAddress();
    } 
        
    /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterIds [0] = twitterIdFrom, [1] = twitterIdTo, [2] = twitterIdThirdParty
    * @param _twitterNames [0] = twitterHandleFrom, [1] = twitterHandleTo, [2] = thirdPartyName
    * @param _value amount or id of token to transfer
    * @param _metaData: 
        [0] = _platformName:
            "twitter"
            "instagram
            etc
        [1] = _txnType lstring indicating type of transaction:
                "launch" = new toke n launch
                "transfer" =  token transfer
        [2] = _fromImgUrl The Twitter img of initiating user
        [3] = _data bytes value for ERC721 & 1155 txns
    */ 
    function initCommand(
        uint256[] memory _twitterIds,
        string[] memory _twitterNames,
        uint256 _value,
        string[] memory _metaData
    ) onlyAdmin public returns(bool){
        /* reference
        string memory _platformName = _metaData[0];
        string memory _txnType = _metaData[1];
        string memory _fromImageUrl = _metaData[2];
        string memory _data = _metaData[3];
        */
        
        //launch criteria
        if(keccak256(bytes(_metaData[1])) == keccak256(bytes("launch"))){
            _initCryptoDrop(_twitterIds[0], _twitterNames[0], _metaData[2]);
        }
        
        //map layer 1 account
        if(keccak256(bytes(_metaData[1])) == keccak256(bytes("mapaccount"))){
            IUserManager _userManagement = IUserManager(_userManagementContractAddress);
            address _fromAddress = _userManagement.userAccountCheck(_twitterIds[0], _twitterNames[0], _metaData[2]);
            address _layer1Address = AdminToolsLibrary.parseAddr(_metaData[3]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');
            _userManagement.mapLayerOneAccount(_fromAddress, _layer1Address);
            
            emit HeresMyAddress(_layer1Address, _fromAddress);
        }
        
        //hybrid launch and map
        if(keccak256(bytes(_metaData[1])) == keccak256(bytes("launchAndMap"))){
            address _layer1Address = AdminToolsLibrary.parseAddr(_metaData[3]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');
            
            _initCryptoDrop(_twitterIds[0], _twitterNames[0], _metaData[2]);
            
             IUserManager _userManagement = IUserManager(_userManagementContractAddress);
            address _fromAddress = _userManagement.getUserAccount(_twitterIds[0]);
            _userManagement.mapLayerOneAccount(_fromAddress, _layer1Address);
            
            emit HeresMyAddress(_layer1Address, _fromAddress);
        }
        
        //transfers
        if(keccak256(bytes(_metaData[1])) == keccak256(bytes("transfer"))){
            
            IUserManager _userManagement = IUserManager(_userManagementContractAddress);
            
            require(_userManagement.isUser(_twitterIds[0]), 'Initiating Twitter user is not a Cryptoraves user');
            
            //get addresses
            address _fromAddress = _userManagement.userAccountCheck(_twitterIds[0], _twitterNames[0], _metaData[2]);
            address _toAddress = _userManagement.userAccountCheck(_twitterIds[1], _twitterNames[1], '');
            
            uint256 _tokenId;
            address _userAccount;
            
            ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
            
            //transfer type check
            if(_twitterIds[2] == 0){
                
                _userAccount = _userManagement.getUserAccount(_twitterIds[0]);
                
                //check if a ticker is being used
                bytes memory ticker = bytes(_twitterNames[2]); // Uses memory
                
                if (ticker.length != 0) {
                    
                    
                    
                    //get token by ticker name
                    address _addr = _tokenManagement.getTickerAddress(_twitterNames[2]);
                    _tokenId = _tokenManagement.getManagedTokenIdByAddress(_addr);
                    
                    
                } else {
                    //No third party given, user transfer using thier dropped tokens
                    _tokenId = _tokenManagement.getManagedTokenIdByAddress(_userAccount);
                }
                
                
                
            } else {
                
                //user transfer using non-cryptoraves tokens
                _userAccount = _userManagement.getUserAccount(_twitterIds[2]);
                
                require(_userAccount!=address(0), 'Third party token given--with username method--does not exist in system');
                    //not a dropped token attempted to be transferred. Check for 
                _tokenId = _tokenManagement.getManagedTokenIdByAddress(_userAccount);
                
            }
            
            _managedTransfer(_fromAddress, _toAddress, _tokenId, _value, AdminToolsLibrary.stringToBytes(_metaData[3]));
        }
    }
    
    function _initCryptoDrop(uint256 _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl) internal returns(address) {
        
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        
        //check if user already dropped
        require(!_userManagement.dropState(_platformUserId), 'User already dropped their crypto.');
        
        //init account
        address _userAddress = _userManagement.userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);
        
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        
        _tokenManagement.dropCrypto(_twitterHandleFrom, _userAddress, _standardMintAmount, _standardMintAmount, '');
        
        _userManagement.setDropState(_platformUserId, true);
        
        return _userAddress;

    }

    function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {
        
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        
        address _userAccount = _userManagement.getUserAccount(_platformId);

        require(_userAccount != address(0), 'User account does not exist');

        return _tokenManagement.getManagedTokenIdByAddress(
            _userAccount
        );
    }
    
    function getUserL1AccountFromL2Account(address _l2) public view returns(address) {
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        return _userManagement.getLayerOneAccount(_l2);
    }
    
    function getUserL2AccountFromL1Account(address _l1) public view returns(address) {
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        return _userManagement.getLayerTwoAccount(_l1);
    }
    
    function _managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) internal {
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        address _cryptoravesTokenAddr = _tokenManagement.getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddr).safeTransferFrom(_from, _to, _id, _val, _data);
        _tokenManagement._checkHeldToken(_to, _id);
        //TODO: emit platformId and change _from & _to vars to userIds and/or handles on given platform
        emit Transfer(_from, _to, _val, _id); 
    }
    
    //End user support features
    function resetTokenDrop(uint256 _platformUserId) public onlyAdmin {
        //reset user's dropState
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        _userManagement.setDropState(_platformUserId, false);
        
        address _acct = _userManagement.getUserAccount(_platformUserId);
        
        //reset token
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        _tokenManagement.setIsManagedToken(_acct, false);
        
    }
}
