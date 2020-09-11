// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "AdministrationContract.sol";

/*  
    Oracle data corridor. Oracle address(es) must be set as administrator.
*/
contract ValidatorInterfaceContract is AdministrationContract {

    //token manager contract address
    address private _transactionManager;
    
    event NewTransactionManager(address indexed _managementAddr);
    
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
        emit NewTransactionManager(_transactionManager);
    }
    
    /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterIds [0] = twitterIdFrom, [1] = twitterIdTo, [2] = twitterIdThirdParty
    * @param _twitterNames [0] = twitterHandleFrom, [1] = twitterHandleTo, [2] = thirdPartyName
    * @param 
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
    function validateCommand(
        uint256[] memory _twitterIds,
        string[] memory _twitterNames,
        uint256 _value,
        string[] memory _metaData
    ) public onlyAdmin {
        
        ITransactionManager transactionManager = ITransactionManager(_transactionManager);
        
        transactionManager.initCommand(_twitterIds, _twitterNames, _value, _metaData);
        /*
        *  Consider using the Token Manager Contract to host view functions for validating.
        *  Also see if view functions can return a function type that can then be executed 
        *  from here if valid.
        */
    }
    
}
