
// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address, uint) external returns (bool);

    function transferFrom(
        address,
        address,
        uint
    ) external returns (bool);
}

contract CrowdFund {
    
    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }

    uint constant public MAXDURATION = 90 days; 

    IERC20 public immutable token;
    uint public count;
    mapping(uint => Campaign) public campaigns;
    mapping(uint => mapping (address => uint)) public pledgedAmount;

    event Launch(uint id, uint goal, uint32 startAt, uint32 endAt);
    event Cancel(uint id);
    event Pledge(uint indexed  id, address indexed caller ,uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint indexed id);
    event Refund(uint indexed id, address indexed caller, uint amount); 

    constructor(IERC20 _token) {
        token = _token;
    }

    function launch(uint _goal, uint32 _startAt, uint32 _endAt) public {
        require(_startAt >= block.timestamp, " start date must be greater than now");
        require(_endAt > _startAt, " end date must be greater than start date");
        require(_endAt <= block.timestamp + MAXDURATION, " end at > max duration ");

        count++;
        campaigns[count] = Campaign({
            creator : msg.sender,
            goal : _goal,
            pledged : 0,
            startAt : _startAt,
            endAt : _endAt,
            claimed : false
        });

        emit Launch(count, _goal, _startAt, _endAt);

    }

    function cancel(uint _id) external campaignCreator(campaigns[_id]) {
        Campaign memory campaign = campaigns[_id];
        require(campaign.startAt < block.timestamp, " funding is already started");

        delete campaigns[_id];

        emit Cancel(_id);
    }

    function pledge(uint _id, uint amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.startAt, " not started");
        require(block.timestamp < campaign.endAt, " ended");

        campaign.pledged += amount;
        pledgedAmount[_id][msg.sender] += amount;

        token.transferFrom(msg.sender, address(this), amount);

        emit Pledge(_id, msg.sender, amount);
    }

    function unpledge(uint _id, uint amount) external {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp <= campaign.endAt, "ended");
        campaign.pledged -= amount;
        pledgedAmount[_id][msg.sender] -= amount;
        token.transfer(msg.sender, amount);

        emit Unpledge(_id, msg.sender, amount);
    }

    function claim(uint _id) external campaignCreator(campaigns[_id]) {
        Campaign storage campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged >= campaign.goal, "pledged < goal");
        require(!campaign.claimed, "claimed");

        campaign.claimed = true;
        token.transfer(campaign.creator, campaign.pledged);

        emit Claim(_id);
    }

    function refund(uint _id) external {
        Campaign memory campaign = campaigns[_id];
        require(block.timestamp > campaign.endAt, "not ended");
        require(campaign.pledged < campaign.goal, "pledged >= goal");

        uint bal = pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender] = 0;
        token.transfer(msg.sender, bal);

        emit Refund(_id, msg.sender, bal);
    }

    modifier campaignCreator(Campaign storage campaign) {
        require(msg.sender == campaign.creator, "you are not creator");
        _;
    }
}