// SPDX-License-Identifier: MIT

pragma solidity >0.5.0 <0.9.0;

contract Lottery {
	//administrator address
    address payable manager;
    // Winner address
    address payable winner;
    //Beter address collection
    address payable [] lotteryPlayers;
	//winner's number
    uint public winningNum;
    // lottery period
    uint public roundNum;
    // Winners' winning ratio (example: when the winnings ratio is 80%, the value is 80.)
    uint public rewardRate;
    //The specific amount of the winner's bonus
    uint public winningReward;
    //Amount of each bet
    uint public lotteryBet;
    // Every time the administrator can draw the starting point
    uint public drawStartTime;
    // Each time the administrator can draw the end of the time
    uint public drawEndTime;
    constructor()  {
    	// Create a contractor automatically for the administrator
        manager = payable(msg.sender);
        //80% of the Ethereum in the prize pool to the winners
        rewardRate = 80;
        // Each time limit 1 ether
        lotteryBet = 1 ether;
        drawStartTime = block.timestamp;
        //Allow the draw time to be 30 minutes
        drawEndTime = block.timestamp +30 minutes;
    }

 function throwIn() public payable{
 	// Guarantee the lottery bet amount is the rated amount
    require(msg.value == lotteryBet);
    //You can only bet before the draw time
    
    // Add the lottery's address to the array
    lotteryPlayers.push(payable(msg.sender));
}

// decorator to ensure that only administrators have permission to operate
 modifier managerLimit {
    require(msg.sender == manager);
    _;
}

// transaction, used for testing
//event test(uint,uint);
function draw() public managerLimit  {
	//Ensure that someone is betting on the current order
    require(lotteryPlayers.length != 0,"No Players found");
    // Make sure that within the allowed lottery period
    require(block.timestamp >= drawStartTime && block.timestamp < drawEndTime,"Lotter time incorrect");
    // Use the current block time stamp, mining difficulty and the number of betting lottery players to take random values
    bytes memory randomInfo = abi.encodePacked(block.timestamp,block.difficulty,lotteryPlayers.length); 
    bytes32 randomHash =keccak256(randomInfo);
    // Use the random value to get the index of the winner in the array
    winningNum = uint(randomHash)%lotteryPlayers.length;
    // Determine the winner address
    winner=lotteryPlayers[winningNum];
    //According to the total amount of Ethereum in the current session, determine the bonus that the winner can receive.
    winningReward = address(this).balance*rewardRate/100;
    //Transfer to the winner
    winner.transfer(winningReward);
    // used for testing
    //emit test(reward,address(this).balance);
    // Pump the administrator
    manager.transfer(address(this).balance);
    // Lottery period +1
    roundNum++;
    //The next start and end time of the draw will increase by 1 day.
    drawStartTime+=1 days;
    drawEndTime+=1 days;
    // Clear this bettor array
    delete lotteryPlayers;
}


//Return the total amount of Ethereum in the current prize pool
function getBalance()public view returns(uint){
    return address(this).balance;
}
// Return to the winning address of the end of the lottery
function getWinner()public view returns(address){
    return winner;
}
// Return to the administrator's address
function getManager()public view returns(address){
    return manager;
}
//Return the current lottery address collection that is participating in the bet
function getLotteryPlayers() public view returns(address payable [] memory){
    return lotteryPlayers;
}
//Return the number of lottery players currently participating in the bet
function getPlayersNum() public view returns(uint){
    return lotteryPlayers.length;
}


//Only administrators can issue refunds
function refund()public managerLimit{
    //Make sure someone is involved in the bet at this time
    require(lotteryPlayers.length != 0);
    //The refund operation can only be performed after the draw end time
    require(block.timestamp>=drawEndTime);
    uint lenLotteryPlayers = lotteryPlayers.length;
    // Refund all participating bettors in this round, the amount is the rated amount
    for(uint i = 0; i<lenLotteryPlayers;i++){
        lotteryPlayers[i].transfer(lotteryBet);
    }
    // Because of the flow, the number of periods +1
    roundNum++;
    //Because of the flow, the next draw start time and the draw end time will increase by one day.
    drawStartTime+=1 days;
    drawEndTime+=1 days;
    // Clear the participating bettor collection
    delete lotteryPlayers;   
}

}