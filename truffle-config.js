const HDWalletProvider = require("@truffle/hdwallet-provider");
const MNEMONIC = "torch problem example wrist economy lady online route resist trophy execute october";

module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*"
    },    
    ropsten: {
      provider: function() {
        return new HDWalletProvider(MNEMONIC, "wss://ropsten.infura.io/ws/v3/9aa3d95b3bc440fa88ea12eaa4456161")
      },
      network_id: '3',
      gas: 4000000,
      networkCheckTimeout: 1000000,
      timeoutBlocks: 200
    }
  },
  mocha: {},
  compilers: {
    solc: {
      version:">=0.5.0 <0.9.0"
    }
  },
  db: {
    enabled: false
  }
};
