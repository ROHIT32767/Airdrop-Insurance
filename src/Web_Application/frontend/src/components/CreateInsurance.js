import * as React from 'react';
import Avatar from '@mui/material/Avatar';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import { Button, FormControlLabel, Checkbox } from '@mui/material';
import { useNavigate } from "react-router-dom";
import { DatePicker } from '@mui/lab';
import AdapterDateFns from '@mui/lab/AdapterDateFns';
import LocalizationProvider from '@mui/lab/LocalizationProvider';
import InsuranceService from "../services/InsuranceService";

const theme = createTheme();

function validate(name, Description, Price, Provider, payout) {
    return {
        Name: name.length === 0,
        Description: Description.length === 0,
        Price: Price <= 0,
        Provider: Provider.length === 0,
        Payout: payout <= 0,
    };
}

const Notification = ({ message }) => {
    if (message === null) {
        return null
    }
    return (
        <div>
            <br />
            <div className='error'>
                {message}
            </div>
            <br />
        </div>
    )
}

export default function CreateInsurance(props) {
    const [errorMessage, setErrorMessage] = React.useState(null);
    const [FormValues, setFormValues] = React.useState({
        Name: "",
        Description: "",
        Price: 0,
        Provider: "",
        Payout: 0,
        Automated: false,
    });
    const [touched, setTouched] = React.useState({
        Name: false,
        Description: false,
        Price: false,
        Provider: false,
        Payout: false,
        Automated: false,
    });
    const [showButtons, setshowButtons] = React.useState({
        showsavebutton: true,
    });
    const navigate = useNavigate();

    function canBeSubmitted() {
        const errors = validate(
            touched.Name,
            touched.Description,
            touched.Price,
            touched.Provider,
            touched.Payout,
            touched.Automated
        );
        const isDisabled = Object.keys(errors).some(x => errors[x]);
        return !isDisabled;
    }

    const errors = validate(
        FormValues.Name,
        FormValues.Description,
        FormValues.Price,
        FormValues.Provider,
        FormValues.Payout
    );
    const isDisabled = Object.keys(errors).some(x => errors[x]);

    const shouldMarkError = field => {
        const hasError = errors[field];
        const shouldShow = touched[field];
        return hasError ? shouldShow : false;
    };

    function handleSubmit() {
        setFormValues({
            ...FormValues,
            Name: "",
            Description: "",
            Price: 0,
            Provider: "",
            Payout: 0,
            Automated: false,
        })
    }
    function handleSubmit(event) {
        event.preventDefault();
        if (!canBeSubmitted()) {
            setFormValues({
                Name: "",
                Description: "",
                Price: 0,
                Provider: "",
                Payout: 0,
                Automated: false,
            })
            setErrorMessage(
                `Given Form Inputs are Invalid `
            )
            setTimeout(() => {
                setErrorMessage(null)
            }, 3000)
        }
        else {
            const CreateInsuranceOption = async () => {
                setshowButtons({ ...showButtons, showsavebutton: false })
                try {
                    const data = await InsuranceService.create(FormValues)
                    console.log("data = ", data)
                    setFormValues({
                        ...FormValues,
                        Name: "",
                        Description: "",
                        Price: 0,
                        Provider: "",
                        Payout: 0,
                        Automated: false,
                    })
                }
                catch (error) {
                    console.log("In CreateInsurance.js", error)
                }
                setshowButtons({ ...showButtons, showsavebutton: true })
            }
            CreateInsuranceOption();
        }
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
                        <Avatar sx={{ m: 1, bgcolor: 'secondary.main' }}>
                            <AccountCircleIcon />
                        </Avatar>
                        <Typography component="h1" variant="h5">
                            Create Insurance Option
                        </Typography>
                        <Notification message={errorMessage} />
                        <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
                            <Grid container spacing={2}>
                                <Grid item xs={12}>
                                    {
                                        shouldMarkError("Name") ?
                                            <TextField
                                                error
                                                id="filled-error-helper-text"
                                                helperText="Invalid entry"
                                                onBlur={event => setTouched({ ...touched, Name: true })}
                                                required
                                                fullWidth
                                                label="Name"
                                                name="Name"
                                                variant="filled"
                                                value={FormValues.Name}
                                                onChange={event => setFormValues({ ...FormValues, Name: event.target.value })}
                                            />
                                            :
                                            <TextField
                                                required
                                                fullWidth
                                                id="Name"
                                                label="Name"
                                                name="Name"
                                                value={FormValues.Name}
                                                onBlur={event => setTouched({ ...touched, Name: true })}
                                                onChange={event => setFormValues({ ...FormValues, Name: event.target.value })}
                                            />
                                    }
                                </Grid>
                                <Grid item xs={12}>
                                    {
                                        shouldMarkError("Description") ?
                                            <TextField
                                                variant="filled"
                                                error
                                                id="filled-error-helper-text"
                                                helperText="Invalid entry"
                                                onBlur={event => setTouched({ ...touched, Description: true })}
                                                required
                                                fullWidth
                                                label="Description"
                                                name="Description"
                                                autoComplete="Description"
                                                value={FormValues.Description}
                                                onChange={event => setFormValues({ ...FormValues, Description: event.target.value })}
                                            />
                                            :
                                            <TextField
                                                required
                                                fullWidth
                                                id="Description"
                                                label="Description"
                                                name="Description"
                                                autoComplete="Description"
                                                value={FormValues.Description}
                                                onBlur={event => setTouched({ ...touched, Description: true })}
                                                onChange={event => setFormValues({ ...FormValues, Description: event.target.value })}
                                            />
                                    }
                                </Grid>
                                <Grid item xs={12}>
                                    {
                                        shouldMarkError("Provider") ?
                                            <TextField
                                                variant="filled"
                                                error
                                                id="filled-error-helper-text"
                                                helperText="Invalid entry"
                                                onBlur={event => setTouched({ ...touched, Provider: true })}
                                                required
                                                fullWidth
                                                name="Provider"
                                                label="Provider"
                                                type="Provider"
                                                value={FormValues.Provider}
                                                onChange={event => setFormValues({ ...FormValues, Provider: event.target.value })}
                                            />
                                            :
                                            <TextField
                                                required
                                                fullWidth
                                                name="Provider"
                                                label="Provider"
                                                type="Provider"
                                                id="Provider"
                                                value={FormValues.Provider}
                                                onBlur={event => setTouched({ ...touched, Provider: true })}
                                                onChange={event => setFormValues({ ...FormValues, Provider: event.target.value })}
                                            />
                                    }
                                </Grid>
                                <Grid item xs={12}>
                                    {
                                        shouldMarkError("Price") ?
                                            <TextField
                                                variant="filled"
                                                error
                                                id="filled-error-helper-text"
                                                helperText="Invalid entry"
                                                onBlur={event => setTouched({ ...touched, password: true })}
                                                required
                                                fullWidth
                                                name="Price"
                                                label="Price"
                                                type="Price"
                                                value={FormValues.Price}
                                                onChange={event => setFormValues({ ...FormValues, Price: event.target.value })}
                                            />
                                            :
                                            <TextField
                                                required
                                                fullWidth
                                                name="Price"
                                                label="Price"
                                                type="Price"
                                                id="Price"
                                                value={FormValues.Price}
                                                onBlur={event => setTouched({ ...touched, Price: true })}
                                                onChange={event => setFormValues({ ...FormValues, Price: event.target.value })}
                                            />
                                    }
                                </Grid>
                                <Grid item xs={12}>
                                    {
                                        shouldMarkError("password") ?
                                            <TextField
                                                variant="filled"
                                                error
                                                id="filled-error-helper-text"
                                                helperText="Invalid entry"
                                                onBlur={event => setTouched({ ...touched, Payout: true })}
                                                required
                                                fullWidth
                                                name="Payout"
                                                label="Payout"
                                                type="Payout"
                                                value={FormValues.Price}
                                                onChange={event => setFormValues({ ...FormValues, Payout: event.target.value })}
                                            />
                                            :
                                            <TextField
                                                required
                                                fullWidth
                                                name="Payout"
                                                label="Payout"
                                                type="Payout"
                                                id="Payout"
                                                value={FormValues.Payout}
                                                onBlur={event => setTouched({ ...touched, Payout: true })}
                                                onChange={event => setFormValues({ ...FormValues, Payout: event.target.value })}
                                            />
                                    }
                                </Grid>
                            </Grid>
                            {
                                isDisabled ?
                                    <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}> Save Changes </Button>
                                    :
                                    showButtons.showsavebutton ? <Button
                                        type="submit"
                                        fullWidth
                                        variant="contained"
                                        sx={{ mt: 3, mb: 2 }}
                                    >
                                        Save Changes
                                    </Button>
                                        :
                                        <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}> Save Changes </Button>
                            }
                        </Box>
                    </Box>
                </Container>
            </ThemeProvider>
        </div>
    )
}
