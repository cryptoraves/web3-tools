pragma solidity ^0.6.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol";

contract ERC1155Full is ERC1155 {
    
    constructor() ERC1155() public {
    }
    
    function mint(address _to, uint256 _id, uint256 _value, bytes memory _data) public{ 
        
        _mint(_to, _id, _value, _data);

    }
    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) public {
        
        _mintBatch(_to, _ids, _values, _data);

    }
}