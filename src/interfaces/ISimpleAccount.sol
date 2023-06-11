// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import {IEntryPoint} from "./IEntryPoint.sol";

interface ISimpleAccount {
    function initialize(address anOwner) external;

    function entryPoint() external view returns (IEntryPoint);
    function execute(address dest, uint256 value, bytes calldata func) external;
    function executeBatch(address[] calldata dest, bytes[] calldata func) external;

    function getDeposit() external view returns (uint256);
    function addDeposit() external payable;
    function withdrawDepositTo(address payable withdrawAddress, uint256 amount) external;
}
