//SPDX-License-Identifier: MIT
import "./ERC721Full.sol";

pragma solidity 0.6.10;


contract EIP721Factory {

    mapping(address => address[]) public created;
    mapping(address => bool) public isEIP721; //verify without having to do a bytecode check.

    constructor() public {
        //upon creation of the factory, deploy a EIP721 (parameters are meaningless) to get address.
        createEIP721('Verification NFT', 'VNFT');
    }

    function createEIP721(string memory name, string memory symbol)
        public
    returns (address) {

        ERC721Full newToken = (new ERC721Full(msg.sender, name, symbol));
        created[msg.sender].push(address(newToken));
        isEIP721[address(newToken)] = true;
        return address(newToken);
    }
}
