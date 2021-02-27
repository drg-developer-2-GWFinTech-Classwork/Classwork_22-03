pragma solidity >=0.4.22 <0.6.0;

contract MartianAuction {

    address deployer;
    address payable public beneficiary;
    address public highestBidder;
    uint public highestBid;
    mapping(address => uint) pendingReturns;
    bool public endeded;

    event HighestBidIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    constructor(
        address payable _beneficiary
    ) public {
        deployer = msg.sender;
        beneficiary = _beneficiary;
    }

    function bid(address payable sender) public payable {
        require(msg.value > highestBid, "There already is a higher bid.");
        require(!ended, "The auction has ended.");
        if highestBid != 0 {
            pendingReturns[highestBidder] += highestBid;
            //highestReturns[] = highestBidder;
            //highestBid = msg.value;
        }
        highestBidder = sender;
        highestBid = msg.value;
        emit HighestBidIncreased(sender, msg.value);
    }

    function withdraw(amount) public returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if amount > 0 {
            pendingReturns[msg.sender] = 0;
            if !msg.sender.send(amount) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function pendingReturn(address sender) public view returns (uint) {
        return pendingReturns[sender];
    }

    function auctionEnd() public {
        require(!ended, "The auction has ended.");
        require(deployer == msg.sender, "ERROR - Deployer is not sender.");
        ended = true;
        emit AcutionEnded(highestBidder, highestBid);
        beneficiary.transfer(highestBid);
    }
}
