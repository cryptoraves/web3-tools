// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "/home/cartosys/openzeppelin-contracts/contracts/token/ERC1155/ERC1155Burnable.sol";
import "./AdministrationContract.sol";

interface CryptoravesTokenContract {
    function cryptoravesIdByAddress(address _account) external view returns(uint);
    function getHeldTokenIds(address _addr) external view returns(uint[] memory);
    function getHeldTokenBalances(address _addr) external view returns(uint[] memory);
    function safeTransferFrom(address from, address to, uint id, uint amount, bytes memory data) external;
    function safeBatchTransferFrom(address from, address to, uint[] memory ids, uint[] memory amounts, bytes memory data) external;
    function burn(address, uint, uint) external;
    function subtractFromTotalSupply(uint _tokenId, uint _amount) external;
}


contract Ravepool is AdministrationContract {

    using SafeMath for uint;
    using Address for address;

    bool private _ravepoolActivated;
    address internal _tokenManager;
    uint private _userId;

    event BurnAndRedeem(uint _sentTokenId, uint _amountOfPersonalToken);

    modifier ravepoolActivated () {
      require(_ravepoolActivated, 'Ravepool is not activated. Reverting.');
      _;
    }
    modifier ravepoolNotActivated () {
      require(!_ravepoolActivated, 'Ravepool is activated. Reverting.');
      _;
    }

    function activateRavepool() public onlyAdmin ravepoolNotActivated{


        address _userTokenManager = ITransactionManager(getTransactionManagerAddress()).userManagementContractAddress();

        //require crypto already dropped by user
        uint _userIdToCheck = IUserManager(_userTokenManager).getUserId(address(this));
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

    function redeemAndBurnViaRavepool(uint _sentTokenId, uint _amountOfPersonalToken, bytes memory _data) public payable onlyAdmin ravepoolActivated {

        require(_amountOfPersonalToken > 0, 'Amount must be greater than zero');

        address _cryptoravesTokenAddress = ITokenManager(_tokenManager).cryptoravesTokenAddress();

        //get personal token Id
        uint _1155tokenId  = CryptoravesTokenContract(_cryptoravesTokenAddress).cryptoravesIdByAddress(address(this));

        //require sent token to be the designated personal token
        require(_sentTokenId == _1155tokenId, 'Token ID sent to redeemAndBurnViaRavepool doesn\'t match designated burn token ID');

        //gather list of all held tokens in Ravepool
        uint[] memory _heldTokenIds = CryptoravesTokenContract(_cryptoravesTokenAddress).getHeldTokenIds(address(this));
        uint[] memory _heldTokenbalances = CryptoravesTokenContract(_cryptoravesTokenAddress).getHeldTokenBalances(address(this));

        //total supply used to calculate final share percentaghe
        uint _totalSupplyOfPersonalToken = ITokenManager(_tokenManager).managedTokenByFullBytesId(_sentTokenId).totalSupply;

        //calculate percentage of each token to be distributed back to msg sender
        uint[] memory _distributionAmounts;

        //will have to ensure erctype is 20 (fungible) for each of these. Then create another function to facilitate non-fungibles
        for (uint i=0; i<_heldTokenIds.length; i++) {
            _distributionAmounts[i] = _heldTokenbalances[i] * _amountOfPersonalToken / _totalSupplyOfPersonalToken;
        }

        //send tokens for redemption
        CryptoravesTokenContract(_cryptoravesTokenAddress).safeTransferFrom(msg.sender, address(this), _sentTokenId, _amountOfPersonalToken, _data);

        //distribute held tokens
        CryptoravesTokenContract(_cryptoravesTokenAddress).safeBatchTransferFrom(address(this), msg.sender, _heldTokenIds, _distributionAmounts, _data);

        //burn spent tokens
        CryptoravesTokenContract(_cryptoravesTokenAddress).burn(address(this), _sentTokenId, _amountOfPersonalToken);

        //adjust totalSupply
        CryptoravesTokenContract(_cryptoravesTokenAddress).subtractFromTotalSupply(_sentTokenId, _amountOfPersonalToken);

        emit BurnAndRedeem(_sentTokenId, _amountOfPersonalToken);
    }
}
