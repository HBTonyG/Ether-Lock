// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract EtherWallet {
    address payable public owner;
    uint256 public releaseTime;
    uint256 blockTime;
    int256 EthPrice;
    int256 tgtPrice;
    bool public locked;
    AggregatorV3Interface internal priceFeed;
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    constructor(address _owner) {
        owner = payable(_owner);
        priceFeed = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    receive() external payable {}

    function withdraw(uint256 _amount) external payable {
        require(msg.sender == owner, "caller is not owner");
        require(locked == false, "Locked");
        //user will withdraw the amount in ether decimal format, so it must be converted into wei
        uint256 amountInWei = _amount * 1 ether;
        require(amountInWei <= address(this).balance);
        payable(owner).transfer(amountInWei);
    }

    function getChainlinkDataFeedLatestAnswer() public returns (int256) {
        (
            ,
            /*uint80 roundID*/ int price /*uint startedAt*/ /*uint timeStamp*/ /*uint80 answeredInRound*/,
            ,
            ,

        ) = priceFeed.latestRoundData();
        EthPrice = price * 1e18;
        return EthPrice;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function depositEth(
        uint256 _timeLimitInDays,
        int256 _tgtPrice
    ) public payable onlyOwner returns (bool) {
        //this allows the user to set a target price as the trigger for the unlock, but also allows a time limit in case the target is never met
        require(
            _timeLimitInDays > 0,
            "Release time must be at least one day in the future"
        );
        //       releaseTime = block.timestamp + (_timeInDays * 1 days);
        releaseTime = block.timestamp + _timeLimitInDays;
        tgtPrice = _tgtPrice;
        locked = true;

        return true;
    }

    function getBlockTime() public view returns (uint256) {
        return block.timestamp;
    }

    //allows the user see how much time until their timelimit has been hit
    function timeLeftUntilUnlock() public view returns (uint256) {
        uint256 timeLeft = (releaseTime - block.timestamp);
        return timeLeft;
    }

    function checkUpkeep() external view returns (bool upkeepNeeded) {
        //this is using upkeepNeeded to check if it is still locked
        upkeepNeeded = locked;
    }

    function performUpKeep() external {
        // if locked it will call the unlock function
        if (locked) {
            unlock();
        }
    }

    function unlock() public {
        // gets the eth price
        getChainlinkDataFeedLatestAnswer;
        // checks if eth price has passed the target, if it does it sets locked to false (unlocks)
        if (EthPrice > tgtPrice) {
            locked = false;
            // if the target price has not been met but the timelimit has it will unlock
        } else if (releaseTime < block.timestamp) {
            locked = false;
        }
    }
}
