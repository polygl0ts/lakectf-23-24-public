// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Challenge {
    event CallMe(address target, bytes4 selector);

    function testFlag(string memory flag) external pure returns (bool) {
        return keccak256(bytes(flag)) == hex"01010101010101010101010101010101"; // FIXME: put real hash
    }

    function callme(address target, bytes4 selector) external {
        emit CallMe(target, selector);
    }
}
