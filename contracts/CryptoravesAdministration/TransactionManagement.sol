// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdministrationContract.sol";

//manages all transactions coming in from social media
contract TransactionManagement is AdministrationContract {

    struct TwitterInts {
        uint twitterIdFrom;
        uint twitterIdTo;
        uint twitterIdThirdParty;
        uint amountOrId;             //amount or original id of token to transfer -- integers of any decimal value. eg 1.31 = 131, 12321.989293 = 12321989293, 1000 = 1000 etc
        uint decimalPlaceLocation;   //where the decimal place lies: 1.31 = 2, 12321.989293 = 6, 1000 = 0 etc
        uint tweetId;                //tweet ID from twitter
    }

    address public tokenManagementContractAddress;
    address public userManagementContractAddress;

    constructor(address _tokenManagementAddr, address _userManagementAddr) public {

        //default administrator
        setAdministrator(msg.sender);

        setTokenManagementAddress(_tokenManagementAddr);
        setUserManagementAddress(_userManagementAddr);

    }
    //unique function for identifying this contract
    function testFortransactionManagerAddressUniquely() public pure returns(bool){
        return true;
    }

    function setTokenManagementAddress(address _newAddr) public onlyAdmin {
        tokenManagementContractAddress = _newAddr;
    }

    function setUserManagementAddress(address _newAddr) public onlyAdmin {
        userManagementContractAddress = _newAddr;
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
    */
    function initCommand(TwitterInts memory _twitterInts, string[] memory _twitterStrings) onlyAdmin public returns(bool){

        address _addr;
        require(_twitterInts.tweetId > 0, "Tweet ID invalid.");

        //launch criteria
        if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("launch"))){
            _initCryptoDrop(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[5], _twitterInts.tweetId);
        }

        //map layer 1 account
        else if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("mapaccount"))){
            IUserManager _userManagement = IUserManager(userManagementContractAddress);
            IUserManager.User memory _userFrom = _userManagement.userAccountCheck(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[5]);
            address _layer1Address = AdminToolsLibrary.parseAddr(_twitterStrings[6]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');
            _userManagement.mapLayerOneAccount(_userFrom.cryptoravesAddress, _layer1Address, _twitterInts.tweetId);
        }

        //hybrid launch and map
        else if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("launchAndMap"))){
            address _layer1Address = AdminToolsLibrary.parseAddr(_twitterStrings[6]);
            require(_layer1Address != address(0), 'Invalid address given for L1 account mapping');

            _initCryptoDrop(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[3], _twitterInts.tweetId);

             IUserManager _userManagement = IUserManager(userManagementContractAddress);
            address _userFrom = _userManagement.getUserAccount(_twitterInts.twitterIdFrom);
            _userManagement.mapLayerOneAccount(_userFrom, _layer1Address, _twitterInts.tweetId);
        }

        //transfers
        else if(keccak256(bytes(_twitterStrings[4])) == keccak256(bytes("transfer"))){

            IUserManager _userManagement = IUserManager(userManagementContractAddress);

            require(_userManagement.isUser(_twitterInts.twitterIdFrom), 'Initiating Twitter user is not a Cryptoraves user');

            //get addresses
            IUserManager.User memory _userFrom = _userManagement.userAccountCheck(_twitterInts.twitterIdFrom, _twitterStrings[0], _twitterStrings[5]);
            IUserManager.User memory _userTo = _userManagement.userAccountCheck(_twitterInts.twitterIdTo, _twitterStrings[1], '');

            IUserManager.User memory _userStruct;

            ITokenManager _tokenManagement = ITokenManager(tokenManagementContractAddress);

            //transfer type check
            if(_twitterInts.twitterIdThirdParty == 0){

                _userStruct = _userManagement.getUserStruct(_twitterInts.twitterIdFrom);

                //check if a ticker is being used
                bytes memory ticker = bytes(_twitterStrings[2]); // Uses memory

                if (ticker.length != 0) {
                    //get token by ticker name
                    _addr = _tokenManagement.getAddressBySymbol(_twitterStrings[2]);

                } else {
                    //No third party given, user transfer using their dropped tokens
                    _addr = _userStruct.cryptoravesAddress;
                }

            } else {

                //user transfer using non-cryptoraves tokens
                _userStruct = _userManagement.getUserStruct(_twitterInts.twitterIdThirdParty);

                require(_userStruct.cryptoravesAddress!=address(0), 'Third party token given--with platform user id method--does not exist in system');
                    //not a dropped token attempted to be transferred. Check for
                _addr = _userStruct.cryptoravesAddress;

            }

            require(_addr != address(0), 'Attempt to send a token not deposited into Cryptoraves');
            uint _cryptoravesTokenId = _tokenManagement.cryptoravesIdByAddress(_addr);
            uint _adjustedValue;

            //nft id adjustment
            if(_tokenManagement.getTokenStruct(_cryptoravesTokenId).ercType == 721){
                _cryptoravesTokenId = _cryptoravesTokenId + _twitterInts.amountOrId;
                _adjustedValue = 1;
            }else{

                uint _dec = _twitterInts.decimalPlaceLocation;
                uint _amt = _twitterInts.amountOrId;
                _adjustedValue = _tokenManagement.adjustValueByUnits(_cryptoravesTokenId, _amt, _dec );
            }
            bytes memory bytesTweetId = abi.encodePacked(_twitterInts.tweetId);
            _tokenManagement.managedTransfer(_userFrom.cryptoravesAddress, _userTo.cryptoravesAddress, _cryptoravesTokenId, _adjustedValue, bytesTweetId);

        } else {
          revert("Invalid transaction type provided");
        }
    }

    function _initCryptoDrop(uint _platformUserId, string memory _twitterHandleFrom, string memory _imageUrl, uint _tweetId) internal returns(address) {

        IUserManager _userManagement = IUserManager(userManagementContractAddress);

        //check if user already dropped
        require(!_userManagement.dropState(_platformUserId), 'User already dropped their crypto.');

        //init account
        IUserManager.User memory _user = _userManagement.userAccountCheck(_platformUserId,_twitterHandleFrom,_imageUrl);

        ITokenManager _tokenManagement = ITokenManager(tokenManagementContractAddress);

        _tokenManagement.dropCrypto(_twitterHandleFrom, _user.cryptoravesAddress, 0, abi.encodePacked(_tweetId));

        _userManagement.setDropState(_platformUserId, true);

        return _user.cryptoravesAddress;

    }

    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        IDownStream _downstream1 = IDownStream(tokenManagementContractAddress);
        bool test1 = _downstream1.testDownstreamAdminConfiguration();
        IDownStream _downstream2 = IDownStream(userManagementContractAddress);
        bool test2 = _downstream2.testDownstreamAdminConfiguration();

        return test1 && test2;
    }

    //End user support features
    function resetTokenDrop(uint _platformUserId) public onlyAdmin {
        //reset user's dropState
        IUserManager _userManagement = IUserManager(userManagementContractAddress);
        _userManagement.setDropState(_platformUserId, false);

        address _acct = _userManagement.getUserAccount(_platformUserId);

        //reset token
        ITokenManager _tokenManagement = ITokenManager(tokenManagementContractAddress);
        _tokenManagement.setIsManagedToken(_acct, false);
    }
}
