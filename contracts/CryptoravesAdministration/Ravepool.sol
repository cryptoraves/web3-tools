// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/openzeppelin-contracts/contracts/token/ERC1155/ERC1155Burnable.sol";
import "./AdministrationContract.sol";

interface CryptoravesTokenManager {
    function cryptoravesIdByAddress(address _account) external view returns(uint256);
    function getHeldTokenIds(address _addr) external view returns(uint256[] memory);
    function getHeldTokenBalances(address _addr) external view returns(uint256[] memory);
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) external;
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;
    function burn(address, uint256, uint256) external;
    function getTotalSupply(uint256) external view returns(uint256);
    function subtractFromTotalSupply(uint256 _tokenId, uint256 _amount) external;
}


contract Ravepool is AdministrationContract {
    
    using SafeMath for uint256;
    using Address for address;
    
    bool private _ravepoolActivated;
    address internal _tokenManager;
    uint256 private _userId;
    
    event BurnAndRedeem(uint256 _sentTokenId, uint256 _amountOfPersonalToken);
    
    modifier ravepoolActivated () {
      require(_ravepoolActivated, 'Ravepool is not activated. Reverting.');
      _;
    }
    modifier ravepoolNotActivated () {
      require(!_ravepoolActivated, 'Ravepool is activated. Reverting.');
      _;
    }
    
    function activateRavepool() public onlyAdmin ravepoolNotActivated{
        
        address _userTokenManager = ITokenManager(_tokenManager).getUserManagementAddress();
        
        //require crypto already dropped by user
        uint256 _userIdToCheck = IUserManager(_userTokenManager).getUserId(address(this));
        require(
            IUserManager(_userTokenManager).dropState(_userIdToCheck),
            'User has not yet dropped their cryptoraves personal token.'
        );
        
        //require layer 1 address be mapped by user 
        require(
            IUserManager(_userTokenManager).userHasL1AddressMapped(address(this)),
            'User has not yet Mapped an L1 address to their cryptoraves address.'
        );
        
        //activate ravepool
        _ravepoolActivated = true;
    }
    function isRavepoolActivated() public view returns(bool) {
        return _ravepoolActivated;
    }
    
    function redeemAndBurnViaRavepool(uint256 _sentTokenId, uint256 _amountOfPersonalToken, bytes memory _data) public payable onlyAdmin ravepoolActivated {
        
        require(_amountOfPersonalToken > 0, 'Amount must be greater than zero');
        
        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).cryptoravesTokenAddr();
        
        //get personal token Id
        uint256 _1155tokenId  = CryptoravesTokenManager(_cryptoravesTokenAddress).cryptoravesIdByAddress(address(this));
        
        //require sent token to be the designated personal token
        require(_sentTokenId == _1155tokenId, 'Token ID sent to redeemAndBurnViaRavepool doesn\'t match designated burn token ID');
        
        //gather list of all held tokens in Ravepool
        uint256[] memory _heldTokenIds = CryptoravesTokenManager(_cryptoravesTokenAddress).getHeldTokenIds(address(this));
        uint256[] memory _heldTokenbalances = CryptoravesTokenManager(_cryptoravesTokenAddress).getHeldTokenBalances(address(this));
        
        //total supply used to calculate final share percentaghe
        uint256 _totalSupplyOfPersonalToken = CryptoravesTokenManager(_cryptoravesTokenAddress).getTotalSupply(_sentTokenId);
        
        //calculate percentage of each token to be distributed back to msg sender
        uint256[] memory _distributionAmounts;
        
        //will have to ensure erctype is 20 (fungible) for each of these. Then create another function to facilitate non-fungibles
        for (uint i=0; i<_heldTokenIds.length; i++) {
            _distributionAmounts[i] = _heldTokenbalances[i] * _amountOfPersonalToken / _totalSupplyOfPersonalToken;
        }
        
        //send tokens for redemption
        CryptoravesTokenManager(_cryptoravesTokenAddress).safeTransferFrom(msg.sender, address(this), _sentTokenId, _amountOfPersonalToken, _data);
        
        //distribute held tokens
        CryptoravesTokenManager(_cryptoravesTokenAddress).safeBatchTransferFrom(address(this), msg.sender, _heldTokenIds, _distributionAmounts, _data);
        
        //burn spent tokens
        CryptoravesTokenManager(_cryptoravesTokenAddress).burn(address(this), _sentTokenId, _amountOfPersonalToken);
        
        //adjust totalSupply 
        CryptoravesTokenManager(_cryptoravesTokenAddress).subtractFromTotalSupply(_sentTokenId, _amountOfPersonalToken);
        
        emit BurnAndRedeem(_sentTokenId, _amountOfPersonalToken);
    }
}