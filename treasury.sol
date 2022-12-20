// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Treasury {
    uint balance = 0;
    address owner;

    constructor() {
        owner = msg.sender;
    }

    receive() payable external {
        balance += msg.value;
    }

    function withdraw(uint amount, address payable destAddress) public onlyOwner {
        balance -= amount;
        destAddress.transfer(amount);
    }



    modifier onlyOwner {
        require(msg.sender == owner, "You're not owner");
        _;
    }
}