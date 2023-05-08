pragma solidity 0.8;

contract Graph {
    mapping(address => uint) public addressToId;

    Node[] public nodes;


    struct Node {
        address _address;
        bool isHuman;
        string name;
        string description;
        string image;
        uint budget;  //TODO: Make the budget is delayed by 3 months
        uint totalReceived; //TODO: Make sure this is updated
       

    }

    uint[] public sourceIds;
    uint[] public targetIds;
    uint[] public weights;

    uint public numNodes;
    uint public numEdges;
    uint public historicalGranted;



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

    function addMultipleEdges(address[] memory recipients, uint[] memory weightsToAdd) public {
        uint senderId = addressToId[msg.sender];
        for (uint i = 0; i < recipients.length; i++) {
            uint recipientId = addressToId[recipients[i]];
            sourceIds.push(senderId);
            targetIds.push(recipientId);
            weights.push(weightsToAdd[i]);
        }

    }


    uint public constant DECIMALS = 1000000000000000000;

    function getPageRank(address _address) public view returns (uint) {
        return 1;
    }

    function getMyPageRank() public view returns (uint) {
        return getPageRank(msg.sender);
    }

    mapping(address => uint) public addressToWithdrawalAmount;

    function fund() public payable {
        totalBudget += msg.value;
        historicalBudget += msg.value;
    }

    uint public totalBudget;
    uint public historicalBudget; 
    function withdraw() public { // Accounts are entitled to funds proportional to their pagerank. They should not be able to withdraw more than their budget: min(M*p/sum(p), budget)
        uint amount = addressToWithdrawalAmount[msg.sender];     


        available = totalBudget*getMyPageRank()/DECIMALS - addressToWithdrawalAmount[msg.sender];
        
        require(amount <= available, "Insufficient funds");
        addressToWithdrawalAmount[msg.sender] += amount;
        totalBudget -= msg.value;
        payable(msg.sender).transfer(amount);
    }

    
    // Function to reset withdrawal amounts. Can only be called by Chainlink automation

    function resetWithdrawalAmounts() public {
        monthlyBudget = totalBudget;
        require(false, "TODO: Make sure this can only be called by Chainlink automation");
        addressToWithdrawalAmount = new mapping(address => uint);
    }


}