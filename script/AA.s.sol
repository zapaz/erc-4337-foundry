// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "forge-std/Script.sol";
import {ISimpleAccountFactory} from "src/interfaces/ISimpleAccountFactory.sol";
import {IEntryPoint} from "src/interfaces/IEntryPoint.sol";
import {BytesLib} from "lib/solidity-bytes-utils/contracts/BytesLib.sol";

contract AAScript is Script {
    using BytesLib for bytes;

    // Goerli
    // address constant simpleAccountFactory = 0x9406Cc6185a346906296840746125a0E44976454;
    // address constant simpleAccountTemplate = 0x8ABB13360b87Be5EEb1B98647A016adD927a136c;
    // address constant simpleAccountDeployed = 0x98856afFc428AB2A375Df7B1f9A9788a9A4b95bf;
    // address constant simpleAccountProxy = 0x38973417E51499001A56EBA38ae9832D99375767;

    address constant entryPoint = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;

    function getInitCode() public view returns (bytes memory initCode) {
        bytes memory simpleAccountCode = vm.getDeployedCode("SimpleAccount.sol:SimpleAccount");
        bytes memory args = abi.encode(entryPoint);
        initCode = abi.encodePacked(simpleAccountCode, args);
        // console.logBytes(initCode);
        console.log("getInitCode", initCode.length);
    }

    function setUp() public {}

    function run() public {
        bytes memory initCode = getInitCode();

        // vm.startBroadcast();

        try IEntryPoint(entryPoint).getSenderAddress(initCode) {
            console.log("OK should not happen!");
        } catch (bytes memory message) {
            console.logBytes(message);
            console.logBytes(message.slice(0, 4));
            console.log(message.toAddress(16));
        }

        // vm.stopBroadcast();
    }
}
