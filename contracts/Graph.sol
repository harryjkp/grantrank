//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Graph {
    address public owner;
    address public admin;
    uint public totalBudget;
    uint public monthlyBudget;
    uint public historicalBudget; 
    bool private locked;
    mapping(address => uint) public addressToId;
    mapping(address => uint) public monthlyWithdraw;
    mapping(address => uint) public userTotalWithdraw;
    mapping(address => bool) public mywithdrawstatus; 

    enum State {OPENED, CLOSED}
    State public withdrawStatus;

    Node[] public nodes;

    struct Node {
        address _address;
        bool isHuman;
        string name;
        string description;
        string image;
        uint budget;  //TODO: Make the budget is delayed by 3 months
    
    }

    uint[] public sourceIds;
    uint[] public targetIds;
    uint[] public weights;

    uint public numNodes;
    uint public numEdges;
    uint public historicalGranted;

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "You are not the Owner");
        _;
    }

    modifier onlyAdmin() {
        require(owner == msg.sender || admin == msg.sender, "You are not an Admin");
        _;
    }
    modifier noReentrancy() {
        require(!locked, "Reentrant call detected!");
        locked = true;
        _;
        locked = false;
    }

    function addNode(bool isHuman, string memory name, string memory description,string memory image, uint budget ) public {
        address _address = msg.sender;
        nodes.push(Node(_address, isHuman, name, description,image, budget));
        addressToId[_address] = numNodes;
        numNodes++;
    }

    function addEdge(address recipient, uint weight) public {
        uint senderId = addressToId[msg.sender];
        uint recipientId = addressToId[recipient];
        sourceIds.push(senderId);
        targetIds.push(recipientId);
        weights.push(weight);
    }

    function addMultipleEdges(address[] calldata recipients, uint[] calldata weightsToAdd) public {
        uint senderId = addressToId[msg.sender];
        uint length = recipients.length;

        for (uint i = 0; i < length; i++) {
            uint recipientId = addressToId[recipients[i]];
            sourceIds.push(senderId);
            targetIds.push(recipientId);
            weights.push(weightsToAdd[i]);
        }

    }

    function getPageRank(address _address) public view returns (uint) {
        return 1;
    }

    function getTotalPageRank(address _address) public view returns (uint) {
        return 100;
    }

    function getMyPageRank() public view returns (uint) {
        return getPageRank(msg.sender);
    }

    mapping(address => uint) public addressToWithdrawalAmount;

    function fund() public payable {
        totalBudget += msg.value;
        historicalBudget += msg.value;
    }

    function withdraw(uint _amount) public  noReentrancy{ // Accounts are entitled to funds proportional to their pagerank. They should not be able to withdraw more than their budget: min(M*p/sum(p), budget)
       require(withdrawStatus == State.OPENED, "Withdraw is not Opened");
       require(monthlyBudget > _amount, "Insufficent for Withdrawal");
       require(mywithdrawstatus[msg.sender], "Exceeded you withdraw limit");
       uint intermediateResult = monthlyBudget.mul(getPageRank(msg.sender));
       uint expectedWithdraw = intermediateResult.div(getTotalPageRank(msg.sender));

        require(expectedWithdraw > monthlyWithdraw[msg.sender]);
                
        monthlyWithdraw += _amount;
        userTotalWithdraw += _amount;

        payable(msg.sender).tranfer(_amount);
        
        if(expectedWithdraw == monthlyWithdraw[msg.sender]){
            mywithdrawstatus[msg.sender] = true;
            monthlyWithdraw[msg.sender] = 0;
        }
       


        uint _amount = addressToWithdrawalAmount[msg.sender];     
        
        require(_amount <= available, "Insufficient funds");
        addressToWithdrawalAmount[msg.sender] += _amount;
        totalBudget -= _amount;

        payable(msg.sender).transfer(_amount);
    }


    
    // Function to reset withdrawal amounts. Can only be called by Chainlink automation

    function resetWithdrawalAmounts() public onlyAdmin{
        monthlyBudget += totalBudget;
        withdrawStatus = State.OPENED;

        // require(false, "TODO: Make sure this can only be called by Chainlink automation");

        // addressToWithdrawalAmount = new mapping(address => uint); // TODO: Figure out how to reset a mapping https://stackoverflow.com/questions/48045784/solidity-setting-a-mapping-to-empty

    }

    function delegateAdmin (address _newadmin) public onlyOwner {
        admin = _newadmin;
    }

}