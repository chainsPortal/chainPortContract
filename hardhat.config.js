require("@nomicfoundation/hardhat-toolbox");
const {mnemonic } = require("./secret.json")
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
 
    solidity: {
    compilers: [
      {
        version: "0.8.19",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ]

    },
    networks: {
      bsc: {
        url: "https://green-aged-panorama.bsc-testnet.quiknode.pro/0063b84f1631faf4d8cd6789fa84d7df2b2d1e2c/",
      chainId : 97,
      accounts: [mnemonic],
    },
    optimism: {
      url: "https://magical-neat-rain.optimism-goerli.quiknode.pro/edfa98d50f3b7c96fe756dbdbe4914869fcf9738/",
    chainId : 420,
    accounts: [mnemonic],
  },
    avax: {
      url: "https://rough-black-haze.avalanche-testnet.quiknode.pro/5c710f85e3809bc0f59fac4fccfa5f9a80fe71bb/ext/bc/C/rpc/",
    chainId : 43113,
   accounts: [mnemonic],
  },
  matic: {
    url: "https://cosmopolitan-empty-grass.matic-testnet.quiknode.pro/0d4514be84b6e499924d29205a138bfbb96d2dc1/",
  chainId : 80001,
 accounts: [mnemonic],
}
  },
  etherscan: {
    // apiKey: "D8M63Z5KSJ3583F5S7194GJG5N38CJQXQH" //bsc
    // apiKey: "81291aeefc084880903da2329ae0d3bb" //
    // apiKey: "SBWKPGB4NEXEZWWIPPWMRV5QY3WMH8271C" //polygon
    // apiKey: "WC9BP5TQVJUKDP63KED42ZQKNM7NC5HA6U" //eth
    // apiKey: "PZUXVNQZ662DPURSEEZTGUG7GY2MBI853U"// opt
    // apiKey: "RG54X18EJKVTVADRCD28FXQEY3Q7DJ6G4C"// arb
    // apiKey: ""// kcc
    // apiKey: "KXN1I8PNITSUARNZ398W4TV4W93YN8ZIY1"// ftm
    // apiKey: ""// avax


//     controllerContract deployed at: 0xA6f825d5D2c3744948Ccbabc21126Ba014648051
// Settings contract  deployed at: 0xE6e3112ab4A376CBEF510e4d2D601e3E4224039D
// feeController contract  deployed at: 0x3395330383BcF5DAc53D67414D2E07cbb58359Fb
// registry contract  deployed at: 0x986029CF0DCA1bC283c30A26986aae22bAcE9932
// bridgeContract contract  deployed at: 0xE4983ad8E65D6A9F89379FD049F17E0bBB14FBF0
// nft contract  deployed at: 0x9AB76119fB6253E4Ed7dcB93E69b37b793c7B3B2
    apiKey: {
      // opbnb: "81291aeefc084880903da2329ae0d3bb"
      bscTestnet:"D8M63Z5KSJ3583F5S7194GJG5N38CJQXQH",
      polygonMumbai: "SBWKPGB4NEXEZWWIPPWMRV5QY3WMH8271C" ,//polygon
      fuji: "YXDIA6516V73UV73V19TNZZ5Q7WSPVJ9TS"
    },

    customChains: [
      {
       network: "opbnb",
       chainId: 5611, // Replace with the correct chainId for the "opbnb" network
       urls: {
         apiURL:  "https://open-platform.nodereal.io/81291aeefc084880903da2329ae0d3bb/op-bnb-testnet/contract/",
         browserURL: "https://opbnbscan.com/",
       },
      },
     ]
  },



  
};


// {
//   'name': 'BSC',
//   'symbol' : 'tBNB',
//   'startblock' : 15636429,
//   'registrar' :"0xe15E396aF3D2D44Fc576A3EF1Bbda94462F01A88",
//   // 'url': "https://green-aged-panorama.bsc-testnet.quiknode.pro/0063b84f1631faf4d8cd6789fa84d7df2b2d1e2c/",
//   'url' : "wss://green-aged-panorama.bsc-testnet.quiknode.pro/0063b84f1631faf4d8cd6789fa84d7df2b2d1e2c/",
//   'bridgeAddress': "0xdA1deb17D0aC09A2Ab3BbAc163a0699eAa15e5Dc",
//   'id': "97",
//   "retries" : 1

// },


// {
//   'name': 'Polygon',
//   'symbol' : 'Matic',
//   'startblock' : 15636429,
//   'registrar' :"0x3548577d8Eb6bA02635A0Ddf27A92F4bE35d998d",
//   'url': "wss://cosmopolitan-empty-grass.matic-testnet.quiknode.pro/0d4514be84b6e499924d29205a138bfbb96d2dc1/",
//   // 'url' : "https://cosmopolitan-empty-grass.matic-testnet.quiknode.pro/0d4514be84b6e499924d29205a138bfbb96d2dc1/",
//   'bridgeAddress': "0x18a823DF8AfEDDC324fFDd607b0EDbA1Fe866C02",
//   'id': "80001",
//   "retries" : 1

// },

// {
//   'name': 'Optimism Goerli',
//   'symbol' : 'O-Eth',
//   'startblock' : 15636429,
//   'registrar' :"0x3548577d8Eb6bA02635A0Ddf27A92F4bE35d998d",
//   'url': "wss://magical-neat-rain.optimism-goerli.quiknode.pro/edfa98d50f3b7c96fe756dbdbe4914869fcf9738/",
//   // 'url' : "https://magical-neat-rain.optimism-goerli.quiknode.pro/edfa98d50f3b7c96fe756dbdbe4914869fcf9738/",
//   'bridgeAddress': "0x18a823DF8AfEDDC324fFDd607b0EDbA1Fe866C02",
//   'id': "420",
//   "retries" : 1

// },

// {
//   'name': 'Avalache Furji',
//   'symbol' : 'Avax',
//   'startblock' : 15636429,
//   'registrar' :"0x3548577d8Eb6bA02635A0Ddf27A92F4bE35d998d",
//   'url': "wss://rough-black-haze.avalanche-testnet.quiknode.pro/5c710f85e3809bc0f59fac4fccfa5f9a80fe71bb/ext/bc/C/ws/",
//   // 'url' : "https://rough-black-haze.avalanche-testnet.quiknode.pro/5c710f85e3809bc0f59fac4fccfa5f9a80fe71bb/ext/bc/C/rpc/",
//   'bridgeAddress': "0x18a823DF8AfEDDC324fFDd607b0EDbA1Fe866C02",
//   'id': "43113",
//   "retries" : 1

// }