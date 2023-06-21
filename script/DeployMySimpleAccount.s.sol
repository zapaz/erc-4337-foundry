// SPDX-License-Identifier: MITs
pragma solidity 0.8.15;

import {DeployLite} from "forge-deploy-lite/script/DeployLite.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";
import {IEntryPoint} from "src/interfaces/IEntryPoint.sol";

contract DeployMySimpleAccount is DeployLite {
    function deployMySimpleAccount() public returns (address mySimpleAccount) {
        address entryPoint = vm.envAddress("ENTRY_POINT");

        vm.startBroadcast(vm.envAddress("ETH_FROM"));

        mySimpleAccount = address(new MySimpleAccount(IEntryPoint(entryPoint)));

        vm.stopBroadcast();
    }

    function run() public virtual {
        deploy("MySimpleAccount");
    }
}
