// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Miner{

    uint256 stakeAmount;
    address userAddress;
    address leaderAddress;
    bool public isRecommender;

    constructor(address _leaderAddress,address _userAddress){
        leaderAddress = _leaderAddress;
        userAddress = _userAddress;
    }
    
    function castVote(uint slotID) public  {
        bytes memory payload = abi.encodeWithSignature("castVote(uint256)",slotID);
        (bool success,) = leaderAddress.call(payload);
        require(success);
    }

    function castVoteForRecommendation(string calldata value) public{
        bytes memory payload = abi.encodeWithSignature("recieveRecommender(string)",value);
        (bool success,) = leaderAddress.call(payload);
        require(success);
    }

    function recommenderModeOn() external{
        isRecommender = true;
    }

    function recommenderModeOff() external{
        isRecommender = false;
    }

    function increaseStakeAmount() private {
        stakeAmount += 1;
    }
    
}