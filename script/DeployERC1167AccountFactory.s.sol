// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployLite} from "forge-deploy-lite/script/DeployLite.sol";
import {ERC1167AccountFactory} from "src/ERC1167AccountFactory.sol";
import {IEntryPoint} from "src/interfaces/IEntryPoint.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";

contract DeployERC1167AccountFactory is DeployLite {
    function deployERC1167AccountFactory() public returns (address) {
        address mySimpleAccount = readAddress("MySimpleAccount");

        vm.startBroadcast(vm.envAddress("ETH_FROM"));

        ERC1167AccountFactory erc1167AccountFactory = new ERC1167AccountFactory(mySimpleAccount);

        vm.stopBroadcast();

        return address(erc1167AccountFactory);
    }

    function run() public virtual {
        deploy("ERC1167AccountFactory");
    }
}
