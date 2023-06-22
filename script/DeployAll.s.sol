// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "forge-std/Script.sol";

import {DeployMySimpleAccount} from "./DeployMySimpleAccount.s.sol";
import {DeployMySimpleAccountFactory} from "./DeployMySimpleAccountFactory.s.sol";
import {DeployERC1167AccountFactory} from "./DeployERC1167AccountFactory.s.sol";

contract DeployAllNext is DeployMySimpleAccount, DeployMySimpleAccountFactory, DeployERC1167AccountFactory {
    function run() public override(DeployMySimpleAccount, DeployMySimpleAccountFactory, DeployERC1167AccountFactory) {
        deploy("MySimpleAccount");
        // deploy("MySimpleAccountFactory");
        deploy("ERC1167AccountFactory");
    }
}
