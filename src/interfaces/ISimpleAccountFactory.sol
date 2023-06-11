// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {ISimpleAccount} from "./ISimpleAccount.sol";

interface ISimpleAccountFactory {
    function createAccount(address owner, uint256 salt) external returns (ISimpleAccount ret);
    function getAddress(address owner, uint256 salt) external view returns (address);
}
