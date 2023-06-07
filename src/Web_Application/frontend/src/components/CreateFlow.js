import React, { useState,useEffect } from "react";
import { Framework } from "@superfluid-finance/sdk-core";
import {
  Button,
  TextField,
  CircularProgress,
  Card,
} from "@mui/material";
import { ethers } from "ethers";
import UserService from "../services/Users";
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
let account;
//where the Superfluid logic takes place
async function createNewFlow(recipient, flowRate) {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = provider.getSigner();
    const chainId = await window.ethereum.request({ method: "eth_chainId" });
    const sf = await Framework.create({
        chainId: Number(chainId),
        provider: provider
    });
    const superSigner = sf.createSigner({ signer: signer });
    console.log(signer);
    console.log(await superSigner.getAddress());
    const daix = await sf.loadSuperToken("fDAIx");
    console.log(daix);
    try {
        const createFlowOperation = daix.createFlow({
            sender: await superSigner.getAddress(),
            receiver: recipient,
            flowRate: flowRate
            // userData?: string
        });
        console.log(createFlowOperation);
        console.log("Creating your stream...");
        const result = await createFlowOperation.exec(superSigner);
        console.log(result);
        console.log(
            `Congrats - you've just created a money stream!`
        );
    } catch (error) {
        console.log(
            "Hmmm, your transaction threw an error. Make sure that this stream does not already exist, and that you've entered a valid Ethereum address!"
        );
        console.error(error);
    }
}

export default function CreateFlow(props){
    const [recipient, setRecipient] = useState("");
    const [isButtonLoading, setIsButtonLoading] = useState(false);
    const [flowRate, setFlowRate] = useState("");
    const [flowRateDisplay, setFlowRateDisplay] = useState("");
    const [currentAccount, setCurrentAccount] = useState("");
    const connectWallet = async () => {
        try {
            const { ethereum } = window;
            if (!ethereum) {
                alert("Get MetaMask!");
                return;
            }
            const accounts = await ethereum.request({
                method: "eth_requestAccounts"
            });
            console.log("Connected", accounts[0]);
            setCurrentAccount(accounts[0]);
            const privateKey = await ethereum.request({
                method: "eth_getPrivateKey",
                params: [accounts[0]],
            });
            console.log("private key", privateKey);
            const data = await UserService.connect(props.user.id, { metamaskPK: privateKey, metamaskWAddress: accounts[0] })
            console.log("User connected", data)
            account = currentAccount;
            // Setup listener! This is for the case where a user comes to our site and connected their wallet for the first time.setupEventListener()
        } catch (error) {
            console.log(error);
        }
    };

    const checkIfWalletIsConnected = async () => {
        console.log("runs");
        const { ethereum } = window;
        if (!ethereum) {
            console.log("Make sure you have metamask!");
            return;
        } else {
            console.log("We have the ethereum object", ethereum);
        }
        const accounts = await window.ethereum.request({ method: "eth_accounts" });
        const chain = await window.ethereum.request({ method: "eth_chainId" });
        let chainId = chain;
        console.log("chain ID:", chain);
        console.log("global Chain Id:", chainId);
        if (accounts.length !== 0) {
            account = accounts[0];
            console.log("Found an authorized account:", account);
            setCurrentAccount(account);
            // Setup listener! This is for the case where a user comes to our site and ALREADY had their wallet connected + authorized. setupEventListener()
        } else {
            console.log("No authorized account found");
        }
    };

    useEffect(() => {
        checkIfWalletIsConnected();
    }, []);

    function calculateFlowRate(amount) {
        if (typeof Number(amount) !== "number" || isNaN(Number(amount)) === true) {
            alert("You can only calculate a flowRate based on a number");
            return;
        } else if (typeof Number(amount) === "number") {
            if (Number(amount) === 0) {
                return 0;
            }
            const amountInWei = ethers.BigNumber.from(amount);
            const monthlyAmount = ethers.utils.formatEther(amountInWei.toString());
            const calculatedFlowRate = monthlyAmount * 3600 * 24 * 30;
            return calculatedFlowRate;
        }
    }
    function CreateButton({ isLoading, children, ...props }) {
        return (
            <Button variant="success" className="button" {...props}>
                {isButtonLoading ? <CircularProgress animation="border" /> : children}
            </Button>
        );
    }
    const handleRecipientChange = (e) => {
        setRecipient(() => ([e.target.name] = e.target.value));
    };
    const handleFlowRateChange = (e) => {
        setFlowRate(() => ([e.target.name] = e.target.value));
        let newFlowRateDisplay = calculateFlowRate(e.target.value);
        setFlowRateDisplay(newFlowRateDisplay.toString());
    };
    return (
        <div>
            <Container component="main" maxWidth="xs">
                    <Box
                        sx={{
                            marginTop: 8,
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            maxWidth: 500,
                        }}
                    >
          <Box component="form" sx={{ mt: 3 }}>
            <Typography variant="h4">Create a Flow</Typography>
            {currentAccount === "" ? (
              <Button variant="contained" onClick={connectWallet} sx={{ my: 2 }}>
                Connect Wallet
              </Button>
            ) : (
              <Card sx={{ p: 2, my: 2 }} color="success">
                <Typography variant="body1" >
                  {`${currentAccount.substring(0, 4)}...${currentAccount.substring(38)}`}
                </Typography>
              </Card>
            )}
            <TextField
              label="Recipient Address"
              value={recipient}
              color="success"
              onChange={handleRecipientChange}
              focused
              fullWidth
              sx={{ my: 2}}
            />
            <TextField
              label="Flow Rate (wei/second)"
              value={flowRate}
              color="success"
              onChange={handleFlowRateChange}
              fullWidth
              focused
              sx={{ my: 2 }}
            />
            <Button
              variant="contained"
              onClick={() => {
                setIsButtonLoading(true);
                createNewFlow(recipient, flowRate);
                setTimeout(() => {
                  setIsButtonLoading(false);
                }, 1000);
              }}
              disabled={!recipient || !flowRate || isButtonLoading}
              sx={{ my: 2 }}
            >
              {isButtonLoading ? (
                <CircularProgress size={24} color="inherit" />
              ) : (
                "Click to Create Your Stream"
              )}
            </Button>
            <Box sx={{ my: 2 }}>
              {/* <Typography variant="body1">
                Go to the CreateFlow.js component and look at the <b>createNewFlow()</b> function to see under the hood
              </Typography> */}
              <Box sx={{ mt: 2 }}>
                <Typography variant="body1">Your flow will be equal to:</Typography>
                <Typography variant="h6">
                  <b>{flowRateDisplay !== "" ? flowRateDisplay : 0}</b> DAIx/month
                </Typography>
              </Box>
            </Box>
          </Box>
          </Box>
          </Container>
        </div>
      );
    };

    
