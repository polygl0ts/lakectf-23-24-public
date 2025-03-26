// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {Challenge} from "src/Challenge.sol";

contract Deploy is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        string memory mnemonic = vm.envString("MNEMONIC");
        address player = vm.rememberKey(vm.deriveKey(mnemonic, 0));
        address operator = vm.rememberKey(vm.deriveKey(mnemonic, 2));
        address opponent = vm.rememberKey(vm.deriveKey(mnemonic, 3));
        Challenge challenge = new Challenge({player: player, operator: operator, opponent: opponent});

        vm.writeFile(vm.envOr("OUTPUT_FILE", string("/tmp/deploy.txt")), vm.toString(address(challenge)));
    }
}
