// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library ZeroCopySink {
    /* @notice          Convert boolean value into bytes
     *  @param b         The boolean value
     *  @return          Converted bytes array
     */
    function WriteBool(bool b) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly {
            buff := mload(0x40)
            mstore(buff, 1)
            switch iszero(b)
            case 1 {
                mstore(add(buff, 0x20), shl(248, 0x00))
                // mstore8(add(buff, 0x20), 0x00)
            }
            default {
                mstore(add(buff, 0x20), shl(248, 0x01))
                // mstore8(add(buff, 0x20), 0x01)
            }
            mstore(0x40, add(buff, 0x21))
        }
        return buff;
    }

    /* @notice          Convert byte value into bytes
     *  @param b         The byte value
     *  @return          Converted bytes array
     */
    function WriteByte(bytes1 b) internal pure returns (bytes memory) {
        return WriteUint8(uint8(b));
    }

    /* @notice          Convert uint8 value into bytes
     *  @param v         The uint8 value
     *  @return          Converted bytes array
     */
    function WriteUint8(uint8 v) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly {
            buff := mload(0x40)
            mstore(buff, 1)
            mstore(add(buff, 0x20), shl(248, v))
            // mstore(add(buff, 0x20), byte(0x1f, v))
            mstore(0x40, add(buff, 0x21))
        }
        return buff;
    }

    /* @notice          Convert uint16 value into bytes
     *  @param v         The uint16 value
     *  @return          Converted bytes array
     */
    function WriteUint16(uint16 v) internal pure returns (bytes memory) {
        bytes memory buff;

        assembly {
            buff := mload(0x40)
            let byteLen := 0x02
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            } {
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x22))
        }
        return buff;
    }

    /* @notice          Convert uint32 value into bytes
     *  @param v         The uint32 value
     *  @return          Converted bytes array
     */
    function WriteUint32(uint32 v) internal pure returns (bytes memory) {
        bytes memory buff;
        assembly {
            buff := mload(0x40)
            let byteLen := 0x04
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            } {
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x24))
        }
        return buff;
    }

    /* @notice          Convert uint64 value into bytes
     *  @param v         The uint64 value
     *  @return          Converted bytes array
     */
    function WriteUint64(uint64 v) internal pure returns (bytes memory) {
        bytes memory buff;

        assembly {
            buff := mload(0x40)
            let byteLen := 0x08
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            } {
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x28))
        }
        return buff;
    }

    /* @notice          Convert limited uint256 value into bytes
     *  @param v         The uint256 value
     *  @return          Converted bytes array
     */
    function WriteUint255(uint256 v) internal pure returns (bytes memory) {
        require(
            v <=
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            "Value exceeds uint255 range"
        );
        bytes memory buff;

        assembly {
            buff := mload(0x40)
            let byteLen := 0x20
            mstore(buff, byteLen)
            for {
                let mindex := 0x00
                let vindex := 0x1f
            } lt(mindex, byteLen) {
                mindex := add(mindex, 0x01)
                vindex := sub(vindex, 0x01)
            } {
                mstore8(add(add(buff, 0x20), mindex), byte(vindex, v))
            }
            mstore(0x40, add(buff, 0x40))
        }
        return buff;
    }

    /* @notice          Encode bytes format data into bytes
     *  @param data      The bytes array data
     *  @return          Encoded bytes array
     */
    function WriteVarBytes(bytes memory data)
        internal
        pure
        returns (bytes memory)
    {
        uint64 l = uint64(data.length);
        return abi.encodePacked(WriteVarUint(l), data);
    }

    /* @notice          Encode uint format data into bytes
     *  @param data      The uint data
     *  @return          Converted bytes array
     */
    function WriteVarUint(uint64 v) internal pure returns (bytes memory) {
        if (v < 0xFD) {
            return WriteUint8(uint8(v));
        } else if (v <= 0xFFFF) {
            return abi.encodePacked(WriteByte(0xFD), WriteUint16(uint16(v)));
        } else if (v <= 0xFFFFFFFF) {
            return abi.encodePacked(WriteByte(0xFE), WriteUint32(uint32(v)));
        } else {
            return abi.encodePacked(WriteByte(0xFF), WriteUint64(uint64(v)));
        }
    }
}
