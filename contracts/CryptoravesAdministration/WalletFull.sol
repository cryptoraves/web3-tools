// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "./Ravepool.sol";

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() public {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}

contract WalletFull is ERC1155Receiver, Ravepool {
    
    using SafeMath for uint256;
    using Address for address;
    
    address private _mappedL1Account;

    constructor(address _managerAddress) public {
        
        address _cryptoravesTokenAddress = ITokenManager(_managerAddress).getCryptoravesTokenAddress();
        //setManager 
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_managerAddress, true);
        _tokenManager = _managerAddress;
        _administrators[_managerAddress] = true;
        _administrators[msg.sender] = true;
    }


    function getLayerOneAccount() public view onlyAdmin returns(address) {
        return _mappedL1Account;
    }
    function mapLayerOneAccount(address _l1Addr) public onlyAdmin {
        require(_mappedL1Account == address(0), "User already mapped an L1 account");
          
        _mappedL1Account = _l1Addr;
        setAdministrator(_l1Addr);
        
        //set L1 account as 1155 operator for this wallet
        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).setApprovalForAll(_mappedL1Account, true);
    }

    function onERC1155Received(address, address, uint256, uint256, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata) external override virtual returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
    
    function managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).safeTransferFrom(_from, _to, _id, _val, _data);
    }
    
    function managedBatchTransfer(address _from, address _to, uint256[] memory _ids,  uint256[] memory _vals, bytes memory _data) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).getCryptoravesTokenAddress();
        IERC1155(_cryptoravesTokenAddress).safeBatchTransferFrom(_from, _to, _ids, _vals, _data);
    }
    
    function managedBurn(address account, uint256 id, uint256 amount) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).getCryptoravesTokenAddress();
        ERC1155Burnable(_cryptoravesTokenAddress).burn(account, id, amount);
    }
    
    function managedBurnBatch(address account, uint256[] memory ids, uint256[] memory amounts) public onlyAdmin {
        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).getCryptoravesTokenAddress();
        ERC1155Burnable(_cryptoravesTokenAddress).burnBatch(account, ids, amounts);
    }
    
    //for custody-less transactions originating from social media. Any action requires approval from mapped L1 account.
    function actionItemApproval() public {
        require(msg.sender == _mappedL1Account, 'Sender not an approved L1 account');
        
        //get list of action items
        
        //execute action items
        
        //remove item from list
        
        //emit event?
    }
}
