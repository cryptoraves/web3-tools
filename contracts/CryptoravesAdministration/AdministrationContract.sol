// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;
pragma experimental ABIEncoderV2;

import "./AdminToolsLibrary.sol";

interface ITransactionManager {
    struct TwitterInts {
        uint twitterIdFrom;
        uint twitterIdTo;
        uint twitterIdThirdParty;
        uint amountOrId;
        uint decimalPlaceLocation;
        uint tweetId;
    }
    function initCommand(TwitterInts memory, string[] memory) external returns(bool);
    function testFortransactionManagerAddressUniquely() external pure returns(bool);
    function tokenManagementContractAddress() external view returns(address);
    function userManagementContractAddress() external view returns(address);
}

interface ITokenManager {
    struct ManagedToken {
        uint cryptoravesTokenId;
        bool isManagedToken;
        uint ercType;
        uint nftIndex;
        uint totalSupply;
        string name;
        string symbol;
        uint decimals;
        string emoji;
        string tokenBrandImageUrl;
        string tokenDescription;
    }
    function managedTokenByFullBytesId(uint) external view returns(ManagedToken memory);
    function getTokenStruct(uint) external view returns(ManagedToken memory); //required as solidity not yet allowing above getter function call from another contract
    function cryptoravesTokenAddress() external view returns(address);
    function getAddressBySymbol(string memory) external view returns(address);
    function cryptoravesIdByAddress(address) external view returns(uint);
    function dropCrypto(string memory, address, uint, bytes memory) external returns(uint);
    function managedTransfer(address, address, uint, uint, bytes memory) external;
    function setIsManagedToken(address, bool) external;
    function adjustValueByUnits(uint, uint, uint) external view returns(uint);
}

interface IUserManager {
    struct User {
        uint twitterUserId;
        address cryptoravesAddress;
        string twitterHandle;
        string imageUrl;
        bool isManaged;
        bool isUser;
        bool dropped;
        uint tokenId;
    }
    function layerTwoAccounts(address) external view returns(address);
    function layerOneAccounts(address) external view returns(address);
    function userAccounts(address) external view returns(uint);
    function userAccountCheck(uint, string memory, string memory) external returns(User memory);
    function mapLayerOneAccount(address, address, uint) external;
    function getUserStruct(uint) external view returns(User memory);
    function setDropState(uint, bool) external returns (address);
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
                    try iTxnMgmt.testFortransactionManagerAddressUniquely() {
                        return _administratorList[i];
                    } catch {}
                }
            }
        }

        revert('No transactionManagerAddress found!');
    }
}
