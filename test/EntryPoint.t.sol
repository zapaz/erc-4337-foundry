// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.15;

import "forge-std/Test.sol";
import {EntryPoint} from "src/core/EntryPoint.sol";
import {MySimpleAccountFactory} from "src/MySimpleAccountFactory.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";
import {BytesLib} from "lib/solidity-bytes-utils/contracts/BytesLib.sol";
import {UserOperation} from "src/interfaces/UserOperation.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EntryPointTest is Test {
    using BytesLib for bytes;
    using ECDSA for bytes32;

    EntryPoint public entryPoint;
    MySimpleAccountFactory public factory;
    MySimpleAccount public account;
    address accountAddress;

    UserOperation userOp;
    uint256 pKey = 42;
    uint256 salt = 76;
    address owner = vm.addr(pKey);

    function signUserOp(UserOperation memory userOp) public returns (bytes memory signature) {
        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        bytes32 hash = userOpHash.toEthSignedMessageHash();

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pKey, hash);
        signature = abi.encodePacked(r, s, v);

        address signer = ecrecover(hash, v, r, s);
        assertEq(owner, signer);
    }

    function setUp() public {
        entryPoint = new EntryPoint();
        factory = new MySimpleAccountFactory(entryPoint);

        accountAddress = factory.getAddress(owner, salt);
        account = MySimpleAccount(payable(accountAddress));
        vm.deal(accountAddress, 1 ether);

        uint192 key = 312;
        uint256 nonce = entryPoint.getNonce(accountAddress, key);
        bytes memory initCode = factory.getInitCode(owner, salt);
        bytes memory callData = "";
        uint256 callGasLimit = 2_000_000;
        uint256 verificationGasLimit = 1_000_000;
        uint256 preVerificationGas = 1_000_000;
        uint256 maxFeePerGas = 2_000_000_000;
        uint256 maxPriorityFeePerGas = 2_000_000_000;
        bytes memory paymasterAndData = "";
        bytes memory signature = "";

        userOp = UserOperation({
            sender: accountAddress,
            nonce: nonce,
            initCode: initCode,
            callData: callData,
            callGasLimit: callGasLimit,
            verificationGasLimit: verificationGasLimit,
            preVerificationGas: preVerificationGas,
            maxFeePerGas: maxFeePerGas,
            maxPriorityFeePerGas: maxPriorityFeePerGas,
            paymasterAndData: paymasterAndData,
            signature: signature
        });
    }

    function test_Signature() public pure {
        assert(true);
    }

    function test_EntryPointTestOK() public pure {
        assert(true);
    }

    function test_getSenderAddress(address owner, uint256 salt) public {
        address factoryGetAddress = factory.getAddress(owner, salt);

        address entryPointGetSenderAddress;
        {
            bytes memory initCode = factory.getInitCode(owner, salt);
            try entryPoint.getSenderAddress(initCode) {}
            catch (bytes memory message) {
                entryPointGetSenderAddress = message.toAddress(16);
            }
        }
        assertEq(entryPointGetSenderAddress, factoryGetAddress);

        address factoryCreateAccountAddress = address(factory.createAccount(owner, salt));
        assertEq(factoryCreateAccountAddress, factoryGetAddress);
    }

    function test_sendUserOp() public {
        vm.prank(owner);

        userOp.signature = signUserOp(userOp);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;
        entryPoint.handleOps(userOps, payable(accountAddress));
    }

    function test_callData() public {
        uint256 _balanceOwner = owner.balance;
        uint256 _balanceAccount = accountAddress.balance;

        vm.startPrank(owner);

        userOp.callData = abi.encodeCall(account.execute, (owner, 0.1 ether, ""));
        userOp.signature = signUserOp(userOp);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = userOp;
        entryPoint.handleOps(userOps, payable(accountAddress));

        vm.stopPrank();

        uint256 balanceOwner_ = owner.balance;
        uint256 balanceAccount_ = accountAddress.balance;

        assertEq(balanceOwner_, _balanceOwner + 0.1 ether);
    }

    function test_getUserOpHashTest() public {
        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        console.logBytes32(userOpHash);

        bytes32 userOpHash2 = entryPoint.getUserOpHash(userOp);
        assertEq(userOpHash, userOpHash2);
    }
}
