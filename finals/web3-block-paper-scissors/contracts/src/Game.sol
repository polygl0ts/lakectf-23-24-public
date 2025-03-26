// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract Game is Ownable {
    event CommittedMovesReady();
    event EncryptionKey(bytes encryptionKey);

    struct CommittedMove {
        bytes R;
        bytes ciphertext;
    }

    struct Player {
        address playerAddress;
        CommittedMove committedMoves;
        uint8[] revealedMoves;
    }

    Player[2] public players;
    uint8 public constant ROCK = 0;
    uint8 public constant PAPER = 1;
    uint8 public constant SCISSORS = 2;

    address public operator;

    constructor(address owner, address operator_) Ownable(owner) {
        operator = operator_;
    }

    function commitMoves(uint256 playerId, bytes calldata R, bytes calldata ciphertext) external {
        Player storage player = players[playerId];
        require(player.playerAddress == msg.sender, "You are not the player");
        require(player.committedMoves.ciphertext.length == 0, "moves already set");
        player.committedMoves.R = R;
        player.committedMoves.ciphertext = ciphertext;
        if (players[1 - playerId].committedMoves.ciphertext.length != 0) {
            emit CommittedMovesReady();
        }
    }

    function revealMoves(uint256 playerId, uint8[] calldata revealedMoves) external {
        require(msg.sender == operator);
        Player storage player = players[playerId];
        player.revealedMoves = revealedMoves;
    }

    function score() external view returns (int256 s) {
        for (uint8 i = 0; i < 16; i++) {
            int8 r = int8(players[0].revealedMoves[i] % 3) + 3 - int8(players[1].revealedMoves[i] % 3);
            s += (3 - 2 * int256(r % 3)) % 3;
        }
    }

    function setPlayer(uint256 playerId, address playerAddress) external onlyOwner {
        players[playerId].playerAddress = playerAddress;
    }

    function broadcastEncryptionKey(bytes calldata encryptionKey) external {
        require(msg.sender == operator);
        emit EncryptionKey(encryptionKey);
    }

    // getters
    function playerAddress(uint256 playerId) external view returns (address) {
        return players[playerId].playerAddress;
    }

    function committedMoves(uint256 playerId) external view returns (bytes memory, bytes memory) {
        CommittedMove storage move = players[playerId].committedMoves;
        return (move.R, move.ciphertext);
    }
}
