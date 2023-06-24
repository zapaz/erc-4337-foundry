// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployLite} from "forge-deploy-lite/script/DeployLite.sol";
import {MySimpleAccountFactory} from "src/MySimpleAccountFactory.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";

contract DeployMySimpleAccountFactory is DeployLite {
    function deployMySimpleAccountFactory() public returns (address) {
        address mySimpleAccount = readAddress("MySimpleAccount");

        vm.startBroadcast(vm.envAddress("ETH_FROM"));

        MySimpleAccountFactory mySimpleAccountFactory = new MySimpleAccountFactory(IEntryPoint (mySimpleAccount));

        vm.stopBroadcast();

        return address(mySimpleAccountFactory);
    }

    function run() public virtual {
        deploy("MySimpleAccountFactory");
    }
}
