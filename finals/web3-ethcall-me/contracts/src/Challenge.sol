// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Challenge {
    event CallMe(address target, bytes4 selector);

    function testFlag(string memory flag) external pure returns (bool) {
        return keccak256(bytes(flag)) == hex"db08356ae572052938278954357b93c6b59258edaba0899ff63df16899dcd4cd";
    }

    function callme(address target, bytes4 selector) external {
        emit CallMe(target, selector);
    }
}
