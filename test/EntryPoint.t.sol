// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {EntryPoint} from "@account-abstraction/core/EntryPoint.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";

import {MySimpleAccountFactory} from "src/MySimpleAccountFactory.sol";
import {ERC1167AccountFactory} from "src/ERC1167AccountFactory.sol";

import {BytesLib} from "lib/solidity-bytes-utils/contracts/BytesLib.sol";
import {UserOperation} from "@account-abstraction/interfaces/UserOperation.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IFactory {
    function accountImplementation() external view returns (MySimpleAccount);
    function getInitCode(address, uint256) external view returns (bytes memory);
    function getAddress(address, uint256) external view returns (address);
    function createAccount(address, uint256) external returns (address);
}

contract EntryPointTest is Test {
    using BytesLib for bytes;
    using ECDSA for bytes32;

    IFactory public factory;

    uint256 public constant salt = 0;
    uint192 public constant key = 312;
    EntryPoint public entryPoint;
    address public account;
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public ownerKey = vm.envUint("PRIVATE_KEY");

    function signUserOp(UserOperation memory userOp) public returns (UserOperation memory) {
        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        bytes32 hash = ECDSA.toEthSignedMessageHash(userOpHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, hash);
        userOp.signature = abi.encodePacked(r, s, v);
        address signer = ecrecover(hash, v, r, s);

        emit log_named_bytes32("signUserOp ~ userOpHash:", userOpHash);
        emit log_named_bytes32("signUserOp ~       hash:", hash);
        emit log_named_bytes("signUserOp ~  signature:", userOp.signature);
        emit log_named_address("signUserOp ~     signer:", signer);

        assert(owner == signer);
        return userOp;
    }

    function setupUserOp() public returns (UserOperation memory userOp) {
        userOp.sender = account;
        userOp.nonce = entryPoint.getNonce(account, key);
        userOp.initCode = IFactory(factory).getInitCode(owner, salt);
        userOp.callData = "";
        userOp.callGasLimit = 100_000;
        userOp.verificationGasLimit = 300_000;
        userOp.preVerificationGas = 0;
        userOp.maxFeePerGas = 10_000_000_000;
        userOp.maxPriorityFeePerGas = 10_000_000_000;
        userOp.paymasterAndData = "";
        userOp.signature = "";

        emit log_named_bytes("setupUserOp ~ initCode:", userOp.initCode);
    }

    function setUp() public {
        MySimpleAccount accountImplementation;

        entryPoint = new EntryPoint();

        bool clone = true;
        if (clone) {
            accountImplementation = new MySimpleAccount(entryPoint);
            factory = IFactory(address(new ERC1167AccountFactory(address(accountImplementation))));
        } else {
            factory = IFactory(address(new MySimpleAccountFactory(entryPoint)));
            accountImplementation = factory.accountImplementation();
        }

        account = factory.getAddress(owner, salt);
        vm.deal(account, 1 ether);

        emit log_named_address("setUp ~     entryPoint:", address(entryPoint));
        emit log_named_address("setUp ~        factory:", address(factory));
        emit log_named_address("setUp ~ implementation:", address(accountImplementation));
        emit log_named_address("setUp ~        account:", address(account));
        emit log_named_address("setUp ~          owner:", address(owner));
    }

    function test_EntryPointTestOK() public pure {
        assert(true);
    }

    function test_getSenderAddress(address owner_, uint256 salt_) public {
        address factoryGetAddress = factory.getAddress(owner_, salt_);

        address entryPointGetSenderAddress;
        {
            bytes memory initCode = factory.getInitCode(owner_, salt_);
            try entryPoint.getSenderAddress(initCode) {}
            catch (bytes memory message) {
                entryPointGetSenderAddress = message.toAddress(16);
            }
        }
        assertEq(entryPointGetSenderAddress, factoryGetAddress);

        address factoryCreateAccountAddress = address(factory.createAccount(owner_, salt_));
        assertEq(factoryCreateAccountAddress, factoryGetAddress);
    }

    function test_sendUserOp() public {
        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = signUserOp(setupUserOp());

        vm.prank(owner);
        entryPoint.handleOps(userOps, payable(account));
    }

    function test_callData() public {
        uint256 _balanceOwner = owner.balance;

        UserOperation memory userOp = setupUserOp();
        userOp.callData = abi.encodeCall(MySimpleAccount(payable(account)).execute, (owner, 0.1 ether, ""));

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = signUserOp(userOp);
        entryPoint.handleOps(userOps, payable(account));

        uint256 balanceOwner_ = owner.balance;

        assertEq(balanceOwner_, _balanceOwner + 0.1 ether);
    }

    function test_getUserOpHashTest() public {
        UserOperation memory userOp = setupUserOp();

        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        console.logBytes32(userOpHash);

        bytes32 userOpHash2 = entryPoint.getUserOpHash(userOp);
        assertEq(userOpHash, userOpHash2);
    }
}
