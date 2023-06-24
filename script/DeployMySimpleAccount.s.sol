// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployLite} from "forge-deploy-lite/script/DeployLite.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";

contract DeployMySimpleAccount is DeployLite {
    function deployMySimpleAccount() public returns (address) {
        address entryPoint = vm.envAddress("ENTRY_POINT");
        address owner = vm.envAddress("ETH_FROM");

        vm.startBroadcast(owner);

        MySimpleAccount mySimpleAccount = new MySimpleAccount(IEntryPoint(entryPoint));

        vm.stopBroadcast();

        return address(mySimpleAccount);
    }

    function run() public virtual {
        deploy("MySimpleAccount");
    }
}
