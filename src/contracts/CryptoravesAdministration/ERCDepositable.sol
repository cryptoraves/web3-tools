// SPDX-License-Identifier: MIT
pragma solidity ^0.6.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";

contract ERCDepositable {
    
    mapping(string => address) public tokenAddressesByTicker;
    
    constructor() internal {
        
    }
    /**
    * @notice Emits when a deposit is made.
    */
    event Deposit(address indexed _from, uint256 _value, address indexed _token);
    /**
    * @notice Emits when a withdrawal is made.
    */
    event Withdraw(address indexed _to, uint256 _value, address indexed _token);
    
    function getTickerAddress(string memory _ticker) external view returns (address) {
       
        return tokenAddressesByTicker[_ticker];
    }
    
    function _checkTickerAddress(string memory _ticker, address _token) internal {
        if(tokenAddressesByTicker[_ticker] == address(0)){
            tokenAddressesByTicker[_ticker] = _token;
        }
    }
    
    /**
    * @dev Allows a user to deposit ETH or an ERC20 into the contract.
           If _token is 0 address, deposit ETH.
    * @param _amount The amount to deposit.
    * @param _tokenAddr The token to deposit.
    */
    function _depositERC20(uint256 _amount, address _tokenAddr) internal {
        if(_tokenAddr == address(0)) {
          require(msg.value == _amount, 'incorrect amount');
          emit Deposit(msg.sender, _amount, _tokenAddr);
        } else {
          IERCuni token = IERCuni(_tokenAddr);
          require(token.transferFrom(msg.sender, address(this), _amount), 'transfer failed');
          _checkTickerAddress(token.symbol(), _tokenAddr);
          emit Deposit(msg.sender, _amount, _tokenAddr);
        }
    }
    
    /**
    * @dev Withdraw funds to msg.sender, but only if the timelock is expired
           and msg.sender is the beneficiary.
           If _token is 0 address, withdraw ETH.
    * @param _amount The amount to withdraw.
    * @param _tokenAddr The token to withdraw.
    */
    function _withdrawERC20(uint256 _amount, address _tokenAddr) internal {
        if(_tokenAddr == address(0)) {
            (bool success, ) = msg.sender.call.value(_amount)("");
            require(success, "Transfer failed.");
            emit Withdraw(msg.sender, _amount, _tokenAddr);
        } else {
            IERCuni token = IERCuni(_tokenAddr);
            require(token.transfer(msg.sender, _amount), 'transfer failed');
            emit Withdraw(msg.sender, _amount, _tokenAddr);
        }
    }
    
    function _depositERC721(uint256 _tokenId, address _tokenAddr) internal {
        IERCuni token = IERCuni(_tokenAddr); //you can use ABI for ERC20 as IERC721.sol conflicts with IERC1155
        token.safeTransferFrom(msg.sender, address(this), _tokenId);
        _checkTickerAddress(token.symbol(), _tokenAddr);
        emit Deposit(msg.sender, _tokenId, _tokenAddr);
        
    }
    function _withdrawERC721(uint256 _tokenId, address _tokenAddr) internal {
        IERCuni token = IERCuni(_tokenAddr);
        token.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit Withdraw(msg.sender, _tokenId, _tokenAddr);
        
    }
}

interface IERCuni is IERC20 {
    //adding erc721 function for minimilaization of inhereitances
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function symbol() external view returns(string memory);
}
