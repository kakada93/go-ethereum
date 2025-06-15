require("@nomicfoundation/hardhat-toolbox");
require("@nomicfoundation/hardhat-ignition-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    geth: {
      url: "http://localhost:8545",
      chainId: 1337,
    },
        //mining: {
    //  auto: false, // Disable automining
    //  interval: 5000, // Optional: mine every 5 seconds if you want scheduled mining
    //},
  },
  ignition: {
    requiredConfirmations: 1, // This is the key for Hardhat Ignition specifically
    chainId: 1337
    // Optional: Also consider these if still stuck
    // blockPollingInterval: 1000, // How often Ignition checks for new blocks (default 1000ms)
    // timeBeforeBumpingFees: 0, // Disable fee bumping immediately for devnet
    // disableFeeBumping: true,  // Fully disable fee bumping
  },
};


