// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

contract Counter {

    uint count = 0;

    function inc() public {
        count++;
    }

    function dec() public {
        require(count > 0, "Count must be at least 0");
        count--;
    } 
} 