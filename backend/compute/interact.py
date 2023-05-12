from web3 import Web3, HTTPProvider, AsyncWeb3
from dotenv import load_dotenv
import os

load_dotenv()


class Graph:
    def __init__(self, contract):
        self.contract = contract
    
    def edges(self):
        num_edges = self.contract.functions.numEdges().call()
        source, target, weight = [], [], []
        for i in range(num_edges):
            source.append(self.contract.functions.sourceIds(i).call())
            target.append(self.contract.functions.targetIds(i).call())
            weight.append(self.contract.functions.weights(i).call())
        return source, target, weight
    
    def nodes(self):
        num_nodes = self.contract.functions.numNodes().call()
        nodes = []
        for i in range(num_nodes):
            nodes.append(self.contract.functions.nodes(i).call())
        return nodes


def fetch_edges():
    w3 = Web3(Web3.HTTPProvider(f'https://sepolia.infura.io/v3/{os.environ.get("INFURA_API_KEY")}'))

    abi = [{"inputs":[{"internalType":"address","name":"recipient","type":"address"},{"internalType":"uint256","name":"weight","type":"uint256"}],"name":"addEdge","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address[]","name":"recipients","type":"address[]"},{"internalType":"uint256[]","name":"weightsToAdd","type":"uint256[]"}],"name":"addMultipleEdges","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"bool","name":"isHuman","type":"bool"},{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"description","type":"string"},{"internalType":"string","name":"image","type":"string"},{"internalType":"uint256","name":"budget","type":"uint256"}],"name":"addNode","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"","type":"address"}],"name":"addressToId","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"historicalGranted","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"nodes","outputs":[{"internalType":"address","name":"_address","type":"address"},{"internalType":"bool","name":"isHuman","type":"bool"},{"internalType":"string","name":"name","type":"string"},{"internalType":"string","name":"description","type":"string"},{"internalType":"string","name":"image","type":"string"},{"internalType":"uint256","name":"budget","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"numEdges","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"numNodes","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"sourceIds","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"targetIds","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"","type":"uint256"}],"name":"weights","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]





    contract_address = '0x35612e5AB65Ad899500E0555D781cA6C986F00E5'
    addr = Web3.to_checksum_address(contract_address)
    contract = w3.eth.contract(address=addr, abi=abi) 


    graph = Graph(contract)

    source, target, weight = graph.edges()
    num_nodes = len(graph.nodes())

    print(graph.nodes())

    return source, target, weight
