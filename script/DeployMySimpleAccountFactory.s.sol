// SPDX-License-Identifier: MITs
pragma solidity 0.8.15;

import {DeployLite} from "forge-deploy-lite/script/DeployLite.sol";
import {MySimpleAccountFactory} from "src/MySimpleAccountFactory.sol";
import {IEntryPoint} from "src/interfaces/IEntryPoint.sol";

contract DeployMySimpleAccountFactory is DeployLite {
    function deployMySimpleAccountFactory() public returns (address) {
        address entryPoint = vm.envAddress("ENTRY_POINT");

        vm.startBroadcast(vm.envAddress("ETH_FROM"));

        MySimpleAccountFactory mySimpleAccountFactory = new MySimpleAccountFactory(IEntryPoint(entryPoint));

        vm.stopBroadcast();

        writeAddress("MySimpleAccount", address(mySimpleAccountFactory.accountImplementation()));

        return address(mySimpleAccountFactory);
    }

    function run() public virtual {
        deploy("MySimpleAccountFactory");
    }
}
