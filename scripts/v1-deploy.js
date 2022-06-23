// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hardhat = require("hardhat");

async function main() {

  const CryptoadsV1 = await hardhat.ethers.getContractFactory("CryptoadsV1");
  const instance = await hardhat.upgrades.deployProxy(CryptoadsV1, [10, "0xF46360EdeCF820F3c69DAd3633CCB2d53d3d69Fb"], {initializer: "store"});

  await instance.deployed();

  console.log("v1 contract deployed to:", instance.address); 

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
