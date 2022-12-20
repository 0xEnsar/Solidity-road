// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Treasury {
    uint public balance = 0;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance += msg.value;
    }

    function withdraw(uint amount, address payable destAddress) public onlyOwner {
        require(balance > amount, "balance is not enough");
        balance -= amount;
        destAddress.transfer(amount);
    }

    modifier onlyOwner {
        require(msg.sender == owner, "You're not owner");
        _;
    }
}