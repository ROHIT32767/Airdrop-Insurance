import React from "react"
import Box from '@mui/material/Box';
import Container from '@mui/material/Container';
import List from '@mui/material/List';
import ListItemIcon from '@mui/material/ListItemIcon';
import ListItemText from '@mui/material/ListItemText';
import ListItem from '@mui/material/ListItem';
import PersonIcon from '@mui/icons-material/Person';
import InsuranceService from "../services/InsuranceService"
import Button from '@mui/material/Button';
import { Framework } from "@superfluid-finance/sdk-core";
import {ethers} from "ethers";
import { Tab, Tabs, TabList, TabPanel } from "react-tabs";
import { createTheme, ThemeProvider } from '@mui/material/styles';
const theme = createTheme();
export default function VerifyClaim(props) {
    const [ClaimRequests, setClaimRequests] = React.useState([])

    async function handleAccept(OptionID, UserID, Payout, Address) {
        console.log(OptionID, UserID)
        const AcceptRequests = async () => {
            try {
                const data = await InsuranceService.AcceptRequest(OptionID, { UserID: UserID })
                console.log("recieved", data)
            }
            catch (error) {
                console.log(error)
            }
            const UpdatedClaimRequests = ClaimRequests.filter(element => element._id !== UserID)

        }
        AcceptRequests();
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
            receiver: Address,
            flowRate: Payout
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
    function handleReject(OptionID, UserID) {
        console.log(OptionID, UserID)
        const RejectRequests = async () => {
            try {
                const data = await InsuranceService.RejectRequest(OptionID, { UserID: UserID })
                console.log("recieved", data)
            }
            catch (error) {
                console.log(error)
            }
            const UpdatedClaimRequests = ClaimRequests.filter(element => element._id !== UserID)
            console.log("Modified Claim requests", UpdatedClaimRequests)
            setClaimRequests(UpdatedClaimRequests)
        }
        RejectRequests();
    }
    React.useEffect(() => {
        const fetchInsuranceOptions = async () => {
            try {
                const data = await InsuranceService.getAll();
                console.log("data = ", data);
                const AllClaimRequests = [];
                data.forEach((option) => {
                    const modifiedClaimRequests = option.ClaimRequests.map((request) => ({
                        ...request,
                        OptionID: option._id,
                        Payout: option.Payout,
                    }));
                    AllClaimRequests.push(...modifiedClaimRequests);
                });
                console.log("AllClaimRequests = ", AllClaimRequests);
                setClaimRequests(AllClaimRequests);
            } catch (error) {
                console.log(error);
            }
        };
        fetchInsuranceOptions();
    }, []);
    console.log("ClaimRequests = ", ClaimRequests)

    return (
        <div>
            <ThemeProvider>
                <Container component="main" maxWidth="xs">
                    <Box
                        sx={{
                            marginTop: 8,
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                        }}
                    >
                        <div className="FollowerTabs">
                            <Tabs className="Tabs">
                                <TabList>
                                    <Tab>  CLAIM REQUESTS </Tab>
                                </TabList>
                                <TabPanel>
                                    <Box
                                        sx={{
                                            marginTop: 8,
                                            display: 'flex',
                                            flexDirection: 'column',
                                            alignItems: 'center',
                                        }}
                                    >
                                        {
                                            ClaimRequests.map(element => {
                                                return (
                                                    <Box sx={{ width: '100%', maxWidth: 360, bgcolor: 'background.paper' }}>
                                                        <nav aria-label="main mailbox folders">
                                                            <List>
                                                                <ListItem >
                                                                    <ListItemIcon>
                                                                        <PersonIcon />
                                                                    </ListItemIcon>
                                                                    <ListItemText primary={element.Username} />
                                                                    <Button onClick={event => handleAccept(element.OptionID, element._id,element.Payout,element.metamaskWAddress)} sx={{ marginLeft: 5 }} variant="contained" color="secondary">ACCEPT</Button>
                                                                    <Button onClick={event => handleReject(element.OptionID, element._id)} sx={{ marginLeft: 5 }} variant="contained" color="secondary">REJECT</Button>
                                                                </ListItem>
                                                            </List>
                                                        </nav>
                                                    </Box>
                                                )
                                            })
                                        }
                                    </Box>
                                </TabPanel>
                            </Tabs>
                        </div>
                    </Box>
                </Container>
            </ThemeProvider>
        </div>
    )
}