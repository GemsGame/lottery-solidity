require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('@openzeppelin/hardhat-upgrades');
require('hardhat-abi-exporter');
require('dotenv').config();

module.exports = {
  defaultNetwork: "localhost",
  etherscan: {
    apiKey: {
      polygonMumbai: process.env.POLYGONSCAN_API_KEY
    }
  },
  networks: {
    mumbai: {
      url: "https://matic-mumbai.chainstacklabs.com",
      accounts: [process.env.PRIVATE_KEY],
      gasPrice: 'auto',
    },
    coinex: {
      url: "https://testnet-rpc.coinex.net",
      accounts: [process.env.PRIVATE_KEY],
      network_id: 53,
      gasPrice: 'auto',
    }
  },
  solidity: {
    version: "0.8.16",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
  mocha: {
    timeout: 60000
  },
  abiExporter: {
    path: './data/abi',
    runOnCompile: true,
    clear: true,
    flat: true,
    spacing: 2,
    pretty: true,
  }
};