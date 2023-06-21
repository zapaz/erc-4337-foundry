// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract ECDSATest is Test {
    using ECDSA for bytes32;

    address public owner;

    function setUp() public {
        owner = msg.sender;
    }

    function test_ECDSATestOK() public pure {
        assert(true);
    }

    function test_Signature() public {
        address alice = vm.addr(42);

        bytes32 hash = keccak256("Signed by Alice");

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(42, hash);

        address signer = ecrecover(hash, v, r, s);
        assertEq(alice, signer);
    }
}
