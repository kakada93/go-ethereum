const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Contract Deployment Proof", function () {
  it("checks that contract code exists at given address", async function () {
    const contractAddress = "0xdB7d6AB1f17c6b31909aE466702703dAEf9269Cf"; // Replace with real address

    const code = await ethers.provider.getCode(contractAddress);
    console.log("Deployed bytecode at address:", code);

    // Assert that code exists (i.e. contract was deployed)
    expect(code).to.not.equal("0x");
  });
});

