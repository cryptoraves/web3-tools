pragma solidity ^0.6.2;

import "./SimpleWallet.sol";

contract WalletFull is SimpleWallet {
    
    constructor(address ManagerAddress) public {
        //setManager 
        ERC1155ABI(ManagerAddress).setApprovalForAll(ManagerAddress, true);
    }
}

interface ERC1155ABI {
    function setApprovalForAll(address operator, bool approved) external;
}