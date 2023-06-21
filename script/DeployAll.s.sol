// SPDX-License-Identifier: MITs
pragma solidity 0.8.15;

import "forge-std/Script.sol";

import {DeployMySimpleAccount} from "./DeployMySimpleAccount.s.sol";
import {DeployMySimpleAccountFactory} from "./DeployMySimpleAccountFactory.s.sol";

contract DeployAllNext is DeployMySimpleAccount, DeployMySimpleAccountFactory {
    function run() public override(DeployMySimpleAccount, DeployMySimpleAccountFactory) {
        // deploy("MySimpleAccount"); // MySimpleAccount implementation deployed by factory
        deploy("MySimpleAccountFactory");
    }
}
