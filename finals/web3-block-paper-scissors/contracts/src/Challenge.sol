// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/Game.sol";

contract Challenge {
    Game public game;

    constructor(address operator, address player, address opponent) {
        game = new Game(address(this), operator);
        game.setPlayer(0, player);
        game.setPlayer(1, opponent);
    }

    function isSolved() public view returns (bool) {
        return game.score() == 16;
    }
}
