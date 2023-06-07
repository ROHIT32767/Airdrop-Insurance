import * as React from 'react';
import Avatar from '@mui/material/Avatar';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import AccountCircleIcon from '@mui/icons-material/AccountCircle';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import { Button } from '@mui/material';
import { useNavigate } from "react-router-dom";
// import axios from 'axios';
import UserService from "../services/Users"
const theme = createTheme();
function validate(Username, Email,password) {
    return {
        Email: Email.length === 0,
        password: password.length === 0,
        Username: Username.length === 0,
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
export default function ViewProfile(props) {
    const [ReadOnlyValues, setReadOnlyValues] = React.useState({
        Username: "",
        Email: "",
        Password: "",
    })
    const [errorMessage, setErrorMessage] = React.useState(null)
    const [FormValues, setFormValues] = React.useState({
        Username: "",
        Email: "",
        password: ""
    })
    const [touched, settouched] = React.useState({
        Username: false,
        Email: false,
        password: false
    })
    const [edit, setedit] = React.useState(false)
    const [showbuttons, setshowbuttons] = React.useState({
        showsavebutton: true,
        showcancelbutton: true,
        showeditbutton: true
    })
    const navigate = useNavigate()
    function canBeSubmitted() {
        const errors = validate(touched.Username, touched.Email, touched.password);
        const isDisabled = Object.keys(errors).some(x => errors[x]);
        return !isDisabled;
    }
    const errors = validate(FormValues.Username, FormValues.Email,FormValues.password);
    const isDisabled = Object.keys(errors).some(x => errors[x]);
    const shouldMarkError = field => {
        const hasError = errors[field];
        const shouldShow = touched[field];
        return hasError ? shouldShow : false;
    };
    function handleEdit() {
        setedit(!edit)
        setFormValues({
            ...FormValues, 
            Username: "",
            Email: "",
            password: ""
        })
    }
    React.useEffect(() => {
        const fetchData = async () => {
            try {
                // console.log("props user =", props.user)
                const data = await UserService.getID()
                console.log("recieved ReadOnlyValues", data)
                setReadOnlyValues({
                    Username: data.Username,
                    Email: data.Email,
                    Password: data.Password,
                })
            }
            catch (error) {
                console.log(error)
            }
        }
        fetchData();
    }, [])
    function handleSubmit(event) {
        event.preventDefault();
        if (!canBeSubmitted()) {
            setFormValues({
                Username: "",
                Email: "",
                password: "",
            })
            setErrorMessage(
                `Given Form Inputs are Invalid `
            )
            setTimeout(() => {
                setErrorMessage(null)
            }, 3000)
        }
        else {
            const UpdateProfile = async () => {
                setshowbuttons({ ...showbuttons, showcancelbutton: false, showeditbutton: false, showsavebutton: false })
                try {
                    console.log("props user for Update = ", props.user)
                    const data = await UserService.UpdateProfile(props.user.id, {
                        ...ReadOnlyValues,
                        ...FormValues
                    })
                    console.log("ReadOnlyValue", ReadOnlyValues)
                    console.log("recieved for Update", data)
                    setReadOnlyValues({
                        ...ReadOnlyValues,
                        ...FormValues
                    })
                    setFormValues({
                        ...FormValues, 
                        Username: "",
                        Email: "",
                        password: ""
                    })
                }
                catch (error) {
                    console.log("In Register.js", error)
                }
                setshowbuttons({ ...showbuttons, showcancelbutton: true, showeditbutton: true, showsavebutton: true })
            }
            UpdateProfile();
            setedit(!edit)
            console.log(ReadOnlyValues)
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
                            PROFILE
                        </Typography>
                        <Notification message={errorMessage} />
                        {edit ?
                            <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
                                <Grid container spacing={2}>
                                    <Grid item xs={12}>
                                        {
                                            shouldMarkError("Username") ?
                                                <TextField
                                                    error
                                                    id="filled-error-helper-text"
                                                    helperText="Invalid entry"
                                                    onBlur={event => settouched({ ...touched, Username: true })}
                                                    required
                                                    fullWidth
                                                    label="Username"
                                                    name="Username"
                                                    variant="filled"
                                                    value={FormValues.Username}
                                                    onChange={event => setFormValues({ ...FormValues, Username: event.target.value })}
                                                />
                                                :
                                                <TextField
                                                    required
                                                    fullWidth
                                                    id="Username"
                                                    label="Username"
                                                    name="Username"
                                                    value={FormValues.Username}
                                                    onBlur={event => settouched({ ...touched, Username: true })}
                                                    onChange={event => setFormValues({ ...FormValues, Username: event.target.value })}
                                                />
                                        }
                                    </Grid>
                                    <Grid item xs={12}>
                                        {
                                            shouldMarkError("Email") ?
                                                <TextField
                                                    variant="filled"
                                                    error
                                                    id="filled-error-helper-text"
                                                    helperText="Invalid entry"
                                                    onBlur={event => settouched({ ...touched, Email: true })}
                                                    required
                                                    fullWidth
                                                    label="Email Address"
                                                    name="email"
                                                    autoComplete="email"
                                                    value={FormValues.Email}
                                                    onChange={event => setFormValues({ ...FormValues, Email: event.target.value })}
                                                />
                                                :
                                                <TextField
                                                    required
                                                    fullWidth
                                                    id="email"
                                                    label="Email Address"
                                                    name="email"
                                                    autoComplete="email"
                                                    value={FormValues.Email}
                                                    onBlur={event => settouched({ ...touched, Email: true })}
                                                    onChange={event => setFormValues({ ...FormValues, Email: event.target.value })}
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
                                                    onBlur={event => settouched({ ...touched, password: true })}
                                                    required
                                                    fullWidth
                                                    name="password"
                                                    label="Password"
                                                    type="password"
                                                    autoComplete="new-password"
                                                    value={FormValues.password}
                                                    onChange={event => setFormValues({ ...FormValues, password: event.target.value })}
                                                />
                                                :
                                                <TextField
                                                    required
                                                    fullWidth
                                                    name="password"
                                                    label="Password"
                                                    type="password"
                                                    id="password"
                                                    autoComplete="new-password"
                                                    value={FormValues.password}
                                                    onBlur={event => settouched({ ...touched, password: true })}
                                                    onChange={event => setFormValues({ ...FormValues, password: event.target.value })}
                                                />
                                        }
                                    </Grid>
                                </Grid>
                                {
                                    isDisabled ?
                                        <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}> Save Changes </Button>
                                        :
                                        showbuttons.showsavebutton ? <Button
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
                                {
                                    showbuttons.showcancelbutton ?
                                        <Button
                                            fullWidth
                                            variant="contained"
                                            sx={{ mt: 3, mb: 2 }}
                                            onClick={handleEdit}
                                        >
                                            Cancel
                                        </Button>
                                        :
                                        <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}> Cancel </Button>
                                }

                            </Box>
                            :
                            <Box component="form" sx={{ mt: 3 }}>
                                <Grid container spacing={2}>
                                    <Grid item xs={12}>
                                        <TextField
                                            fullWidth
                                            id="outlined-read-only-input"
                                            label="Username"
                                            name="username"

                                            InputProps={{
                                                readOnly: true,
                                            }}
                                            value={ReadOnlyValues.Username}
                                        />
                                    </Grid>
                                    <Grid item xs={12}>
                                        <TextField
                                            fullWidth
                                            id="outlined-read-only-input"
                                            label="Email Address"
                                            name="Email"
                                            autoComplete="email"

                                            InputProps={{
                                                readOnly: true,
                                            }}
                                            value={ReadOnlyValues.Email}
                                        />
                                    </Grid>
                                </Grid>
                                {
                                    showbuttons.showeditbutton ?
                                        <Button
                                            fullWidth
                                            variant="contained"
                                            sx={{ mt: 3, mb: 2 }}
                                            onClick={handleEdit}
                                        >
                                            Edit
                                        </Button>
                                        :
                                        <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}> Edit </Button>
                                }
                            </Box>
                        }
                    </Box>
                </Container>
            </ThemeProvider>
        </div>
    )
}