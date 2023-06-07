import React, { useState, useEffect } from "react";
import { ethers } from "ethers";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import Container from "@mui/material/Container";

export default function CreateFlow(props) {
  const [currentAccount, setCurrentAccount] = useState("");
  const [accountBalance, setAccountBalance] = useState("");

  const checkIfWalletIsConnected = async () => {
    console.log("runs");
    const { ethereum } = window;
    if (!ethereum) {
      console.log("Make sure you have MetaMask installed!");
      return;
    } else {
      console.log("We have the ethereum object", ethereum);
    }
    const accounts = await window.ethereum.request({
      method: "eth_accounts",
    });
    const chain = await window.ethereum.request({
      method: "eth_chainId",
    });
    let chainId = chain;
    console.log("chain ID:", chain);
    console.log("global Chain Id:", chainId);
    if (accounts.length !== 0) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const balance = await provider.getBalance(accounts[0]);
      const formattedBalance = ethers.utils.formatEther(balance);
      setCurrentAccount(accounts[0]);
      setAccountBalance(formattedBalance);
      console.log("Found an authorized account:", accounts[0]);
    } else {
      console.log("No authorized account found");
    }
  };

  useEffect(() => {
    checkIfWalletIsConnected();
  }, []);

  const connectWallet = async () => {
    try {
      const { ethereum } = window;

      if (!ethereum) {
        alert("Get MetaMask!");
        return;
      }
      const accounts = await ethereum.request({
        method: "eth_requestAccounts",
      });
      console.log("Connected", accounts[0]);
      setCurrentAccount(accounts[0]);
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const balance = await provider.getBalance(accounts[0]);
      const formattedBalance = ethers.utils.formatEther(balance);
      setAccountBalance(formattedBalance);
    } catch (error) {
      console.log(error);
    }
  };

  return (
    <div>
      <Container component="main" maxWidth="xs">
        <Box
          sx={{
            marginTop: 8,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
          }}
        >
          <Typography variant="h6" component="h1" gutterBottom>
            Connect to Wallet
          </Typography>
          <Typography variant="body1" component="p" gutterBottom>
            Balance: {accountBalance} ETH
          </Typography>
          {currentAccount ? (
            <Typography variant="body1" component="p" gutterBottom>
              Connected to {currentAccount}
            </Typography>
          ) : (
            <button onClick={connectWallet}>Connect Wallet</button>
          )}
        </Box>
      </Container>
    </div>
  );
}

// import React, { useState } from 'react';
// import Web3 from 'web3';

// const FDAI_CONTRACT_ADDRESS = '0x4E15361FD6b4BB609Fa63C81A2be19d873717870';
// const FDAI_CONTRACT_ABI = [
//   {
//     "constant": false,
//     "inputs": [
//       {
//         "name": "_to",
//         "type": "address"
//       },
//       {
//         "name": "_value",
//         "type": "uint256"
//       }
//     ],
//     "name": "transfer",
//     "outputs": [
//       {
//         "name": "",
//         "type": "bool"
//       }
//     ],
//     "payable": false,
//     "stateMutability": "nonpayable",
//     "type": "function"
//   }
// ];

// function App() {
//   const [recipient, setRecipient] = useState('');
//   const [amount, setAmount] = useState('');
//   const [web3, setWeb3] = useState(null);
//   const [accounts, setAccounts] = useState([]);

//   const connectWallet = async () => {
//     try {
//       if (window.ethereum) {
//         const web3 = new Web3(window.ethereum);
//         await window.ethereum.enable();
//         const accounts = await web3.eth.getAccounts();
//         setWeb3(web3);
//         setAccounts(accounts);
//       } else {
//         alert('Please install Metamask to use this feature');
//       }
//     } catch (error) {
//       console.error(error);
//     }
//   };

//   const transferFDAI = async () => {
//     if (!web3) {
//       alert('Please connect your wallet first');
//       return;
//     }

//     try {
//       const fDaiContract = new web3.eth.Contract(FDAI_CONTRACT_ABI, FDAI_CONTRACT_ADDRESS);
//       const amountInWei = web3.utils.toWei(amount.toString(), 'ether');
//       const tx = await fDaiContract.methods.transfer(recipient, amountInWei).send({ from: accounts[0] });
//       console.log(tx);
//       alert('Transfer successful');
//     } catch (error) {
//       console.error(error);
//       alert('Transfer failed');
//     }
//   };

//   return (
//     <div className="App">
//       <header className="App-header">
//         <h1>Transfer FDAI</h1>
//       </header>
//       <div className="App-content">
//         <div className="App-wallet">
//           <h2>Connect Wallet</h2>
//           {accounts.length > 0 ? (
//             <p>Connected to {accounts[0]}</p>
//           ) : (
//             <button onClick={connectWallet}>Connect to Metamask</button>
//           )}
//         </div>
//         <div className="App-transfer">
//           <h2>Transfer FDAI</h2>
//           <label>
//             Recipient Address:
//             <input type="text" value={recipient} onChange={(e) => setRecipient(e.target.value)} />
//           </label>
//           <label>
//             Amount:
//             <input type="text" value={amount} onChange={(e) => setAmount(e.target.value)} />
//           </label>
//           <button onClick={transferFDAI}>Transfer</button>
//         </div>
//       </div>
//     </div>
//   );
// }

// export default App;

// import React, { useState } from 'react';
// import Web3 from 'web3';

// const MATIC_CONTRACT_ADDRESS = '0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0';
// const MATIC_CONTRACT_ABI = [
//   {
//     "inputs": [],
//     "name": "name",
//     "outputs": [
//       {
//         "internalType": "string",
//         "name": "",
//         "type": "string"
//       }
//     ],
//     "stateMutability": "view",
//     "type": "function"
//   },
//   {
//     "inputs": [],
//     "name": "symbol",
//     "outputs": [
//       {
//         "internalType": "string",
//         "name": "",
//         "type": "string"
//       }
//     ],
//     "stateMutability": "view",
//     "type": "function"
//   },
//   {
//     "inputs": [],
//     "name": "decimals",
//     "outputs": [
//       {
//         "internalType": "uint8",
//         "name": "",
//         "type": "uint8"
//       }
//     ],
//     "stateMutability": "view",
//     "type": "function"
//   },
//   {
//     "inputs": [
//       {
//         "internalType": "address",
//         "name": "_to",
//         "type": "address"
//       },
//       {
//         "internalType": "uint256",
//         "name": "_value",
//         "type": "uint256"
//       }
//     ],
//     "name": "transfer",
//     "outputs": [
//       {
//         "internalType": "bool",
//         "name": "",
//         "type": "bool"
//       }
//     ],
//     "stateMutability": "nonpayable",
//     "type": "function"
//   }
// ];

// function App() {
//   const [recipient, setRecipient] = useState('');
//   const [amount, setAmount] = useState('');
//   const [web3, setWeb3] = useState(null);
//   const [accounts, setAccounts] = useState([]);

//   const connectWallet = async () => {
//     try {
//       if (window.ethereum) {
//         const web3 = new Web3(window.ethereum);
//         await window.ethereum.enable();
//         const accounts = await web3.eth.getAccounts();
//         setWeb3(web3);
//         setAccounts(accounts);
//       } else {
//         alert('Please install Metamask to use this feature');
//       }
//     } catch (error) {
//       console.error(error);
//     }
//   };

//   const transferMATIC = async () => {
//     if (!web3) {
//       alert('Please connect your wallet first');
//       return;
//     }

//     try {
//       const maticContract = new web3.eth.Contract(MATIC_CONTRACT_ABI, MATIC_CONTRACT_ADDRESS);
//       const amountInWei = web3.utils.toWei(amount.toString(), 'ether');
//       const tx = await maticContract.methods.transfer(recipient, amountInWei).send({ from: accounts[0] });
//       console.log(tx);
//       alert('Transfer successful');
//     } catch (error) {
//       console.error(error);
//       alert('Transfer failed');
//     }
//   };

//   return (
//     <div className="App">
//       <header className="App-header">
//         <h1>Transfer MATIC</h1>
//       </header>
//       <div className="App-content">
//         <div className="App-wallet">
//           <h2>Connect Wallet</h2>
//           {accounts.length > 0 ? (
//             <p>Connected to {accounts[0]}</p>
//           ) : (
//             <button onClick={connectWallet}>
//             Connect
//           </button>
//           )}
//         </div>
//         <div className="App-transfer">
//           <h2>Transfer MATIC</h2>
//           <label>Recipient Address</label>
//           <input type="text" value={recipient} onChange={(e) => setRecipient(e.target.value)} />
//           <label>Amount</label>
//           <input type="number" value={amount} onChange={(e) => setAmount(e.target.value)} />
//           <button onClick={transferMATIC}>Transfer</button>
//         </div>
//       </div>
//     </div>
//   );
//           };
    
// export default App;


