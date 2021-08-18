// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0 <0.9.0;

contract Coin {
    address public minter;
    mapping(address => uint) public balances;

    event Sent(address from,address to,uint amount);

    constructor() public {
        minter = msg.sender;
    }

    function mint (address payable receiver, uint amount) public payable {
        require(minter == msg.sender);
        require(amount < 1e50);
        balances[receiver] += amount;
    }

    function send (address payable receiver, uint amount) public payable {
        require(amount <= balances[msg.sender]);
        balances[msg.sender] -= amount;
        balances[receiver] += amount;

        emit Sent(msg.sender,receiver,amount);
    }
}