pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./TokenManagement.sol";

contract ValidatorSystem {
    
    using SafeMath for uint256;
    using Address for address;

    /*
    * Legit list of validator addresses 
    */
    mapping(address => bool) private _validators;
    
    //token manager contract address
    address private _tokenManager;
    
    event NewTokenManager(address);
    
    /*
    * Require msg.sender to be validator
    */
    modifier onlyValidator () {
      // can we pull from a Chainlink mapping?
      require(_validators[msg.sender], 'Sender is not a validator.');
      _;
    }
    
    //owner can validate by default. Can later revoke self by unsetValidator()
    constructor(string memory _uri) public {
        
        //set default validator
         _validators[msg.sender] = true;
         
         //launch token Manager
         TokenManagement _tknManager = new TokenManagement(_uri);
         
         //set default token manager address
         _tokenManager = address(_tknManager);
         
         emit NewTokenManager(_tokenManager);
    }
    
    /*
    * Add a validator to the list
    * @param newValidator The address of the new validator
    */
    function setValidator(address newValidator) public onlyValidator {
        _validators[newValidator] = true;
    }
    
    /*
    * de-authorize a validator
    * @param oldValidator The address of the validator to remove access
    */
    function unsetValidator(address oldValidator) public onlyValidator {
        _validators[oldValidator] = false;
    }
    
    /*
    * Get token manager address
    */
    function getTokenManager() public view onlyValidator returns(address) {
        return _tokenManager;
    }
    
    /*
    * Change token manager address
    * @param newTokenManager is the address of new Token Manager
    */
    function changeTokenManager(address newTokenManager) public onlyValidator {
        _tokenManager = newTokenManager;
    }
    
    /*
    * check incoming parsed Tweet data for valid command
    * @param _twitterIds [1] = twitterIdFrom, [2] = twitterIdTo, [3] = twitterIdThirdParty
    * @param _twitterNames [1] = twitterHandleFrom, [2] = twitterHandleTo, [3] = thirdPartyName
    * @param _fromImgUrl The Twitter img of initiating user
    * @param _isLaunch launch indicator
    * @param _value amount or id of token to transfer
    * @param _data bytes value for ERC721 & 1155 txns
    */ 
    function validateCommand(
        uint256[] memory _twitterIds,
        string[] memory _twitterNames,
        string memory _fromImageUrl,
        bool _isLaunch, 
        uint256 _value,
        bytes memory _data
    ) public onlyValidator {
        
        TokenManagement tokenManager = TokenManagement(_tokenManager);
        
        tokenManager.initCommand(_twitterIds, _twitterNames, _fromImageUrl, _isLaunch, _value, _data);
        /*
        *  Consider using the Token Manager Contract to host view functions for validating.
        *  Also see if view functions can return a function type that can then be executed 
        *  from here if valid.
        */
    }
    
}
