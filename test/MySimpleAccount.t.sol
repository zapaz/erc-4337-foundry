// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import {BytesLib} from "lib/solidity-bytes-utils/contracts/BytesLib.sol";

contract MySimpleAccountTest is Test {
    using BytesLib for bytes;

    error SenderAddressResult(address sender);

    bytes4 selector;
    address sender;

    function setUp() public {
        selector = SenderAddressResult.selector;
        sender = msg.sender;
    }

    function testOK() public pure {
        assert(true);
    }

    function testEncode() public {
        bytes memory data = abi.encode(selector, sender);
        console.logBytes(data);
    }

    function testEncodePack() public {
        bytes memory data = abi.encodePacked(selector, sender);
        console.logBytes(data);
    }

    function testEncodeWithSelector() public {
        bytes memory data = abi.encodeWithSelector(selector, sender);
        console.logBytes(data);
    }

    function testEncodeWithSignature() public {
        bytes memory data = abi.encodeWithSignature("SenderAddressResult(address)", sender);
        console.logBytes(data);
    }

    function testDecode() public {
        bytes memory data = abi.encode(selector, sender);
        console.logBytes(data);
        (bytes4 selector_, address sender_) = abi.decode(data, (bytes4, address));
        console.logBytes4(selector_);
        console.log(sender_);
        assertEq(sender, sender_);
        assertEq(selector, selector_);
    }

    function decodeCall(bytes calldata data) public {
        bytes4 selector_ = bytes4(data[:4]);
        console.logBytes4(selector_);
        address sender_ = address(bytes20(data[16:36]));
        console.log(sender_);
    }

    function testDecodeCall() public {
        bytes memory data = abi.encodeWithSelector(selector, sender);
        console.logBytes(data);

        bytes4 selector_ = bytes4(data.slice(0, 4));
        console.logBytes4(selector_);
        address sender_ = data.toAddress(16);
        console.log(sender_);

        // this.decodeCall(data);
    }
}
