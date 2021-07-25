// SPDX-License-Identifier: MIT
pragma solidity 0.6.10;

library AdminToolsLibrary {

    //for checking if address is a contract or not
    function _isContract(address _addr) internal view returns (bool){
      uint32 size;
      assembly {
        size := extcodesize(_addr)
      }
      return (size > 0);
    }
    function _stringsMatch (string memory a, string memory b) internal pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }

    //conversion functions
    function stringToBytes( string memory s) public pure returns (bytes memory){
        bytes memory b3 = bytes(s);
        return b3;
    }
    function bytesTouint(bytes memory _bytes) internal pure returns (uint) {
        require(_bytes.length >= 32, "touint_outOfBounds");
        uint tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), 0))
        }

        return tempUint;
    }

    function parseAddr(string memory _a) public pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }
}
