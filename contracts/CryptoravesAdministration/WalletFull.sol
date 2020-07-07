// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC1155/ERC1155Burnable.sol";

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}

interface ITokenManager {
    function getCryptoravesTokenAddress() external view returns(address);
}

contract WalletFull is ERC1155Receiver {

    address private _walletManager;
    
    modifier onlyWalletManager () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _walletManager, 'Sender is not the manager.');
      _;
    }

    constructor(address _managerAddress) public {
        
        address _cryptoravesTokenAddress = ITokenManager(_managerAddress).getCryptoravesTokenAddress();
        //setManager 
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_managerAddress, true);
        _walletManager = _managerAddress;
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    
    function managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) public onlyWalletManager {
        
        address _cryptoravesTokenAddress = ITokenManager(_walletManager).getCryptoravesTokenAddress();
        
        IERC1155(_cryptoravesTokenAddress).safeTransferFrom(_from, _to, _id, _val, _data);
    }
}

