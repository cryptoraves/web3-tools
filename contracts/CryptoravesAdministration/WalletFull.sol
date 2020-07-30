// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/www/openzeppelin-contracts/contracts/token/ERC1155/ERC1155Burnable.sol";
import "./AdministrationContract.sol";

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

contract WalletFull is ERC1155Receiver, AdministrationContract {

    address private _walletManager;
    address private _mappedL1Account;

    constructor(address _managerAddress) public {
        
        address _cryptoravesTokenAddress = ITokenManager(_managerAddress).getCryptoravesTokenAddress();
        //setManager 
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_managerAddress, true);
        _walletManager = _managerAddress;
        _administrators[_managerAddress] = true;
        _administrators[msg.sender] = true;
    }

    function mapLayerOneAccount(address _l1Addr) public onlyAdmin {
        unsetAdministrator(_mappedL1Account);
        _mappedL1Account = _l1Addr;
        setAdministrator(_l1Addr);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    
    function managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_walletManager).getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).safeTransferFrom(_from, _to, _id, _val, _data);
    }
    
    function managedBatchTransfer(address _from, address _to, uint256[] memory _ids,  uint256[] memory _vals, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_walletManager).getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).safeBatchTransferFrom(_from, _to, _ids, _vals, _data);
    }
}

