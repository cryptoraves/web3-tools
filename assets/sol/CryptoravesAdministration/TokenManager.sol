pragma solidity ^0.6.0;

import "./WalletFull.sol";


//can manage tokens for any Cryptoraves-native address

contract TokenManager is ERC1155{
    
    mapping(address => bool) public wallets;
    
    //the address of the contract launcher is _manager by default
    address private _manager;
    
    modifier onlyManager () {
      // can we pull from a Chainlink mapping?
      require(msg.sender == _manager, 'Sender is not the manager.');
      _;
    }

    constructor() ERC1155() public {
        _manager = msg.sender;
        
    }
    
    function mint(address _to, uint256 _id, uint256 _value, bytes memory _data) public{ 
        _mint(_to, _id, _value, _data);
    }

    function mintBatch(address _to, uint256[] memory _ids, uint256[] memory _values, bytes memory _data) public {
        _mintBatch(_to, _ids, _values, _data);
    }
    
    function launchL2Account() public onlyManager returns (address) {
        WalletFull receiver = new WalletFull(address(this));
        wallets[address(receiver)];
        return address(receiver);
    }
    
    function managedTransfer(address _from, address _to, uint256 _id,  uint256 _val, bytes memory _data) onlyManager public {
        WalletFull(_from).managedTransfer(_from, _to, _id, _val, _data);
    }
}
