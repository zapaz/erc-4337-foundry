// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts/utils/Create2.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {MySimpleAccount} from "src/MySimpleAccount.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";

/**
 * A sample factory contract for MySimpleAccount
 * A UserOperations "creationCode" holds the address of the factory, and a method call (to createAccount, in this sample factory).
 * The factory's createAccount returns the target account address even if it is already installed.
 * This way, the entryPoint.getSenderAddress() can be called either before or after the account is created.
 */

contract MySimpleAccountFactory {
    MySimpleAccount public immutable accountImplementation;

    constructor(IEntryPoint _entryPoint) {
        accountImplementation = new MySimpleAccount(_entryPoint);
    }

    /**
     * get creation code used to create account for this owner
     */
    function getCreationCode(address owner) public view returns (bytes memory) {
        return abi.encodePacked(
            type(ERC1967Proxy).creationCode,
            abi.encode(address(accountImplementation), abi.encodeCall(MySimpleAccount.initialize, (owner)))
        );
    }

    /**
     * get init code used to call createAccount for this owner with salt
     */
    function getInitCode(address owner, uint256 salt) public view returns (bytes memory) {
        return abi.encodePacked(address(this), abi.encodeCall(this.createAccount, (owner, salt)));
    }

    /**
     * create an account, and return its address.
     * returns the address even if the account is already deployed.
     * Note that during UserOperation execution, this method is called only if the account is not deployed.
     * This method returns an existing account address so that entryPoint.getSenderAddress() would work even after account creation
     */
    function createAccount(address owner, uint256 salt) public returns (MySimpleAccount) {
        address addr = getAddress(owner, salt);

        // Create2 if not already exists
        if (addr.code.length == 0) {
            // Assert deployed to same address
            assert(Create2.deploy(0, bytes32(salt), getCreationCode(owner)) == addr);
        }

        return MySimpleAccount(payable(addr));
    }

    /**
     * get counterfactual address of the account of this owner with salt
     */
    function getAddress(address owner, uint256 salt) public view returns (address) {
        return Create2.computeAddress(bytes32(salt), keccak256(getCreationCode(owner)));
    }
}
