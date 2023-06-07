import React from "react"
import AppBar from '@mui/material/AppBar';
import Box from '@mui/material/Box';
import Toolbar from '@mui/material/Toolbar';
import Typography from '@mui/material/Typography';
import Button from '@mui/material/Button';
import ExitToAppIcon from '@mui/icons-material/ExitToApp';
import RedditIcon from '@mui/icons-material/Reddit';
import LocalMallIcon from '@mui/icons-material/LocalMall';
import WalletIcon from '@mui/icons-material/Wallet';
import useMediaQuery from '@mui/material/useMediaQuery';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import GetAppIcon from '@mui/icons-material/GetApp';
import DeleteIcon from '@mui/icons-material/Delete';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import TokenIcon from '@mui/icons-material/Token';
import BeachAccessIcon from '@mui/icons-material/BeachAccess';
import UpdateIcon from '@mui/icons-material/Update';
import { useNavigate } from "react-router-dom";
export default function Home(props) {
    const navigate = useNavigate()
    const handleLogout = (event) => {
        window.localStorage.removeItem('token')
        props.setuser(null)
        navigate("/")
    }
    const matches = useMediaQuery('(min-width:480px)');
    return (
        <Box sx={{ flexGrow: 1 }}>
            <AppBar position="fixed">
                <Toolbar>
                    {matches ? <BeachAccessIcon style={{ fontSize: "2rem", marginRight: "1rem" }} /> : null}
                    <Typography align="left" variant="h4" component="div" sx={{ flexGrow: 1 }}>
                        <Button color="inherit" href="/">Airdrop Insurance</Button>
                    </Typography>
                    {props.user ?
                        props.user.role === "admin" ?
                            <div>
                                <Button color="inherit" href="/profile"><AccountCircleIcon style={{ marginRight: "0.5rem" }} />Profile</Button>
                                <Button color="inherit" href="/Wallet"><WalletIcon style={{ marginRight: "0.5rem" }} />Wallet</Button>
                                <Button color="inherit" href="/DeleteFlow"><DeleteIcon style={{ marginRight: "0.5rem" }} />Delete Flow</Button>
                                <Button color="inherit" href="/CreateInsurance"><AccountCircleIcon style={{ marginRight: "0.5rem" }} />Create Insurance</Button>
                                <Button color="inherit" href="/VerifyClaim"><ExitToAppIcon style={{ marginRight: "0.5rem" }} />Verify Claim</Button>
                                <Button color="inherit" onClick={handleLogout}><ExitToAppIcon style={{ marginRight: "0.5rem" }} />Logout</Button>
                            </div> :
                            props.user.role === "speculator" ?
                                <div>
                                    <Button color="inherit" href="/profile"><AccountCircleIcon style={{ marginRight: "0.5rem" }} />Profile</Button>
                                    <Button color="inherit" href="/InsuranceBid"><AccountCircleIcon style={{ marginRight: "0.5rem" }} />InsuranceBid</Button>
                                    <Button color="inherit" onClick={handleLogout}><ExitToAppIcon style={{ marginRight: "0.5rem" }} />Logout</Button>
                                </div>
                                :
                                <div>
                                    <Button color="inherit" href="/profile"><AccountCircleIcon style={{ marginRight: "0.5rem" }} />Profile</Button>
                                    <Button color="inherit" href="/Wallet"><WalletIcon style={{ marginRight: "0.5rem" }} />Wallet</Button>
                                    <Button color="inherit" href="/BuyInsurance"><LocalMallIcon style={{ marginRight: "0.5rem" }} />Buy Insurance</Button>
                                    <Button color="inherit" href="/CreateFlow"><AddCircleOutlineIcon style={{ marginRight: "0.5rem" }} />Create Flow</Button>
                                    <Button color="inherit" href="/UpdateFlow"><UpdateIcon style={{ marginRight: "0.5rem" }} />Update Flow</Button>
                                    <Button color="inherit" href="/DeleteFlow"><DeleteIcon style={{ marginRight: "0.5rem" }} />Delete Flow</Button>
                                    {/* <Button color="inherit" href="/ClaimInsurance"><GetAppIcon style={{ marginRight: "0.5rem" }} />Claim Insurance</Button> */}
                                    <Button color="inherit" href="/GetTokens"><TokenIcon style={{ marginRight: "0.5rem" }} />Get Tokens</Button>
                                    <Button color="inherit" onClick={handleLogout}><ExitToAppIcon style={{ marginRight: "0.5rem" }} />Logout</Button>
                                </div>
                        :
                        <div>
                            Airdrop-Insurance
                        </div>
                    }
                </Toolbar>
            </AppBar>
        </Box>
    )
}