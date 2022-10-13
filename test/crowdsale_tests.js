const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Crypto Lottery crowdsale tests", () => {
  let account1;
  let account2;
  let contract;

  beforeEach(async () => {
    [account1, account2] = await ethers.getSigners();
  
    const CryptoLottery = await ethers.getContractFactory("CryptoLottery", account1);
    contract = await CryptoLottery.deploy();
    await contract.deployed();
  });

  it("crypto lottery contract should be deployed", async () => {
    expect(contract.address).to.be.properAddress;
  });

  it("should be OFF crowdsale status", async () => {
    const tx = await contract.turnOff();
    const status = await contract.crowd_sale_status();
    expect(status).to.be.equal(1);
  });

  it("should be ON crowdsale status", async () => {
    const tx = await contract.turnOn();
    const status = await contract.crowd_sale_status();
    expect(status).to.be.equal(0);
  });


  /*it("1000 tokens was got", async () => {
    const balance = await token.balanceOf(accounts[0].address);
    expect(balance).to.equal("1000000000000000000000")
  });

  it("should be empty lockers count", async () => {
    const array = await contract.get_lockers();
    expect(array.length).to.be.equal(0);
  });

  it("lock 10 tokens", async () => {

    let _token = token.address;
    let _unlockTime = 1649078191;
    let _amount = 10;

    await token.approve(contract.address, _amount);

    const tx = await contract.deposit(
      _amount,
      _unlockTime,
      _token
    );
    expect(tx).to.have.any.keys("hash");
  });

  it("smart contract have 1 locker", async () => {

    let _token = token.address;
    let _unlockTime = 1649078191;
    let _amount = 10;

    await token.approve(contract.address, _amount);

    const tx = await contract.deposit(
      _amount,
      _unlockTime,
      _token
    );
    const array = await contract.get_lockers();
    expect(array.length).to.be.equal(1);
  });

  it("should be the token address", async () => {
    const address = await contract.main_token_address();
    expect(address).to.be.a('string');
  }); */

});
