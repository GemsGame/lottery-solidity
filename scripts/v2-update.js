
const hardhat = require("hardhat");

const PROXY = "0x5914B1dC0aB6C0244f680C15BF71464F76c31572";

async function main() {

  // Upgrading
  const CryptoadsV2 = await hardhat.ethers.getContractFactory("CryptoadsV2");
  const upgraded = await hardhat.upgrades.upgradeProxy(PROXY, CryptoadsV2);
  console.log('contract upgraded')

}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
