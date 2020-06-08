pragma solidity 0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Burnable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/math/SafeMath.sol";

contract DepositContract {
  using SafeMath for uint;

  /*** STORAGE VARIABLES ***/

  /**
    * @notice Token look up table for front-end access.
  */
  address[] public tokenLUT;

  /**
    * @notice Checks whether a token exists in the fund.
  */
  mapping(address => bool) public tokens;
  
  
  /**
    * @notice Address of ERC20 token used for withdrawal
  */
  address public MasterTokenAddress;

  /*** EVENTS ***/

  /**
    * @notice Emits when a deposit is made.
  */
  event Deposit(address indexed _from, uint _value, address indexed _token);

  /**
    * @notice Emits when a withdrawal is made.
  */
  event Withdraw(address indexed _to, uint _value, address indexed _token);

  /*** MODIFIERS ***/

  
  /**
    * @param _MasterTokenAddress the redemption token.
  */
  constructor(address _MasterTokenAddress) public {
    MasterTokenAddress = _MasterTokenAddress;
  }

  /*** VIEW/PURE FUNCTIONS ***/

  /**
    * @dev Returns the length of the tokenLUT array.
  */
  function getTokenPool() public view returns(uint) {
    return tokenLUT.length;
  }
  
  /**
    * @dev Returns MasterTokenAddress
  */
  function getMasterTokenAddress() public view returns(address) {
    return MasterTokenAddress;
  }


  /*** OTHER FUNCTIONS ***/

  /**
    * @dev Allows a user to deposit ETH or an ERC20 into the contract.
           If _token is 0 address, deposit ETH.
    * @param _amount The amount to deposit.
    * @param _token The token to deposit.
  */
  function deposit(uint _amount, address _token) public payable {
    if(_token == address(0)) {
      require(msg.value == _amount, 'incorrect amount');
      if(!tokens[_token]) {
        tokenLUT.push(_token);
        tokens[_token] = true;
      }
      emit Deposit(msg.sender, _amount, _token);
    }
    else {
      IERC20 token = IERC20(_token);
      require(token.transferFrom(msg.sender, address(this), _amount), 'transfer failed');
      if(!tokens[_token]) {
        tokenLUT.push(_token);
        tokens[_token] = true;
      }
      emit Deposit(msg.sender, _amount, _token);
    }
  }

  /**
    * @param _amount The amount of master tokens to redeem and burn.
  */
  function RedeemTokenShare(uint _amount, address _token) public payable {
      /**
      * @dev Throws if redemption not initiated using Master Tokens.
      */
      require( _token == MasterTokenAddress, 'Only Master Token Can Redeem Locked Assets');
      MasterToken t = MasterToken(MasterTokenAddress);
      
      uint256 proportion = _amount / t.totalSupply();
      
      require(t.burn(_amount), 'burn failed');
      
      uint arrayLength = getTokenPool();
      for (uint i=0; i<arrayLength; i++) {
          _withdraw(proportion, tokenLUT[i]);
      }
      
  }    
  /**
    * @dev Withdraw funds to msg.sender, but only if the timelock is expired
           and msg.sender is the beneficiary.
           If _token is 0 address, withdraw ETH.
    * @param _amount The amount to withdraw.
    * @param _token The token to withdraw.
  */
  function _withdraw(uint _amount, address _token) internal {
    if(_token == address(0)) {
      (bool success, ) = msg.sender.call.value(_amount)("");
      require(success, "Transfer failed.");
      emit Withdraw(msg.sender, _amount, _token);
    } else {
      IERC20 token = IERC20(_token);
      require(token.transfer(msg.sender, _amount), 'transfer failed');
      emit Withdraw(msg.sender, _amount, _token);
    }
  }
}

interface MasterToken {
    function burn(uint _amount) external returns(bool);
    function totalSupply() external view returns (uint256);
}