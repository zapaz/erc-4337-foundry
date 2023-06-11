// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {ISimpleAccountFactory} from "src/interfaces/ISimpleAccountFactory.sol";

contract CounterScript is Script {
    address constant simpleAccountFactory = 0x5FF137D4b0FDCD49DcA30c7CF57E578a026d2789;
    address constant simpleAccount = 0x38973417E51499001A56EBA38ae9832D99375767;

    function setUp() public {}

    function run() public {
        // creationCode
        bytes memory simpleAccountCode = vm.getCode("SimpleAccount.sol:SimpleAccount");
        console.logBytes(simpleAccountCode);

        bytes memory simpleAccountCodeDeployed = simpleAccount.code;
        console.logBytes(simpleAccountCodeDeployed);
        
        if (keccak256(simpleAccountCode) == keccak256(simpleAccountCodeDeployed)) console.log("OK");

        bytes memory args = abi.encode(simpleAccountFactory);
        console.logBytes(args);

        bytes memory initCode = abi.encodePacked(simpleAccountCode, args);
        console.logBytes(initCode);
    }
}
