// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { run } = require("hardhat")

const delay = ms => new Promise(res => setTimeout(res, ms));


async function main() {
    const controllerContract = await ethers.getContractFactory("Controller");
    const controller = await controllerContract.attach("0xb5fAf46dF01bEaCbecF212B7927E0E9A586E13f4");
    await controller.addRegistrar("0x1E4D571eB0B676e49417e9Af01B4b4301c542C41" , true)
    await controller.addOracle("0x1E4D571eB0B676e49417e9Af01B4b4301c542C41" , true)
    const settingsContract = await ethers.getContractFactory("Settings");
    const setting = await settingsContract.attach("0x145dbe4dc0552a16bF70925eFf0c7A34A3AD9951");
    await setting.setNetworkSupportedChains(
        ["97" , "80001"],
        ["0x9B6c464BD65Abb38d556e1Ae5eDfed88943674C7" ,"0x9B6c464BD65Abb38d556e1Ae5eDfed88943674C7"],
        ["13264668187771770619" , "12532609583862916517"],
        ["1000000000000000000" , "1000000000000000000"],
        true
    );
    await delay(20000);
    console.log(await setting.isNetworkSupportedChain("97"));
    console.log(await setting.isNetworkSupportedChain("80001"));
}
// uint256[] memory chains,
// address[] memory chainRegistries,
// uint64[] memory chainSelectors,
// uint256[] memory fees,
// bool addchain
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});



// controllerContract deployed at: 0xb5fAf46dF01bEaCbecF212B7927E0E9A586E13f4
// Settings contract  deployed at: 0x145dbe4dc0552a16bF70925eFf0c7A34A3AD9951
// feeController contract  deployed at: 0xA21C02A4eBc98214e0f3C3882a421f9ABBfed43a
// registry contract  deployed at: 0x9B6c464BD65Abb38d556e1Ae5eDfed88943674C7
// bridgeContract contract  deployed at: 0x964726faa1a4705dbA1DEEE2aF0da0C966449D6B
// transfering ownership
// NFT  contract  deployed at: 0x270c31eaCE24818e020CdB4cDc5BCb0e23780D6b