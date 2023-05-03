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
        uint budget;
    }

    uint[] public sourceIds;
    uint[] public targetIds;
    uint[] public weights;

    uint public numNodes;
    uint public numEdges;



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


}