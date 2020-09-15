// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "./AdministrationContract.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

contract ERCDepositable is IERC721Receiver, AdministrationContract {
    
    mapping(string => address) public tokenAddressesBySymbol;

    function getTotalSupplyOf3rdPartyToken(address _tknAddr) public view returns (uint256) {
        IERCuni token = IERCuni(_tknAddr);
        return token.totalSupply();
    }
    
    function getSymbolOf3rdPartyToken(address _tknAddr) public view returns (string memory) {
        IERCuni token = IERCuni(_tknAddr);
        return token.symbol();
    }
    
    function getTickerAddress(string memory _ticker) external view returns (address) {
        return tokenAddressesBySymbol[_ticker];
    }
    
    function _checkTickerAddress(string memory _ticker, address _token) internal {
        //only adds ticker if not yet taken
        if(tokenAddressesBySymbol[_ticker] == address(0)){
            tokenAddressesBySymbol[_ticker] = _token;
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
            (bool success, ) = msg.sender.call{value: _amount}("");
            require(success, "Transfer failed.");
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
        
    //required for use with safeTransfer in ERC721
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}

interface IERCuni is IERC20 {
    //adding erc721 function for minimilaization of inhereitances
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function symbol() external view returns(string memory);
    function totalSupply() external view override returns (uint256);
}
