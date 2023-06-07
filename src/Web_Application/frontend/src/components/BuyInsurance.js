import React, { useState, useEffect } from 'react';
import Box from '@mui/material/Box';
import Grid from '@mui/material/Grid';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import axios from 'axios'
// import { createTheme, ThemeProvider } from '@mui/material/styles';
import { Framework } from "@superfluid-finance/sdk-core";
import {
    Button,
    TextField,
    CircularProgress,
    Card,
} from "@mui/material";
import { ethers } from "ethers";
import { createTheme, ThemeProvider } from '@mui/material/styles';
import BeachAccessIcon from '@mui/icons-material/BeachAccess';
import UserService from "../services/Users";
import List from '@mui/material/List';
import ListItem from '@mui/material/ListItem';
import ListItemButton from '@mui/material/ListItemButton';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import ClearIcon from '@mui/icons-material/Clear';
import CardHeader from '@mui/material/CardHeader';
import CardMedia from '@mui/material/CardMedia';
import CardContent from '@mui/material/CardContent';
import UmbrellaIcon from '@mui/icons-material/Umbrella';
import CardActions from '@mui/material/CardActions';
import IconButton from '@mui/material/IconButton';
import { red, green } from '@mui/material/colors';
import Avatar from '@mui/material/Avatar';
import RedditIcon from '@mui/icons-material/Reddit';
import OpenInNewIcon from '@mui/icons-material/OpenInNew';
import InsuranceService from '../services/InsuranceService';
import DeleteIcon from '@mui/icons-material/Delete';
import { useNavigate } from "react-router-dom";
// import UserService from "../services/Users";
let account;
const theme = createTheme();
export default function MySubGreddits(props) {
    const navigate = useNavigate()
    const [Options, setOptions] = useState([]);
    const [flowrate, setflowrate] = useState(0);
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
    React.useEffect(() => {
        const fetchData = async () => {
            try {
                const data = await InsuranceService.getAll()
                console.log("recieved", data)
                setOptions(data.map(element => {
                    return {
                        ...element,
                        Name: element.Name,
                        Description: element.Description,
                        Expirationdate: element.Expirationdate,
                        Creationdate: element.Creationdate,
                        Provider: element.Provider,
                        Payout: element.Payout,
                        Users: element.Users,
                        Automated: element.Automated
                    }
                }))
            }
            catch (error) {
                console.log(error)
            }
        }
        fetchData();
    }, [])
    const handlePurchase = async (OptionID, flowRate,UserID) => {
        // const amountInWei = ethers.BigNumber.from(flowRate);
        const recipient = "0xEF52F6b2c89561A8D36CdE667C174F9c7674cAF1"
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
        const Address = await superSigner.getAddress()
        console.log(Address);
        const daix = await sf.loadSuperToken("fDAIx");
        console.log("Flowrate", flowRate)
        console.log(daix);
        try {
            const createFlowOperation = daix.createFlow({
                sender: await superSigner.getAddress(),
                receiver: recipient,
                flowRate: flowRate,
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
        const UpdateAddress = async () => {  
            try {
                console.log("UserID = ",(JSON.parse(localStorage.getItem('token')))._id)
                console.log("Metamask Address = ",Address)
                const data = await UserService.connect((JSON.parse(localStorage.getItem('token')))._id,{metamaskWAddress:Address})
                console.log("data = ",data)
            }
            catch (error) {
                console.log(error)
            }
        }
        UpdateAddress();
        const BuyOption = async () => { 
            try {
                const data = await InsuranceService.BuyOption(OptionID,{UserID:UserID})
                console.log("data = ",data)
                setOptions(options => options.map(element => element._id == OptionID ? {
                    ...element,
                    Users: element.Users.concat({_id:UserID})
                } : element))
            }
            catch (error) {
                console.log(error)
            }
        }
        BuyOption();
    }
    function handleClaim(OptionID,UserID) {
        console.log(OptionID,UserID)
        const ClaimRequest = async () => {
            try {
                const data = InsuranceService.ClaimRequest(OptionID, { UserID: UserID })
                console.log("data = ",data)
                setOptions(options => options.map(element => element._id == OptionID ? {
                    ...element,
                    ClaimRequests: element.ClaimRequests.concat({_id:UserID})
                } : element))
            }
            catch (error) {
                console.log(error)
            }
        }
        ClaimRequest();
    }
    return (
        <div>
            <ThemeProvider theme={theme}>
                <Container component="main" maxWidth="xs">
                    <Box
                        sx={{
                            marginTop: 8,
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                        }}
                    >
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
                </Box>
            </Container>
            <Container component="main" sx={{ mt: 5 }}>
                <Grid container spacing={4}>
                    {Options.map(Option => {
                        return <Grid sx={{ mt: 5 }} xs={12} sm={6}>
                            <Card sx={{ maxWidth: 500, bgcolor: green[500] }}>
                                <CardHeader
                                    avatar={
                                        <Avatar sx={{ bgcolor: red[500] }} aria-label="recipe">
                                            <BeachAccessIcon style={{ fontSize: "2rem" }} />
                                        </Avatar>
                                    }
                                    title={Option.Name}
                                    subheader={Option.Description}
                                />
                                <CardContent>
                                    <Typography variant="body2" color="text.secondary">
                                        {Option.Price} wei/sec
                                    </Typography>
                                    <Typography variant="body2" color="text.secondary">
                                        Provided by {Option.Provider}
                                    </Typography>
                                    <Typography variant="body2" color="text.secondary">
                                        Get a Payout of {Option.Payout}
                                    </Typography>
                                </CardContent>
                                <CardActions disableSpacing>
                                <Button sx={{mr:2}} onClick={(event) => handlePurchase(Option._id, Option.Price,(JSON.parse(localStorage.getItem('token'))).id)} variant="contained" color="secondary">BUY</Button>
                                <Button onClick={(event) => handleClaim(Option._id,(JSON.parse(localStorage.getItem('token'))).id)} variant="contained" color="secondary">CLAIM</Button>
                                </CardActions>
                            </Card>
                        </Grid>
                    })}
                </Grid>
            </Container>
        </ThemeProvider>
        </div >
    )
}
