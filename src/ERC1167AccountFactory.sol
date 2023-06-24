// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IEntryPoint} from "@account-abstraction/interfaces/IEntryPoint.sol";
import {MySimpleAccount} from "src/MySimpleAccount.sol";

contract ERC1167AccountFactory {
    address public accountImplementation;

    constructor(address accountImplementation_) {
        accountImplementation = accountImplementation_;
    }

    // Get init code used to call createAccount for this owner with salt
    function getInitCode(address owner, uint256 salt) public view returns (bytes memory) {
        return abi.encodePacked(address(this), abi.encodeCall(this.createAccount, (owner, salt)));
    }

    // Create an account if needed, and return its address
    function createAccount(address owner, uint256 salt) public returns (address account) {
        account = getAddress(owner, salt);

        // Clone if not already exists
        if (account.code.length == 0) {
            // Assert deployed to same address
            assert(Clones.cloneDeterministic(accountImplementation, _ownerSalt(owner, salt)) == account);

            MySimpleAccount(payable(account)).initialize(owner);
        }
    }

    // Get account address, event if not deployed yet
    function getAddress(address owner, uint256 salt) public view returns (address) {
        return Clones.predictDeterministicAddress(accountImplementation, _ownerSalt(owner, salt));
    }

    // Add owner to salt, to get one clone per owner
    function _ownerSalt(address owner, uint256 salt) internal pure returns (bytes32) {
        return keccak256(abi.encode(owner, salt));
    }
}
