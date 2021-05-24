// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdministrationContract.sol";

/*
    Oracle data corridor. Oracle address(es) must be set as administrator.
*/
contract ValidatorInterfaceContract is AdministrationContract {

    //token manager contract address
    address private _transactionManager;

    //owner is administrator ("validator") by default. Can later revoke self by unsetValidator()
    constructor(address _txnManager) public {

        //asssign sender as admin
        setAdministrator(msg.sender);

        //set default token manager address
        setTransactionManagementAddress(_txnManager);
    }


    /*
    * Get token manager address
    */
    function getTransactionManagementAddress() public view onlyAdmin returns(address) {
        return _transactionManager;
    }

    /*
    * set token manager address
    * @param newTransactionManager is the address of new Token Manager
    */
    function setTransactionManagementAddress(address newTransactionManager) public onlyAdmin {

        require(_transactionManager != newTransactionManager);
        _transactionManager = newTransactionManager;
    }

    function testDownstreamAdminConfiguration() public view onlyAdmin returns(bool){
        IDownStream _downstream = IDownStream(getTransactionManagementAddress());
        return _downstream.testDownstreamAdminConfiguration();
    }

    /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterInts - see struct twitterInts in transactionManagement.sol
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
    function validateCommand(
        ITransactionManager.TwitterInts memory _twitterInts,
        string[] memory _twitterStrings
    ) public onlyAdmin {

        ITransactionManager transactionManager = ITransactionManager(_transactionManager);

        transactionManager.initCommand(_twitterInts, _twitterStrings);
        /*
        *  Consider using the Token Manager Contract to host view functions for validating.
        *  Also see if view functions can return a function type that can then be executed
        *  from here if valid.
        */
    }

}
