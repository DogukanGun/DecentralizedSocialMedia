// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract LoginManager{
    
    mapping(string => address) public users;
    address public messagePoolAddress;
    address public  routerAddress;

    constructor(address _messageAddress,address _routerAddress){
        messagePoolAddress = _messageAddress;
        routerAddress = _routerAddress;
    }

    modifier onlyRouterAddress(){
        require(msg.sender == routerAddress,"Only router can run this function.");
        _;
    }

    function register(string memory nullifier,address userAddress) external payable returns(bool){
        if(users[nullifier] != userAddress || users[nullifier] != address(0)){
            return false;
        }
        if(users[nullifier] == address(0)){
            users[nullifier] = userAddress;
            saveUserToMessageWhiteList(userAddress);
        }
        return true;
    }

    function saveUserToMessageWhiteList(address userAddress) private {
        bytes memory payload = abi.encodeWithSignature("addUserToWhitelist(address)",userAddress);
        (bool success,) = messagePoolAddress.call(payload);
        require(success);
    }
}