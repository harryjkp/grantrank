const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
// const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");

describe("Graph", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployGraphFixture() {
    // const ONE_YEAR_IN_SECS = 365 * 24 * 60 * 60;
    // const ONE_GWEI = 1_000_000_000;

    // const lockedAmount = ONE_GWEI;
    // const unlockTime = (await time.latest()) + ONE_YEAR_IN_SECS;

    // // Contracts are deployed using the first signer/account by default
    // const [owner, otherAccount] = await ethers.getSigners();

    const all_accounts = await ethers.getSigners();
    const owner = all_accounts[0];
    const accounts = all_accounts.slice(1);

    const Graph = await ethers.getContractFactory("Graph");
    const graph = await Graph.deploy();

    return {  graph, owner, accounts };
  }

  describe("Deployment", function () {
    // it("Should set the right unlockTime", async function () {
    //   const { lock, unlockTime } = await loadFixture(deployOneYearLockFixture);

    //   expect(await lock.unlockTime()).to.equal(unlockTime);
    // });

    it("Should initialise public variables to zero", async function () {
      const { graph } = await loadFixture(deployGraphFixture);

      expect(await graph.numNodes()).to.equal(0);
      
    });
  });

  describe("Enrolling", function () {

    it ("Should allow accounts to enroll", async function () {
      const { graph, owner, accounts } = await loadFixture(deployGraphFixture);

      await graph.connect(accounts[0]).addNode(
        true,
        'Alice',
        'Alice is a human',
        'https://example.com/alice.jpg',
        100)

      expect((await graph.numNodes()) === 1);
      expect((await graph.nodes(0)).name === 'Alice');
      expect((await graph.nodes(0)).description === 'Alice is a human');
      expect((await graph.nodes(0)).image === 'https://example.com/alice.jpg');
      expect((await graph.nodes(0)).budget === 100);
      expect((await graph.nodes(0)).isHuman === true);

      await graph.connect(accounts[1]).addNode(
        false,
        'Effective Altruism',
        'Effective Altruism is a movement',
        'https://example.com/ea.jpg',
        1000)
      
      await graph.connect(accounts[2]).addNode(
        false,
        'GiveWell',
        'GiveWell is a charity evaluator',
        'https://example.com/givewell.jpg',
        1000)
      
      await graph.connect(accounts[3]).addNode(
        false,
        'Malaria Consortium',
        'Malaria Consortium is a charity',
        'https://example.com/malariaconsortium.jpg',
        1000)
      
      await graph.addNode(
        false,
        'Paperclip Maximizer Corporation',
        'Paperclip Maximizer Corporation is a corporation',
        'https://example.com/paperclipmaximizercorporation.jpg',
        1000)
      
     
      await graph.connect(accounts[3]).addNode(
        false,
        'Megacorp',
        'Megacorp is a corporation',
        'https://example.com/megacorp.jpg',
        1000)
      
      
      expect((await graph.numNodes()) === 6);

      await graph.connect(accounts[0]).addEdge(accounts[2].address, 100);
      await graph.connect(accounts[0]).addEdge(accounts[3].address, 20);
      await graph.connect(accounts[0]).addEdge(accounts[5].address, 20);
      await graph.connect(accounts[5]).addEdge(accounts[4].address, 100);
      await graph.connect(accounts[2]).addEdge(accounts[3].address, 100);


      // expect((await graph.numEdges()) === 5);

      expect((await graph.sourceIds(0)) === 0);
      expect((await graph.targetIds(0)) === 2);
      expect((await graph.weights(0)) === 100);

      expect((await graph.nodes(await graph.targetIds(0))).name === 'GiveWell');





     
    });
  });
  });
