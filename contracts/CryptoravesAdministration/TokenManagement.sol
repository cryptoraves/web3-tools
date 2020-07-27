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
    
    event CryptoDropped(address user, uint256 tokenId);
    event CryptoravesTokenAddressChange(address _newContractAddr);
    event UserManagementAddressChange(address _newContractAddr);

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
            //launch new Cryptoraves Token contract
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
    ) onlyAdmin public returns(bool){
        
        //launch criteria
        if(_isLaunch){
            _initCryptoDrop(_twitterIds[0], _twitterNames[0], _fromImageUrl);
        }else{
            
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
            
            _managedTransfer(_fromAddress, _toAddress, _tokenId, _value, _data);
        }
    }
    
    function _initCryptoDrop(uint256 _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl) internal returns(address) {
        
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        
        //check if user already dropped
        require(!_userManagement.dropState(_platformUserId), 'User already dropped their crypto.');
        
        //init account
        address _userAddress = _userManagement.userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);
        
        CryptoravesToken _cryptoravesToken = CryptoravesToken(_cryptoravesContractAddress);
        
        uint256 _tokenId = _cryptoravesToken.getManagedTokenIdByAddress(_userAddress);
        
        _cryptoravesToken.mint(_userAddress, _tokenId, _standardMintAmount, '');
        
        _userManagement.setDropState(_platformUserId);
        
        emit CryptoDropped(_userAddress, _tokenId);
        
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
}
