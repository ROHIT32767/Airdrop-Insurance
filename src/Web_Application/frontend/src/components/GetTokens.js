import React, { useState, useEffect } from "react";
import { Button, CircularProgress, Card } from "@mui/material";
import { ethers } from "ethers";
import { faucetABI, faucetMumbaiAddress } from "../services/config";
import Box from '@mui/material/Box';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';

// let account;

//where the Superfluid logic takes place
async function getTokens() {
    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const signer = provider.getSigner();

    const chainId = await window.ethereum.request({ method: "eth_chainId" });

    console.log("chain id: ", chainId);
    let faucetContract;

    faucetContract = new ethers.Contract(
        faucetMumbaiAddress,
        faucetABI,
        provider
    );

    console.log(faucetContract);

    if (Number(chainId) === 80001) {
        try {
            faucetContract.connect(signer).tapFaucet();
        } catch (error) {
            console.log(error);
        }
    } else {
        console.log("invalid network... choose mumbai please");
    }
}

export default function GetTokens(props) {
    const [isButtonLoading, setIsButtonLoading] = useState(false);
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
        } catch (error) {
            console.log(error);
        }
    };

    const checkIfWalletIsConnected = async () => {
        const { ethereum } = window;

        if (!ethereum) {
            console.log("Make sure you have metamask!");
            return;
        } else {
            console.log("We have the ethereum object", ethereum);
        }

        const accounts = await ethereum.request({ method: "eth_accounts" });
        const chain = await window.ethereum.request({ method: "eth_chainId" });
        let chainId = chain;
        console.log("chain ID:", chain);
        console.log("global Chain Id:", chainId);
        if (accounts.length !== 0) {
            const account = accounts[0];
            console.log("Found an authorized account:", account);
            setCurrentAccount(account);
        } else {
            console.log("No authorized account found");
        }
    };

    useEffect(() => {
        checkIfWalletIsConnected();
    }, []);

    function GetTokens({ isLoading, children, ...props }) {
        return (
            <Button variant="success" className="button" {...props}>
                {isButtonLoading ? <CircularProgress animation="border" /> : children}
            </Button>
        );
    }

    return (
        <Container component="main" maxWidth="xs">
            <Box
                sx={{
                    marginTop: 8,
                    display: "flex",
                    flexDirection: "column",
                    alignItems: "center",
                }}
            >
                <Box component="form" sx={{ mt: 5 }}>
                    <Typography component="h1" variant="h4" mb={3}>
                        Get Tokens
                    </Typography>
                    {currentAccount === "" ? (
                        <Button variant="contained" onClick={connectWallet} sx={{ mb: 3  , mr:3}}>
                            Connect Wallet
                        </Button>
                    ) : (
                        <Card
                            variant="outlined"
                            sx={{ p: 1, borderRadius: 1, mb: 3 }}
                        >{`${currentAccount.substring(0, 4)}...${currentAccount.substring(
                            38
                        )}`}</Card>
                    )}
                    <Button
                        variant="contained"
                        onClick={() => {
                            setIsButtonLoading(true);
                            getTokens();
                            setTimeout(() => {
                                setIsButtonLoading(false);
                            }, 1000);
                        }}
                        disabled={isButtonLoading}
                        sx={{ mb: 3 }}
                    >
                        {isButtonLoading ? (
                            <CircularProgress color="inherit" size={20} />
                        ) : (
                            "Click to Get 100k DAIx"
                        )}
                    </Button>
                    <Typography variant="subtitle2">
                        <b>NOTE:</b> This will only work on Mumbai and you must wait 12 hours
                        between calls.
                    </Typography>
                </Box>
            </Box>
        </Container>
    );
};