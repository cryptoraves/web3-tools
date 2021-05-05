// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdminToolsLibrary.sol";

interface ITransactionManager {
    struct TwitterInts {
        uint256 twitterIdFrom;
        uint256 twitterIdTo;
        uint256 twitterIdThirdParty;
        uint256 amountOrId;
        uint256 decimalPlaceLocation;
        uint256 tweetId;
    }
    function initCommand(TwitterInts memory, string[] memory, bytes[] memory, bytes calldata) external returns(bool);
    function testForTransactionManagementAddressUniquely() external pure returns(bool);
    function getUserL1AccountFromL2Account(address) external view returns(address);
    function getUserL2AccountFromL1Account(address) external view returns(address);
    function getTokenManagementAddress() external view returns(address);
    function getUserManagementAddress() external view returns(address);
    function getCryptoravesTokenAddress() external view returns(address);
    function emitTransferFromTokenManagementContract(address,address,uint256,uint256,uint256) external;
}

interface ITokenManager {
    function getCryptoravesTokenAddress() external view returns(address);
    function getUserManagementAddress() external view returns(address);
    function getAddressBySymbol(string memory) external view returns(address);
    function getManagedTokenBasedBytesIdByAddress(address) external view returns(uint256);
    function dropCrypto(string memory, address, uint256, bytes memory) external;
    function managedTransfer(address, address, uint256, uint256, bytes memory) external;
    function setIsManagedToken(address, bool) external;
    function adjustValueByUnits(uint256, uint256, uint256) external view returns(uint256);
    function getERCtype(uint256) external view returns(uint256);
    function getNextBaseId(uint256) external view returns(uint256);
}

interface IUserManager {
    struct User {
        uint256 twitterUserId;
        address cryptoravesAddress;
        string twitterHandle;
        string imageUrl;
        bool isManaged;
        bool isUser;
        bool dropped;
        uint256 tokenId;
    }
    function getLayerOneAccount(address) external view returns(address);
    function getLayerTwoAccount(address) external view returns(address);
    function userHasL1AddressMapped(address) external view returns(bool);
    function getUserId(address) external view returns(uint256);
    function dropState (uint256) external view returns(bool);
    function userAccountCheck(uint256, string memory, string memory) external returns(User memory);
    function mapLayerOneAccount(address, address) external;
    function getUserAccount(uint256) external view returns(address);
    function getUserStruct(uint256) external view returns(User memory);
    function isUser (uint256) external view  returns(bool);
    function setDropState(uint256, bool) external returns (address);
}

interface IDownStream {
    function testDownstreamAdminConfiguration() external view returns(bool);
}

contract AdministrationContract {

    /*
    * Legit list of admin addresses & loopable array
    */
    mapping(address => bool) private _administrators;
    address [] internal _administratorList;

    //event NewAdministrator(address indexed _newAdminAddr, address indexed _fromContractAddr);
    //event RemovedAdministrator(address indexed _oldAdminAddr, address indexed _fromContractAddr);

    constructor() public {
        //default validator is set to sender
        _administrators[msg.sender] = true;
        _administratorList.push(msg.sender);
    }

    /*
    * Require msg.sender to be administrator
    */
    modifier onlyAdmin () {
      // can we pull from a Chainlink mapping?
      require(_administrators[msg.sender], 'Sender is not the parent contract nor an admin.');
      _;
    }

    /*
    * Return admin flag of sender
    */
    function isAdministrator(address _addr) public view returns(bool) {
        return _administrators[_addr];
    }

    /*
    * Add an admin to the list
    * @param _newAdmin The address of the new admin
    */
    function setAdministrator(address _newAdmin) public onlyAdmin {
        _administrators[_newAdmin] = true;
        _administratorList.push(_newAdmin);
        //emit NewAdministrator(_newAdmin, address(this));
    }

    /*
    * de-authorize an admin
    * @param oldAdmin The address of the admin to remove access
    */
    function unsetAdministrator(address _oldAdmin) public onlyAdmin {
        _administrators[_oldAdmin] = false;
        //emit RemovedAdministrator(_oldAdmin, address(this));
    }

    /*
    * For checking if contract is launched
    */
    function isAvailable() public pure returns(bool) {
        return true;
    }

    /*
    * Admin Address Looper for hook functionality
    */
    function getTransactionManagerAddress() public view returns(address) {
        require(_administratorList.length < 1000, 'List of administrators is too damn long!');

        for (uint i=0; i<_administratorList.length; i++) {
            //first, ensure _administrator is set to true
            if(_administrators[_administratorList[i]]){
                //check if address is a contract
                if(AdminToolsLibrary._isContract(_administratorList[i])){
                    //first instantiate existing contract
                    ITransactionManager iTxnMgmt = ITransactionManager(_administratorList[i]);
                    //then try to run its function
                    try iTxnMgmt.testForTransactionManagementAddressUniquely() {
                        return _administratorList[i];
                    } catch {}
                }
            }
        }

        revert('No TransactionManagementAddress found!');
    }
}
