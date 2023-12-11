// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { run } = require("hardhat")

const verify = async (contractAddress, args) => {
    console.log("Verifying contract...")
    try {
        await run("verify:verify", {
            address: contractAddress,
            constructorArguments: args,
        })
    } catch (e) {
        if (e.message.toLowerCase().includes("already verified")) {
            console.log("Already verified!")
        } else {
            console.log(e)
        }
    }
}

const delay = ms => new Promise(res => setTimeout(res, ms));
async function main() {
  const nftContract = await ethers.getContractFactory("SimpleNFT");
  const nft = await nftContract.deploy("testNFT", "TNFT", "1000" );
  await nft.waitForDeployment();
  console.log("NFT  contract  deployed at:", nft.target );
  await delay(20000);
  console.log("Waited 1min");
  verify(nft.target , ["testNFT", "TNFT", "1000"]);

  // // const router = "0x70499c328e1e2a3c41108bd3730f6670a44595d1";
  // const router = "0x554472a2720e5e7d5d3c817529aba05eed5f82d8";
  // // const router = "0x9527e2d01a3064ef6b50c1da1c0cc523803bcff2";
  // const feeRemitance ="0xc3A1D9C337c4E1EeFC95AD4d1418a5e04F365C6a";
  // const controllerContract = await ethers.getContractFactory("Controller");
  // const Controller= await controllerContract.deploy();
  // await Controller.waitForDeployment();
  // console.log("controllerContract deployed at:", Controller.target);
  
  // const setttingsContract = await ethers.getContractFactory("Settings");
  // const Settings= await setttingsContract.deploy(Controller.target ,feeRemitance );
  // await Settings.waitForDeployment();
  // console.log("Settings contract  deployed at:", Settings.target);
  
  // const feeContract = await ethers.getContractFactory("FeeController");
  // const feeController= await feeContract.deploy(Controller.target , Settings.target);
  // await feeController.waitForDeployment();
  // console.log("feeController contract  deployed at:", feeController.target);


  // const registryContract = await ethers.getContractFactory("Registry");
  // const registry = await registryContract.deploy(router);
  // await registry.waitForDeployment();

  // console.log("registry contract  deployed at:", registry.target);

  // const bridgeContract = await ethers.getContractFactory("Bridge");
  // const bridge = await bridgeContract.deploy(router ,Controller.target , Settings.target, registry.target , feeController.target,);
  // await bridge.waitForDeployment();

  // console.log("bridgeContract contract  deployed at:", bridge.target );

  // await registry.transferOwnership(bridge.target );
  // console.log("transfering ownership" );

  //   const nftContract = await ethers.getContractFactory("SimpleNFT");
  // const nft = await nftContract.deploy("testNFT", "TNFT", "1000" );
  // await nft.waitForDeployment();
  // console.log("NFT  contract  deployed at:", nft.target );
  // console.log("waiting for 1min");

  // await delay(20000);
  // console.log("Waited 1min");
  // verify(Controller.target , []);
  // await delay(20000);
  // console.log("Waited 1min");
  // verify(Settings.target , [Controller.target , feeRemitance]);
  // await delay(20000);
  // console.log("Waited 1min");
  // verify(feeController.target , [Controller.target , Settings.target]);
  // await delay(20000);
  // console.log("Waited 1min");
  // verify(feeController.target , [Controller.target , Settings.target]);
  // await delay(20000);
  // console.log("Waited 1min");
  // verify(registry.target , [router]);
  // await delay(20000);
  // console.log("Waited 1min");
  // verify(nft.target , ["testNFT", "TNFT", "1000"]);
  // await delay(20000);
  // console.log("Waited 1min");
  // verify(bridge.target , [router , Controller.target , Settings.target, registry.target , feeController.target]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
