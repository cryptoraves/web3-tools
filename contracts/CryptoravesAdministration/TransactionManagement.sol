// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdministrationContract.sol";

interface IERC1155 {
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
}

//manages all transactions coming in from social media
contract TransactionManagement is AdministrationContract {
    struct TwitterInts {
        uint256 twitterIdFrom;
        uint256 twitterIdTo;
        uint256 twitterIdThirdParty;
        uint256 amountOrId;             //amount or original id of token to transfer -- integers of any decimal value. eg 1.31 = 131, 12321.989293 = 12321989293, 1000 = 1000 etc
        uint256 decimalPlaceLocation;   //where the decimal place lies: 1.31 = 2, 12321.989293 = 6, 1000 = 0 etc
        uint256 tweetId;                //tweet ID from twitter
    }
    address private _tokenManagementContractAddress;
    address private _userManagementContractAddress;
    uint256 private _standardMintAmount = 1000000000000000000000000000; //18-decimal adjusted standard amount (1 billion)

    event Transfer(address _from, address _to, uint256 _value, uint256 _cryptoravesTokenId, uint256 _tweetId);
    event HeresMyAddress(address _layer1Address, address _cryptoravesAddress, uint256 _tweetId);

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
    }

    function getUserManagementAddress() public view returns(address){
        return _userManagementContractAddress;
    }

    function setUserManagementAddress(address _newAddr) public onlyAdmin {
        _userManagementContractAddress = _newAddr;
    }

    function getCryptoravesTokenAddress() public view returns(address){
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        return _tokenManagement.getCryptoravesTokenAddress();
    }

    /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterInts - see struct twitterInts
    * @param _twitterStrings [0] = twitterHandleFrom, [1] = twitterHandleTo, [2] = ticker
        [3] = _platformName:
            "twitter"
            "instagram
            etc
        [4] = _txnType lstring indicating type of transaction:
                "launch" = new toke n launch
                "transfer" =  token transfer
        [5] = _fromImgUrl The Twitter img of initiating user
        [6] = map account L1 Address

    * @param _metaData:
        [0] = _data bytes value for ERC721 & 1155 txns
    * @param _functionData = proxy function calldata. Calldata type must be defined in function params
    */
    function initCommand(
        TwitterInts memory _twitterInts,
        string[] memory _twitterStrings,
        bytes[] memory _metaData,
        bytes calldata _functionData
    ) onlyAdmin public returns(bool){
        /* reference
        string memory _platformName = _twitterStrings[3];
        string memory _txnType = _twitterStrings[4];
        string memory _fromImageUrl = _twitterStrings[5];
        string memory _data = _metaData[0];
        */

        address _addr;
        require(_twitterInts.tweetId > 0, "Tweet ID invalid.");

        /*
        * L1 signerd transaction proxy
        * redefined params for this function:
        * @param _twitterStrings[0] = ERCxxx contract of signed function. Approve = ERC20/721 deposit/ withdraw = ERC1155
        * @param _twitterStrings[4] = 'proxy'
        * @param _twitterStrings[1] = calldata generated from website
        * @param _twitterStrings[2] = signed meta tx signature
        *
        */
        if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("proxy"))){

            _addr = _bytesToAddress(_metaData[1]);
             _forward(_addr, _functionData, _metaData[0]);
        }

        //launch criteria
        if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("launch"))){
            _initCryptoDrop(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[5]);
        }

        //map layer 1 account
        if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("mapaccount"))){
            IUserManager _userManagement = IUserManager(_userManagementContractAddress);
            IUserManager.User memory _userFrom = _userManagement.userAccountCheck(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[5]);
            address _layer1Address = AdminToolsLibrary.parseAddr(_twitterStrings[6]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');
            _userManagement.mapLayerOneAccount(_userFrom.cryptoravesAddress, _layer1Address);

            emit HeresMyAddress(_layer1Address, _userFrom.cryptoravesAddress, _twitterInts.tweetId);
        }

        //hybrid launch and map
        if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("launchAndMap"))){
            address _layer1Address = AdminToolsLibrary.parseAddr(_twitterStrings[6]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');

            _initCryptoDrop(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[3]);

             IUserManager _userManagement = IUserManager(_userManagementContractAddress);
            address _userFrom = _userManagement.getUserAccount(_twitterInts.twitterIdFrom);
            _userManagement.mapLayerOneAccount(_userFrom, _layer1Address);

            emit HeresMyAddress(_layer1Address, _userFrom,_twitterInts.tweetId);
        }

        //transfers
        if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("transfer"))){

            IUserManager _userManagement = IUserManager(_userManagementContractAddress);

            require(_userManagement.isUser(_twitterInts.twitterIdFrom), 'Initiating Twitter user is not a Cryptoraves user');

            //get addresses
            IUserManager.User memory _userFrom = _userManagement.userAccountCheck(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[5]);
            IUserManager.User memory _userTo = _userManagement.userAccountCheck(_twitterInts.twitterIdTo, _twitterStrings[1], '');

            IUserManager.User memory _userStruct;

            ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);

            //transfer type check
            if(_twitterInts.twitterIdThirdParty == 0){

                _userStruct = _userManagement.getUserStruct(_twitterInts.twitterIdFrom);

                //check if a ticker is being used
                bytes memory ticker = bytes(_twitterStrings[2]); // Uses memory

                if (ticker.length != 0) {

                    //get token by ticker name
                    _addr = _tokenManagement.getAddressBySymbol(_twitterStrings[2]);

                } else {
                    //No third party given, user transfer using thier dropped tokens
                    _addr = _userStruct.cryptoravesAddress;
                }

            } else {

                //user transfer using non-cryptoraves tokens
                _userStruct = _userManagement.getUserStruct(_twitterInts.twitterIdThirdParty);

                require(_userStruct.cryptoravesAddress!=address(0), 'Third party token given--with platform user id method--does not exist in system');
                    //not a dropped token attempted to be transferred. Check for
                _addr = _userStruct.cryptoravesAddress;

            }

            uint256 _cryptoravesTokenId = _tokenManagement.getManagedTokenBasedBytesIdByAddress(_addr);

            uint256 _adjustedValue;

            //nft id adjustment
            if(_tokenManagement.getERCtype(_cryptoravesTokenId) == 721){
                _cryptoravesTokenId = _cryptoravesTokenId;
                _adjustedValue = 1;
            }else{
                uint256 _dec = _twitterInts.decimalPlaceLocation;
                uint256 _amt = _twitterInts.amountOrId;
                _adjustedValue = _adjustValueByUnits(_cryptoravesTokenId, _amt, _dec );
            }

            bytes memory mData = _metaData[0];
            _tokenManagement.managedTransfer(_userFrom.cryptoravesAddress, _userTo.cryptoravesAddress, _cryptoravesTokenId, _adjustedValue, mData);

            //TODO: emit platformId and change _from & _to vars to userIds and/or handles on given platform
            uint256 _tweetId = _twitterInts.tweetId;
            emit Transfer(_userFrom.cryptoravesAddress, _userTo.cryptoravesAddress, _adjustedValue, _cryptoravesTokenId, _tweetId);
        }
    }

    // verify the Layer1 signed data and execute the data on L2
    // @param _to = ERC20/721 address
    function _forward(address _to, bytes calldata _data, bytes memory _signature) private returns (bytes memory _result) {
        bool success;

        require(_to != address(0), "invalid target address");
        bytes memory payload = abi.encode(_to, _data);

        address signerAddress = _recoverSignerAddress(
            _toEthSignedMessageHash(
                keccak256(payload)
            ),
            _signature
        );

        //ensure user's address is registered
        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        require(_userManagement.getLayerTwoAccount(signerAddress) != address(0), "Offline Transaction Signer Not Registered on Cryptoraves");


        (success, _result) = _to.call(_data);
        if (!success) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }
    //next two functions from https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v3.3/contracts/cryptography/ECDSA.sol
    function _recoverSignerAddress(bytes32 hash, bytes memory signature) private pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // EIP-2 still allows signature malleability for ecrecover(). Remove this possibility and make the signature
        // unique. Appendix F in the Ethereum Yellow paper (https://ethereum.github.io/yellowpaper/paper.pdf), defines
        // the valid range for s in (281): 0 < s < secp256k1n ÷ 2 + 1, and for v in (282): v ∈ {27, 28}. Most
        // signatures from current libraries generate a unique signature with an s-value in the lower half order.
        //
        // If your library generates malleable signatures, such as s-values in the upper range, calculate a new s-value
        // with 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 - s1 and flip v from 27 to 28 or
        // vice versa. If your library also generates signatures with 0/1 for v instead 27/28, add 27 to v to accept
        // these malleable signatures as well.
        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        if (v < 27) {
          v += 27;
        }
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        // If the signature is valid (and not malleable), return the signer address
        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }
    function _toEthSignedMessageHash(bytes32 hash) private pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function _initCryptoDrop(uint256 _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl) internal returns(address) {

        IUserManager _userManagement = IUserManager(_userManagementContractAddress);

        //check if user already dropped
        require(!_userManagement.dropState(_platformUserId), 'User already dropped their crypto.');

        //init account
        IUserManager.User memory _user = _userManagement.userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);

        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);

        _tokenManagement.dropCrypto(_twitterHandleFrom, _user.cryptoravesAddress, _standardMintAmount, '');

        _userManagement.setDropState(_platformUserId, true);

        return _user.cryptoravesAddress;

    }

    function getTokenIdFromPlatformId(uint256 _platformId) public view returns(uint256) {

        IUserManager _userManagement = IUserManager(_userManagementContractAddress);
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);

        address _userAccount = _userManagement.getUserAccount(_platformId);

        require(_userAccount != address(0), 'User account does not exist');

        return _tokenManagement.getManagedTokenBasedBytesIdByAddress(_userAccount);
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

    function _adjustValueByUnits(uint256 _cryptoravesTokenId, uint256 _value, uint256 _decimalPlace) private view returns(uint256){
        //check if nft. if yes, return same _value
        ITokenManager _tokenManagement = ITokenManager(_tokenManagementContractAddress);
        return _tokenManagement.adjustValueByUnits(_cryptoravesTokenId, _value, _decimalPlace);


    }

    function _bytesToAddress(bytes memory bys) private pure returns (address addr) {
        assembly {
          addr := mload(add(bys,20))
        }
    }
}
