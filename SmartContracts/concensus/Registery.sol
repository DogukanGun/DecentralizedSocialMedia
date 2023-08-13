// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Miner.sol";

contract Registery{

    address leaderAddress;

    constructor(address _leaderAddress){
        leaderAddress = _leaderAddress;
    }
    
    function registerToConcensus() public returns(address){
        address minerAddress = address(new Miner(leaderAddress,msg.sender));
        bytes memory payload = abi.encodeWithSignature("saveUserAsMine(address)",minerAddress);
        (bool success,) = leaderAddress.call(payload);
        require(success);
        return minerAddress;
    }

}