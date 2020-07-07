// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract ERCDepositable {
    
    mapping(string => address) public tokenAddressesByTicker;
    
    constructor() internal {
        
    }
    
    
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
        } else {
          IERCuni token = IERCuni(_tokenAddr);
          require(token.transferFrom(msg.sender, address(this), _amount), 'transfer failed');
          _checkTickerAddress(token.symbol(), _tokenAddr);
        }
    }
    
    /**
    * @dev Withdraw funds to msg.sender
           and msg.sender is the beneficiary.
           If _token is 0 address, withdraw ETH.
    * @param _amount The amount to withdraw.
    * @param _tokenAddr The token to withdraw.
    */
    function _withdrawERC20(uint256 _amount, address _tokenAddr) internal {
        if(_tokenAddr == address(0)) {
            require(msg.sender.balance >= msg.value, "Transfer failed.");
        } else {
            IERCuni token = IERCuni(_tokenAddr);
            require(token.transfer(msg.sender, _amount), 'transfer failed');
        }
    }
    
    function _depositERC721(uint256 _tokenId, address _tokenAddr) internal {
        IERCuni token = IERCuni(_tokenAddr); //you can use ABI for ERC20 as IERC721.sol conflicts with IERC1155
        token.safeTransferFrom(msg.sender, address(this), _tokenId);
        _checkTickerAddress(token.symbol(), _tokenAddr);
        
    }
    function _withdrawERC721(uint256 _tokenId, address _tokenAddr) internal {
        IERCuni token = IERCuni(_tokenAddr);
        token.safeTransferFrom(address(this), msg.sender, _tokenId);
        
    }
}

interface IERCuni is IERC20 {
    //adding erc721 function for minimilaization of inhereitances
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function symbol() external view returns(string memory);
}
