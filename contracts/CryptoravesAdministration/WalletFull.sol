// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/openzeppelin-contracts/contracts/token/ERC1155/ERC1155Burnable.sol";
import "./AdministrationContract.sol";

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver, AdministrationContract {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}

interface IERC1155Mintable {
    function mint() external view returns(address);
    function getUserManagementAddress() external view returns(address);
}

contract WalletFull is ERC1155Receiver {

    using SafeMath for uint256;
    using Address for address;

    address private _transactionManagementAddress;

    constructor(address _txnManagerAddress) public {
        
        address _cryptoravesTokenAddress = ITransactionManager(_txnManagerAddress).cryptoravesTokenAddr();
        address _tokenManagerAddress = ITransactionManager(_txnManagerAddress).getTokenManagementAddress();
        //setManager
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_tokenManagerAddress, true);
        _transactionManagementAddress = _txnManagerAddress;
        setAdministrator(_txnManagerAddress);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
/*
    function managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagementAddress).cryptoravesTokenAddr();
        IERC1155(_cryptoravesTokenAddress).safeTransferFrom(_from, _to, _id, _val, _data);
    }

    function managedBatchTransfer(address _from, address _to, uint256[] memory _ids,  uint256[] memory _vals, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagementAddress).cryptoravesTokenAddr();
        IERC1155(_cryptoravesTokenAddress).safeBatchTransferFrom(_from, _to, _ids, _vals, _data);
    }

    function managedBurn(address account, uint256 id, uint256 amount) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagementAddress).cryptoravesTokenAddr();
        ERC1155Burnable(_cryptoravesTokenAddress).burn(account, id, amount);
    }

    function managedBurnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagementAddress).cryptoravesTokenAddr();
        ERC1155Burnable(_cryptoravesTokenAddress).burnBatch(account, ids, amounts);
    }
*/
    //for custody-less transactions originating from social media. Any action requires approval from mapped L1 account.
    function actionItemApproval() public view {
        //require(msg.sender == _mappedL1Account, 'Sender not an approved L1 account');

        //get list of action items

        //execute action items

        //remove item from list

        //emit event
    }
}
