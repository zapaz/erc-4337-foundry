// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {BytesLib} from "lib/solidity-bytes-utils/contracts/BytesLib.sol";
import {MySimpleAccountFactory} from "src/MySimpleAccountFactory.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract MySimpleAccountFactoryTest is Test {
    MySimpleAccountFactory factory;
    IEntryPoint entryPoint = IEntryPoint(makeAddr("EntryPoint"));

    function setUp() public {
        factory = new MySimpleAccountFactory(entryPoint);
    }

    function test_SimpleAccountFactoryTestOK() public pure {
        assert(true);
    }

    function test_createAccount(address owner, uint256 salt) public {
        address addr1 = factory.getAddress(owner, salt);
        address addr2 = address(factory.createAccount(owner, salt));

        assertEq(addr1, addr2);
    }

    function test_getCreationCode(address owner, address implementation) public {
        uint256 proxyLength = type(ERC1967Proxy).creationCode.length;
        uint256 callLength = abi.encode(implementation, abi.encodeCall(MySimpleAccount.initialize, (owner))).length;

        bytes memory creationCode = factory.getCreationCode(owner);

        assertEq(creationCode.length, proxyLength + callLength);
        assertEq(callLength, 5 * 32);
    }
}
