//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Graph {

    using SafeMath for uint256;

    address public owner;
    address public admin;
    uint256 public totalBudget;
    uint256 public monthlyBudget;
    uint256 public historicalBudget; 
    uint256 public amountWithdrawMonthly;
    bool private locked;
    mapping(address => uint256) public addressToId;
    mapping(address => bool) public organisations;
    mapping(address => uint256) public monthlyWithdraw;
    mapping(address => uint256) public userTotalWithdraw;
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
        uint256 budget;  //TODO: Make the budget is delayed by 3 months
    
    }

    uint256[] public sourceIds;
    uint256[] public targetIds;
    uint256[] public weights;

    uint256 public numNodes;
    uint256 public numEdges;
    uint256 public historicalGranted;

    event depositEvent(address indexed donor, uint256 amount);
    event withdrawEvent(address indexed organisation, uint256 amount);


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

    function addNode(bool isHuman, string memory name, string memory description,string memory image, uint256 budget ) public {
        address _address = msg.sender;
        nodes.push(Node(_address, isHuman, name, description,image, budget));
        addressToId[_address] = numNodes;
        numNodes++;
        organisations[msg.sender] = true;
    }

    function addEdge(address recipient, uint256 weight) public {
        uint256 senderId = addressToId[msg.sender];
        uint256 recipientId = addressToId[recipient];
        sourceIds.push(senderId);
        targetIds.push(recipientId);
        weights.push(weight);
    }

    function addMultipleEdges(address[] calldata recipients, uint256[] calldata weightsToAdd) public {
        uint256 senderId = addressToId[msg.sender];
        uint256 length = recipients.length;

        for (uint256 i = 0; i < length; i++) {
            uint256 recipientId = addressToId[recipients[i]];
            sourceIds.push(senderId);
            targetIds.push(recipientId);
            weights.push(weightsToAdd[i]);
        }

    }

    function getPageRank(address _address) public view returns (uint256) {
        return 1;
    }

    function getTotalPageRank(address _address) public view returns (uint256) {
        return 100;
    }

    function getMyPageRank() public view returns (uint256) {
        return getPageRank(msg.sender);
    }

    mapping(address => uint256) public addressToWithdrawalAmount;

    function fund() public payable {
        totalBudget += msg.value;
        historicalBudget += msg.value;
        emit depositEvent(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) public  noReentrancy{ // Accounts are entitled to funds proportional to their pagerank. They should not be able to withdraw more than their budget: min(M*p/sum(p), budget)
        require(organisations[msg.sender] == true, "You are not an organinsation");
        require(totalBudget > 0, "No Money In the Contract");
        require(monthlyBudget > 0, "No Money allocated for this month");
        require(withdrawStatus == State.OPENED, "Withdraw is not Opened");
        require(monthlyBudget > _amount, "Insufficent for Withdrawal");
        require(mywithdrawstatus[msg.sender], "Exceeded you withdraw limit");

        /** @dev 
         * Calculate the expected Withdraw of a user or organisation
        */
        uint256 expectedWithdraw = uint256(monthlyBudget).mul(uint256(getPageRank(msg.sender))).div(uint256(getTotalPageRank(msg.sender)));
       
        require(expectedWithdraw > monthlyWithdraw[msg.sender]);
        require(expectedWithdraw > _amount);

        monthlyWithdraw[msg.sender] += _amount;
        userTotalWithdraw[msg.sender] += _amount;
        totalBudget -= _amount;
        amountWithdrawMonthly += _amount;

        payable(msg.sender).transfer(_amount);

        /** @dev 
         * Set the withdraw status of the user to true when the user has used up to expected withdraw
         */
        if(expectedWithdraw == monthlyWithdraw[msg.sender] || expectedWithdraw > monthlyWithdraw[msg.sender] ){
            mywithdrawstatus[msg.sender] = true;
            monthlyWithdraw[msg.sender] = 0;
        }else{
            mywithdrawstatus[msg.sender] = false;
        }
        /** @dev 
         * Set the withdraw status of the contract to close once the monthly budget is 0
         */
        if(monthlyBudget == amountWithdrawMonthly){
            monthlyBudget = 0;
            amountWithdrawMonthly = 0;
            withdrawStatus = State.CLOSED;
        }else{
            withdrawStatus = State.OPENED;
        }
    
        emit withdrawEvent(msg.sender, _amount);

    }
    
    // Function to reset withdrawal amounts. Can only be called by Chainlink automation

    function resetWithdrawalAmounts() public onlyAdmin{
        monthlyBudget += totalBudget;
        amountWithdrawMonthly = 0;
        withdrawStatus = State.OPENED;

        // require(false, "TODO: Make sure this can only be called by Chainlink automation");

        // addressToWithdrawalAmount = new mapping(address => uint256); // TODO: Figure out how to reset a mapping https://stackoverflow.com/questions/48045784/solidity-setting-a-mapping-to-empty

    }

    function delegateAdmin (address _newadmin) public onlyOwner {
        admin = _newadmin;
    }
    receive() external payable {}

    fallback() external payable {}
}