const { ethers } = require("hardhat");
const { expect } = require("chai");

describe("Geth Network Tests", function () {
  it("Prints current block number", async function () {
    const block = await ethers.provider.getBlockNumber();
    console.log("🧱 Current block number:", block);
    expect(block).to.be.a("number");
  });
});

