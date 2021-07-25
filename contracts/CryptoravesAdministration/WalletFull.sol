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
}

contract WalletFull is ERC1155Receiver {

    using SafeMath for uint;
    using Address for address;

    address private _transactionManagerAddress;

    constructor(address _txnManagerAddress) public {


        address _tokenManagerAddress = ITransactionManager(_txnManagerAddress).tokenManagementContractAddress();
        address _cryptoravesTokenAddress = ITokenManager(_tokenManagerAddress).cryptoravesTokenAddress();
        //setManager
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_tokenManagerAddress, true);
        _transactionManagerAddress = _txnManagerAddress;
        setAdministrator(_txnManagerAddress);
    }

    function onERC1155Received(address, address, uint, uint, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint[] calldata, uint[] calldata, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
/*
    function managedTransfer(address _from, address _to, uint _id,  uint _val, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagerAddress).cryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).safeTransferFrom(_from, _to, _id, _val, _data);
    }

    function managedBatchTransfer(address _from, address _to, uint[] memory _ids,  uint[] memory _vals, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagerAddress).cryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).safeBatchTransferFrom(_from, _to, _ids, _vals, _data);
    }

    function managedBurn(address account, uint id, uint amount) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagerAddress).cryptoravesTokenAddress();
        ERC1155Burnable(_cryptoravesTokenAddress).burn(account, id, amount);
    }

    function managedBurnBatch(address account, uint[] memory ids, uint[] memory amounts) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_transactionManagerAddress).cryptoravesTokenAddress();
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
