// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdministrationContract.sol";
import "/home/cartosys/openzeppelin-contracts/contracts/cryptography/ECDSA.sol";

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}

//manages all transactions coming in from social media
contract TransactionManagement is AdministrationContract {
    using ECDSA for bytes32;
    
    address private _tokenManagementContractAddress;
    address private _userManagementContractAddress;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18-decimal adjusted standard amount (1 billion)
    
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
    * @param _values 
        [0] amount or id of token to transfer -- integers of any decimal value. eg 1.31 = 131, 12321.989293 = 12321989293, 1000 = 1000 etc
        [1] where the decimal place lies: 1.31 = 2, 12321.989293 = 6, 1000 = 0 etc
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
        uint256[] memory _values,
        string[] memory _metaData
    ) onlyAdmin public returns(bool){
        /* reference
        string memory _platformName = _metaData[0];
        string memory _txnType = _metaData[1];
        string memory _fromImageUrl = _metaData[2];
        string memory _data = _metaData[3];
        */
        
        /*
        * L1 signerd transaction proxy
        * redefined params for this function:
        * @param _twitterNames[0] = ERCxxx contract of signed function. Approve = ERC20/721 deposit/ withdraw = ERC1155
        * @param _metadata[1] = calldata generated from website
        * @param _twitterNames[1] = data hash
        * @param _twitterNames[2] = signed meta tx signature
        * 
        */
        if(keccak256(bytes(_metaData[1])) == keccak256(bytes("proxy"))){
            bytes memory _addrBytes = bytes(_twitterNames[0]);
            address _addr = _bytesToAddress(_addrBytes);
            
            bytes memory _data = bytes(_twitterNames[1]); //was calldata
            _forward(_addr, _data, bytes(_twitterNames[2]));
        }
        
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
                    address _addr = _tokenManagement.getAddressBySymbol(_twitterNames[2]);
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
            
            uint256 _adjustedValue;
            
            //nft id adjustment
            if(_tokenManagement.getERCtype(_tokenId) == 721){
                _tokenId = _tokenId + _values[0];
                _adjustedValue = 1;
            }else{
                _adjustedValue = _adjustValueByUnits(_tokenId, _values[0], _values[1]);
            }

            bytes memory mData = AdminToolsLibrary.stringToBytes(_metaData[3]);
            _tokenManagement.managedTransfer(_fromAddress, _toAddress, _tokenId, _adjustedValue, mData);
        }
    }
    
    // verify the Layer1 signed data and execute the data on L2 
    // @param _to = ERC20/721 address
    function _forward(address _to, bytes memory _data, bytes memory _signature) private returns (bytes memory _result) {
        bool success;
        
        require(_to != address(0), "invalid target address");
        bytes memory payload = abi.encode(_to, _data);
        address signerAddress = keccak256(payload).toEthSignedMessageHash().recover(_signature);

        //ensure user's address is registered        
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        require(_userManagement.getLayerTwoAccount(signerAddress) != address(0), "Offline Transaction Signer Not Registered");

        
        (success, _result) = _to.call(_data);
        if (!success) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
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

        return _tokenManagement.getManagedTokenIdByAddress(_userAccount);
    }
    
    function getUserL1AccountFromL2Account(address _l2) public view returns(address) {
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        return _userManagement.getLayerOneAccount(_l2);
    }
    
    function getUserL2AccountFromL1Account(address _l1) public view returns(address) {
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        return _userManagement.getLayerTwoAccount(_l1);
    }
    
    
    
    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        IDownStream _downstream1 = IDownStream(getTokenManagementAddress());
        bool test1 = _downstream1.testDownstreamAdminConfiguration();
        IDownStream _downstream2 = IDownStream(getUserManagementAddress());
        bool test2 = _downstream2.testDownstreamAdminConfiguration();
        
        return test1 && test2;
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
    
    function _adjustValueByUnits(uint256 _tokenId, uint256 _value, uint256 _decimalPlace) private view returns(uint256){
        //check if nft. if yes, return same _value
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        return _tokenManagement.adjustValueByUnits(_tokenId, _value, _decimalPlace);
        
                
    }
    
    function _bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
          addr := mload(add(bys,20))
        } 
    }
}
