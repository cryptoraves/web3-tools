//SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

import "/home/cartosys/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol"; //release-v3.0.0
import "/home/cartosys/openzeppelin-contracts/contracts/token/ERC20/ERC20Burnable.sol"; //release-v3.0.0


contract ERC20Full is ERC20, ERC20Burnable {
	
	constructor(
	    address userAddress,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _initialAmount
    ) ERC20(_name, _symbol) public {
	    _mint(userAddress, _initialAmount);
	    _setupDecimals(_decimals);
	}
}