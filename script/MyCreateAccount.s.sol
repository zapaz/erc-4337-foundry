// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Test.sol";
import {EntryPoint} from "src/core/EntryPoint.sol";
import {MySimpleAccountFactory} from "src/MySimpleAccountFactory.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";
import {UserOperation} from "src/interfaces/UserOperation.sol";
import {ReadWriteJson} from "forge-deploy-lite/script/ReadWriteJson.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MyCreateAccountScript is Test, ReadWriteJson {
    address public constant ENTRY_POINT = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    uint256 public constant salt = 0;
    uint192 public constant key = 312;
    EntryPoint public entryPoint;
    MySimpleAccountFactory public factory;
    address public account;
    address public owner = vm.envAddress("PUBLIC_KEY");
    uint256 public ownerKey = vm.envUint("PRIVATE_KEY");

    function signUserOp(UserOperation memory userOp) public view returns (UserOperation memory) {
        bytes32 userOpHash = entryPoint.getUserOpHash(userOp);
        bytes32 hash = ECDSA.toEthSignedMessageHash(userOpHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerKey, hash);
        userOp.signature = abi.encodePacked(r, s, v);

        assert(owner == ecrecover(hash, v, r, s));

        return userOp;
    }

    function setupUserOp() public returns (UserOperation memory userOp) {
        userOp.sender = account;
        userOp.nonce = entryPoint.getNonce(account, key);
        userOp.initCode = factory.getInitCode(owner, salt);
        userOp.callData = "";
        userOp.callGasLimit = 100_000;
        userOp.verificationGasLimit = 300_000;
        userOp.preVerificationGas = 0;
        userOp.maxFeePerGas = 10_000_000_000;
        userOp.maxPriorityFeePerGas = 10_000_000_000;
        userOp.paymasterAndData = "";
        userOp.signature = "";

        emit log_named_bytes("setupUserOp ~ userOp.initCode:", userOp.initCode);
    }

    function run() public {
        entryPoint = EntryPoint(payable(ENTRY_POINT));
        factory = MySimpleAccountFactory(readAddress("MySimpleAccountFactory"));
        account = factory.getAddress(owner, salt);
        console.log("  owner:", owner);
        console.log("account:", account);

        UserOperation[] memory userOps = new UserOperation[](1);
        userOps[0] = signUserOp(setupUserOp());

        vm.startBroadcast(ownerKey);

        entryPoint.handleOps{gas: 1_000_000}(userOps, payable(account));

        vm.stopBroadcast();
    }
}
