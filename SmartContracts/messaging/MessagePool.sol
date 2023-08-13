// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./LoginManager.sol";

contract MessagePool{

    struct SocialMessage{
        address useraddress;
        string message;
        uint256 chainID;
    }
    
    address[] whiteList;
    SocialMessage[] topicMessages;
    string topicName;
    address public loginManagerAddress;
    address public messageRouterAddress;

    constructor(string memory _topicName,address _messageRouterAddress){
        topicName = _topicName;
        messageRouterAddress = _messageRouterAddress;
        loginManagerAddress = address(new LoginManager(address(this),messageRouterAddress));
        bytes memory payload = abi.encodeWithSignature("registerMessagePool(address,string,address)",address(this), topicName,loginManagerAddress);
        (bool success,) = _messageRouterAddress.call(payload);
        // TODO revert et success true degılse
    }

    modifier onlyLoginManager(){
        require(msg.sender == loginManagerAddress);
        _;
    }

    modifier onlyWhiteList(address userAddress){
        bool flag = false;
        for (uint256 index=0; index<whiteList.length; index++) 
        {
            if(userAddress == whiteList[index]){
                flag = true;
            }
        }
        require(flag,"User not registered");
        _;
    }

    function addUserToWhitelist(address userAddress) external onlyLoginManager{
        whiteList.push(userAddress);
    }

    //Send message
    function sendMessage(string calldata message,address userAddress) external payable onlyWhiteList(userAddress){
        topicMessages.push(SocialMessage(userAddress,message,block.chainid));
    }
    
    //Send Message from cross platform
    function sendMessageFromCrossChain(
        string calldata message,
        address sender,
        uint256 chainID
    ) external payable{
        topicMessages.push(SocialMessage(sender,message,chainID));
    }

    //Get Messages
    function getMessages() external view returns(SocialMessage [] memory){
        return topicMessages;
    }

    //Set Topic 
    function setTopic(string calldata _topicName) external {
        topicName = _topicName;
    }

    //Get Topic
    function getTopic() external view returns(string memory){
        return topicName;
    }
}