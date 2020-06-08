pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol"; //release-v3.0.0
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol"; //release-v3.0.0

contract ValidatorSystem {
    
    using SafeMath for uint256;
    using Address for address;

    /*
    * Legit list of validator addresses 
    */
    mapping(address => bool) private _validators;
    
    /*
    * Require msg.sender to be validator
    */
    modifier onlyValidator () {
      // can we pull from a Chainlink mapping?
      require(_validators[msg.sender], 'Sender is not a validator.');
      _;
    }
    
    //owner can validate by default. Can later revoke self by unsetValidator()
    constructor() public {
         _validators[msg.sender] = true;
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
    * check incoming parsed Tweet data for valid command
    * @param twitterAddressFrom The Twitter ID of the Tweet author
    * @param fromImgUrl The Twitter img of user
    * @param param1 first possible param to ckeck
    * @param param2 second possible param to ckeck
    * @param param3 third possible param to ckeck
    */ 
    function validateCommand(
        uint256 twitterIdFrom,
        string memory fromImageUrl,
        string memory param1, 
        string memory param2, 
        string memory param3
    ) public onlyValidator {
        /*
        *  Consider using the Token Manager Contract to host view functions for validating.
        *  Also see if view functions can return a function type that can then be executed 
        *  from here if valid.
        */
    }    
}
