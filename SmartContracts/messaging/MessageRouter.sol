// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./MessageFactory.sol";
import "./MessagePool.sol";

contract MessageRouter{

    struct MessagePoolInfo{
        string topic;
        address messagePoolAddress;
        address loginManagerAddress;
    }

    address public  messageFactoryAddress;
    address bridgeAddress;
    MessagePoolInfo[] public messagePoolInfo;

    constructor(){
        messageFactoryAddress = address(new MessageFactory(address(this)));
    }

    function sendMessage(address messagePoolAddress, string calldata message, uint256 chainId ) public{
        if(block.chainid == chainId){
            MessagePool messagePool = MessagePool(messagePoolAddress);
            messagePool.sendMessage(message,msg.sender);
            
        }else{
            //cross chain message sending
            bytes memory payload = abi.encodeWithSignature("sendMessage(chainID, sender, message)",chainId, msg.sender, message);
            (bool success,) = bridgeAddress.call(payload);
            require(success);
        }
    }

    function registerMessagePool(address messagePoolAddress, string memory topic,address loginManagerAddress) public {
        messagePoolInfo.push(MessagePoolInfo(topic, messagePoolAddress,loginManagerAddress));
    }

    function getMessages() public view returns(MessagePoolInfo[] memory){
        return messagePoolInfo;
    }

    function setBridgeAddress(address _bridgeAddress) public{
        bridgeAddress = _bridgeAddress;
    }
}