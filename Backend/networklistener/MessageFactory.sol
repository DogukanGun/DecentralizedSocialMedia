// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./MessagePool.sol";

contract MessageFactory{

    address messageRouterAddress;

    constructor(address _messageRouterAddress){
        messageRouterAddress = _messageRouterAddress;
    }

    function createMessagePool(string calldata topic) public {
        MessagePool newMessage = new MessagePool(topic,messageRouterAddress);
        address(newMessage);
    }
}