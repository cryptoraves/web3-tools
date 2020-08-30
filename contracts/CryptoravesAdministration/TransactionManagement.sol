// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./TokenManagement.sol";
import "./UserManagement.sol";

//can manage tokens for any Cryptoraves-native address
contract TransactionManagement is AdministrationContract {
    
    using SafeMath for uint256;
    using Address for address;
    
    address private _tokenManagementContractAddress;
    address private _userManagementContractAddress;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18-decimal adjusted standard amount (1 billion)
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, uint256 _tokenId);
    
    event TokenManagementAddressChange(address _newContractAddr);
    event UserManagementAddressChange(address _newContractAddr);
    event HeresMyAddress(address _layer1Address, address _walletContractAddress);

    constructor(string memory _uri, address _tokenManagementAddr, address _userManagementAddr) public {
        
        //default administrators include parent contract and its owner
        setAdministrator(tx.origin);
        
        //launch child contracts if no address arguments specified
        if (_tokenManagementAddr == address(0)){
            //launch new Cryptoraves Token contract
            TokenManagement _tokenManagement = new TokenManagement(_uri);
            _tokenManagementContractAddress = address(_tokenManagement);
        } else {
            TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
            _tokenManagementContractAddress = address(_tokenManagement);
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
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
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
            UserManagement _userManagement = UserManagement(_userManagementContractAddress);
            address _fromAddress = _userManagement.userAccountCheck(_twitterIds[0], _twitterNames[0], _metaData[2]);
            address _layer1Address = parseAddr(_metaData[3]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');
            _userManagement.mapLayerOneAccount(_fromAddress, _layer1Address);
            
            emit HeresMyAddress(_layer1Address, _fromAddress);
        }
        
        //transfers
        if(keccak256(bytes(_metaData[1])) == keccak256(bytes("transfer"))){
            
            UserManagement _userManagement = UserManagement(_userManagementContractAddress);
            
            require(_userManagement.isUser(_twitterIds[0]), 'Initiating Twitter user is not a Cryptoraves user');
            
            //get addresses
            address _fromAddress = _userManagement.userAccountCheck(_twitterIds[0], _twitterNames[0], _metaData[2]);
            address _toAddress = _userManagement.userAccountCheck(_twitterIds[1], _twitterNames[1], '');
            
            uint256 _tokenId;
            address _userAccount;
            
            TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
            
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
            
            _managedTransfer(_fromAddress, _toAddress, _tokenId, _value, _stringToBytes(_metaData[3]));
        }
    }
    
    function _initCryptoDrop(uint256 _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl) internal returns(address) {
        
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        
        //check if user already dropped
        require(!_userManagement.dropState(_platformUserId), 'User already dropped their crypto.');
        
        //init account
        address _userAddress = _userManagement.userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);
        
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
        
        _tokenManagement.dropCrypto(_twitterHandleFrom, _userAddress, _standardMintAmount, _standardMintAmount, '');
        
        _userManagement.setDropState(_platformUserId, true);
        
        return _userAddress;

    }

    function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {
        
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
        
        address _userAccount = _userManagement.getUserAccount(_platformId);

        require(_userAccount != address(0), 'User account does not exist');

        return _tokenManagement.getManagedTokenIdByAddress(
            _userAccount
        );
    }
    
    function getUserL1AccountFromL2Account(address _l2) public view returns(address) {
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        return _userManagement.getLayerOneAccount(_l2);
    }
    
    function getUserL2AccountFromL1Account(address _l1) public view returns(address) {
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        return _userManagement.getLayerTwoAccount(_l1);
    }
    
    function _managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) internal {
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
        address _cryptoravesTokenAddr = _tokenManagement.getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddr).safeTransferFrom(_from, _to, _id, _val, _data);
        _tokenManagement._checkHeldToken(_to, _id);
        //TODO: emit platformId and change _from & _to vars to userIds and/or handles on given platform
        emit Transfer(_from, _to, _val, _id); 
    }
    
    //End user support features
    function resetTokenDrop(uint256 _platformUserId) public onlyAdmin {
        //reset user's dropState
        UserManagement _userManagement = UserManagement(_userManagementContractAddress);
        _userManagement.setDropState(_platformUserId, false);
        
        address _acct = _userManagement.getUserAccount(_platformUserId);
        
        //reset token
        TokenManagement _tokenManagement = TokenManagement(_tokenManagementContractAddress);
        _tokenManagement.setIsManagedToken(_acct, false);
        
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
