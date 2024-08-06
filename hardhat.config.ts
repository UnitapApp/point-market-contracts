import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('@openzeppelin/hardhat-upgrades');

const config: HardhatUserConfig = {
  solidity: "0.8.24",
};

export default config;
