pragma solidity ^0.6.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20Burnable.sol";


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