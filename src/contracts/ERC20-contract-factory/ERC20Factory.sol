//SPDX-License-Identifier: MIT
import "./ERC20Full.sol"; 

pragma solidity ^0.6.0;


contract EIP20Factory {

    mapping(address => address[]) public created;
    mapping(address => bool) public isEIP20; //verify without having to do a bytecode check.
    
    constructor() public {
        //upon creation of the factory, deploy a EIP20 (parameters are meaningless) and store the bytecode provably.
        createEIP20(10000, "Verify Token", 3, "VTX");
    }

    function createEIP20(uint256 _initialAmount, string memory _name, uint8 _decimals, string memory _symbol)
        public
    returns (address) {

        ERC20Full newToken = (new ERC20Full(msg.sender, _name, _symbol, _decimals, _initialAmount));
        created[msg.sender].push(address(newToken));
        isEIP20[address(newToken)] = true;
        //the factory will own the created tokens. You must transfer them.
        return address(newToken);
    }
}
