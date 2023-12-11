// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const { run } = require("hardhat")

const delay = ms => new Promise(res => setTimeout(res, ms));
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
async function main() {

    const  senderContract = await ethers.getContractFactory("BasicMessageSender");
    const  sender = await  senderContract.deploy("0x9527e2d01a3064ef6b50c1da1c0cc523803bcff2", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06");
    await  sender.waitForDeployment();
  
    console.log("sender contract  deployed at:",  sender.target );
    await delay(60000);
    verify(sender.target , ["0x9527e2d01a3064ef6b50c1da1c0cc523803bcff2", "0x84b9B910527Ad5C03A9Ca831909E21e236EA7b06"]);



    // const  receiverContract = await ethers.getContractFactory("BasicMessageReceiver");
    // const  receiver = await  receiverContract.deploy("0x70499c328e1e2a3c41108bd3730f6670a44595d1");
    // await  receiver.waitForDeployment();

    
    // console.log("reciever contract  deployed at:",  receiver.target );
    // await delay(60000);
    // verify(receiver.target , ["0x70499c328e1e2a3c41108bd3730f6670a44595d1"]);

   
}
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
