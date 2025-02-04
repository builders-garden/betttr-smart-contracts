import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import { vars } from "hardhat/config";


const QUICKNODE_API_KEY = vars.get("QUICKNODE_API_KEY");

const config: HardhatUserConfig = {
  networks: {
    hardhat: {
      forking: {
        url: `https://wiser-dimensional-haze.matic.quiknode.pro/${QUICKNODE_API_KEY}`,
        blockNumber: 67522380
      }
    }
  },
  solidity: {
    version: "0.8.27",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      viaIR: true,
    },
  },
  gasReporter: {
    enabled: true,
    currency: "USD",
    gasPrice: 30,
  },
};

export default config;
