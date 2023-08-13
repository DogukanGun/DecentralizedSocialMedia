// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract MessageBridge{

    event SendMessage(uint256 chainID,address sender,string message);

    function sendMessage(
        uint256 chainID,
        address sender,
        string calldata message
    ) public payable{
        emit SendMessage(chainID, sender, message);
    }
}