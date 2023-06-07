export const Framework = require("@superfluid-finance/sdk-core");
export const ethers = require("ethers");

// Ethers.js provider initialization
export const url =
  "https://eth-kovan.alchemyapi.io/v2/nl2PDNZm065-H3wMj2z1_mvGP81bLfqX";
export const customHttpProvider = new ethers.providers.JsonRpcProvider(url);

export const faucetABI = [
  {
    inputs: [
      { internalType: "contract ISuperToken", name: "_token", type: "address" }
    ],
    stateMutability: "nonpayable",
    type: "constructor"
  },
  {
    inputs: [],
    name: "tapFaucet",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function"
  },
  {
    inputs: [],
    name: "token",
    outputs: [
      { internalType: "contract ISuperToken", name: "", type: "address" }
    ],
    stateMutability: "view",
    type: "function"
  }
];

export const faucetGoerliAddress = "0x04e77c3a4D46BA60fcd2cb48a2FDA6d117E65e69";
export const faucetMumbaiAddress = "0x19dA1670e2D8D969e9551d9c8Ec22E302673b48B";
