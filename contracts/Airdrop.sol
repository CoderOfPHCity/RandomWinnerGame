// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract Airdrop is VRFConsumerBase {
    error PLEASE_REGISTER();

    uint256 startime;
    address owner;
    uint256 maxplayers = 10;
    uint256 lotteryCount;
    address[] public eligiblePlayers;
    address public winner;

    bytes32  keyHash;
    uint256 public fee;

    constructor() VRFConsumerBase(
        0x8C7382F9D8f56b33781fE506E897a4F1e2d17255, // vrfCoordinator
        0x326C977E6efc84E512bB9C30f76E30c160eD06FB  // linkToken
    ) {
        keyHash = 0x6e75b569a01ef56d18cab6a8e71e6600d6ce853834d4a5748b720d06f878b3a4;
        fee = 0.0001 * 10 ** 18; 
    }


    struct Lottery {
        uint256 lotteryId;
        string title;
        address[] players;
        bool hasEnded;
        // startime = block.timestamp;
    }

    mapping(uint256 => mapping(address => Lottery)) lottery;
    mapping (uint => Lottery) lotteryIndex;
    mapping(address => bool) hasRegistered;
    Lottery[] lotteryArray;

    function createLottery(uint256 _lotteryId, string memory _title) public {
        onlyOwner();
        Lottery memory lotteries = lottery[_lotteryId][msg.sender];

        lotteries.lotteryId = _lotteryId;
        lotteries.title = _title;
        lotteryArray.push(lotteries);
        lotteryCount++;
    }

    function registeruser(uint256 _lotteryId, address _player) public {
        Lottery storage Reglottery = lottery[_lotteryId][_player];

        if (hasRegistered[_player]) {
            Reglottery.players.push(_player);
        }
        hasRegistered[_player] = true;
    }

    function getAllPlayers (uint _id) public view returns(address[] memory){
        return lotteryIndex[_id].players; 

    }

    function getAllCreatedLotteries() public view returns(Lottery[] memory){
        return lotteryArray;

    }
  

    function enterLottery(uint256 _lotteryid) public {
        Lottery storage newLottery = lottery[_lotteryid][msg.sender];
        if (hasRegistered[msg.sender]) {
            revert("PLEASE_REGISTER");
        }

        eligiblePlayers = newLottery.players;

        require(eligiblePlayers.length < maxplayers, "max players reached");
        eligiblePlayers.push(msg.sender);

        if (eligiblePlayers.length == maxplayers) newLottery.hasEnded = true;
        requestRandomNumber();
    }

    function onlyOwner() private view {
        require(msg.sender == owner, "only owner");
    }


    uint256 public randomResult;

    function requestRandomNumber()
        public
        returns (bytes32 requestId)
    {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        return requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {
        randomResult = randomness;
        uint256 randomIndex = randomness % eligiblePlayers.length;

         winner = eligiblePlayers[randomIndex];
    }
}
    

