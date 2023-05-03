// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");


async function main() {


  const Graph = await hre.ethers.getContractFactory("Graph");
  const graph = await Graph.deploy();

  await graph.deployed();

  

  console.log(
    `graph-address=${graph.address}`// `Graph deployed to ${graph.address}`
  );

    //wait for 5 block transactions to ensure deployment before verifying

    await graph.deployTransaction.wait(5);

    //verify

    await hre.run("verify:verify", {
      address: graph.address,

});
  
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
