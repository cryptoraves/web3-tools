pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
//import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/IERC721.sol";

contract ERC20Depositable {
    
    //list of deposited tokens
    mapping(uint256 => address) public ERC20TokenList;
    
    /**
    * @notice Emits when a deposit is made.
    */
    event Deposit(address indexed _from, uint _value, address indexed _token);
    /**
    * @notice Emits when a withdrawal is made.
    */
    event Withdraw(address indexed _to, uint _value, address indexed _token);
    /**
    * @notice Emits when a Transfer is made.
    */
    
    /**
    * @dev Allows a user to deposit ETH or an ERC20 into the contract.
           If _token is 0 address, deposit ETH.
    * @param _amount The amount to deposit.
    * @param _token The token to deposit.
    */
    function _depositERC20(uint256 _amount, address _token) internal {
        if(_token == address(0)) {
          require(msg.value == _amount, 'incorrect amount');
          emit Deposit(msg.sender, _amount, _token);
        } else {
          IERC20 token = IERC20(_token);
          require(token.transferFrom(msg.sender, address(this), _amount), 'transfer failed');
          emit Deposit(msg.sender, _amount, _token);
        }
    }
    
    /**
    * @dev Withdraw funds to msg.sender, but only if the timelock is expired
           and msg.sender is the beneficiary.
           If _token is 0 address, withdraw ETH.
    * @param _amount The amount to withdraw.
    * @param _token The token to withdraw.
    */
    function _withdrawERC20(uint256 _amount, address _token) internal {
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
    
    function _depositERC721(uint256 _tokenId, address _token) internal {
        IERCuni token = IERCuni(_token); //trying ABI for ERC20 as IERC721.sol conflicts with IERC1155
        token.safeTransferFrom(msg.sender, address(this), _tokenId);
        emit Deposit(msg.sender, _tokenId, _token);
        
    }
    function _withdrawERC721(uint256 _tokenId, address _token) internal {
        IERCuni token = IERCuni(_token);
        token.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Withdraw(msg.sender, _tokenId, _token);
        
    }
}

interface IERCuni is IERC20 {
    //adding erc721 function for minimilaization of inhereitances
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}