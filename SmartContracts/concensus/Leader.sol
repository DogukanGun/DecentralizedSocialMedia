// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Miner.sol";
import "./Registery.sol";

interface IMessageFactory{
    function createMessagePool(string calldata topic) external;
}

contract Leader{

    uint256 turnNumber = 0;
    uint256 maxCandidateNumber = 10;
    bool isVotingOn;
    bool isRecommendationOn;
    uint256 totalStake;
    address messageFactory;
    address public registeryAddress;
    address public chosenMiner;

    struct Vote{
        address miner;
        uint256 slotNumber;
    }
    struct Candidate{
        string value;
        address recommender;
        uint256 totalVote;
    }
    struct MinerData{
        address minerAddress;
        uint256 stakeAmount;
    }
    MinerData[] public miners;
    //key represents turn number
    mapping(uint256=>Vote[]) public votesOfTurns;
    mapping(uint256=>Candidate[]) public topicsForVote;
    mapping(uint256=>Candidate[]) public candidates;

    constructor(address _messageFactory){
        totalStake = 0;
        messageFactory = _messageFactory;
        createRegistery();
        createFirstTerm();
    }

    modifier onlyMiner(){
        bool flag = false;
        for (uint index=0; index<miners.length;index++) 
        {
            if(miners[index].minerAddress==msg.sender){
                flag = true;
            }
        }
        require(flag,"This function is allowed for only mines");
        _;
    }

    modifier notCasted(){
        bool flag = true;
        for (uint index=0; index<votesOfTurns[turnNumber].length;index++) 
        {
            if(votesOfTurns[turnNumber][index].miner == msg.sender){
                flag = false;
            }
        }
        require(!flag,"You casted a vote before");
        _;
    }

    modifier lessThanMaxCandidate(){
        require(candidates[turnNumber].length<maxCandidateNumber,"No more candidate");
        _;
    }

    modifier cannotOfferMoreThanOne(){
        bool flag = false;
        for (uint256 index=0; index<candidates[turnNumber].length; index++) 
        {
            if(candidates[turnNumber][index].recommender == msg.sender){
                flag = true;
            }
        }
        require(!flag,"User made the recommendation before");
        _;
    }

    modifier votingOn(){
        require(isVotingOn,"Voting is not active");
        _;
    }

    modifier votingOff(){
        require(!isVotingOn,"Voting is active");
        _;
    }

    modifier recommendationOn(){
        require(isRecommendationOn,"Recommendation is not active");
        _;
    }

    modifier recommendationOff(){
        require(!isRecommendationOn,"Recommendation is active");
        _;
    }

    function createFirstTerm() private{
        candidates[turnNumber].push(Candidate("Topic1",msg.sender,0));
        candidates[turnNumber].push(Candidate("Topic2",msg.sender,0));
        candidates[turnNumber].push(Candidate("Topic3",msg.sender,0));
        candidates[turnNumber].push(Candidate("Topic4",msg.sender,0));
        candidates[turnNumber].push(Candidate("Topic5",msg.sender,0));
        topicsForVote[turnNumber].push(Candidate("Topic1",msg.sender,0));
        topicsForVote[turnNumber].push(Candidate("Topic2",msg.sender,0));
        topicsForVote[turnNumber].push(Candidate("Topic3",msg.sender,0));
        topicsForVote[turnNumber].push(Candidate("Topic4",msg.sender,0));
        topicsForVote[turnNumber].push(Candidate("Topic5",msg.sender,0));
    }

    function createRegistery() public returns(address){
        address _registeryAddress = address(new Registery(address(this)));
        registeryAddress = _registeryAddress;
        return registeryAddress;
    }

    function saveUserAsMine(address minerAddress) public {
        miners.push(MinerData(minerAddress,0));
    }

    function startVoting() external votingOff{
        isVotingOn = true;
    }

    function finishVoting() external votingOn{
        isVotingOn = false;
        for (uint256 index = 0; index<topicsForVote[turnNumber].length; index++) 
        {
            IMessageFactory messageFactoryContract = IMessageFactory(messageFactory);
            messageFactoryContract.createMessagePool(topicsForVote[turnNumber][index].value);
        }
        //TODO send result to message router
        startRecommendation();
    }

    function startRecommendation() public recommendationOff {
        turnNumber+=1;
        isRecommendationOn = true;
        chooseMinerForRecommendation();
    }

    function finishRecommendation() public {
        isRecommendationOn = false;
        for (uint256 index=0; index < candidates[turnNumber].length; index++) 
        {
            topicsForVote[turnNumber].push(candidates[turnNumber][index]);
        }
    }

    function castVote(uint256 slotNumber) public onlyMiner notCasted votingOn{
        topicsForVote[turnNumber][slotNumber].totalVote+=1;
    }

    function addStake() external payable{
        for (uint256 index=0; index<miners.length; index++) 
        {
            if(msg.sender == miners[index].minerAddress){
                miners[index].stakeAmount += msg.value;
                totalStake += msg.value;
            }
        }
    }
    
    function chooseMinerForRecommendation() private votingOff{
        chosenMiner = selectRandomMiner();
        bytes memory payload = abi.encodeWithSignature("recommenderModeOn()");
        (bool success,) = chosenMiner.call(payload);
        require(success);
    }

    function pseudoRandom(uint256 limit) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % limit;
    }

    function recieveRecommender(string calldata value) external lessThanMaxCandidate recommendationOn {
        candidates[turnNumber].push(Candidate(value,msg.sender,0));
    }

    function selectRandomMiner() public view returns(address) {
        uint256 randomIndex = pseudoRandom(miners.length-1);

        return miners[randomIndex].minerAddress;
    }

    function setMaximumCandidateNumber(uint256 _maxCandiateNumber) public recommendationOff{
        maxCandidateNumber = _maxCandiateNumber;
    }

    function getMaximumCandidateNumber() public view returns(uint256){
        return maxCandidateNumber;
    }

}