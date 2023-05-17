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

  console.log(`Graph deployed to ${graph.address}`)

  // no need to verify on localhost or hardhat
  if (network.config.chainId != 31337 && process.env.ETHERSCAN_API_KEY) {
    console.log(`Waiting for block confirmation...`)
    await graph.deployTransaction.wait(5)

    console.log('Verifying contract...')
    try {
      run('verify:verify', {
        address: graph.address,
      })
    } catch (e) {
      console.log(e)
    }
  }
  console.log(`graph-address=${graph.address}`)
}

  

//   console.log(
//     `graph-address=${graph.address}`// `Graph deployed to ${graph.address}`
//   );

//     //wait for 5 block transactions to ensure deployment before verifying

//     await graph.deployTransaction.wait(5);
  
// }

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
