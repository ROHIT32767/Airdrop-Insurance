import * as React from 'react';
import Avatar from '@mui/material/Avatar';
import Button from '@mui/material/Button';
import CssBaseline from '@mui/material/CssBaseline';
import TextField from '@mui/material/TextField';
import Box from '@mui/material/Box';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import loginService from "../services/login"
import UserService from "../services/Users" 
// import AuthContext from '../context/AuthContext';

const theme = createTheme();

function validate(email, password) {
    // true means invalid, so our conditions got reversed
    return {
        email: email.length === 0,
        password: password.length === 0
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
// ! Password: Testing - rohitgowlapalli01@gmail.com
// ! Password: Hello123 rohit.gowlapalli@students.iiit.ac.in
// ! dynrohttajaytzob
// ! airdropinsurance@gmail.com - airdrop
export default function Login(props) {
    const [emaillogin, setemaillogin] = React.useState("")
    const [passwordlogin, setpasswordlogin] = React.useState("")
    const [errorMessage, setErrorMessage] = React.useState(null)
    const [touched, settouched] = React.useState({
        email: false,
        password: false
    })
    // const navigate = useNavigate()
    // const setuser = React.useContext(AuthContext).setuser
    function changeemaillogin(event) {
        setemaillogin(event.target.value)
    }
    function changepasswordlogin(event) {
        setpasswordlogin(event.target.value)
    }
    const handlelogin = async (event) => {
        console.log(emaillogin, passwordlogin)
        if (canBeSubmitted()) {
            event.preventDefault()
            try {
                const user = await loginService.login({
                    Email: emaillogin,
                    password: passwordlogin
                })
                props.setuser(user)
                window.localStorage.setItem(
                    'token', JSON.stringify(user)
                )
                UserService.setToken(user.token)
                setemaillogin("")
                setpasswordlogin("")
                // TODO: Make sure everything is reight here
            } catch (error) {
                console.log(emaillogin, passwordlogin, error)
                setemaillogin("")
                setpasswordlogin("")
                setErrorMessage(
                    `Invalid Credentials`
                )
                setTimeout(() => {
                    setErrorMessage(null)
                }, 3000)
            }
        }
        else {
            console.log(emaillogin, passwordlogin)
            setemaillogin("")
            setpasswordlogin("")
            setErrorMessage(
                `Invalid Credentials`
            )
            setTimeout(() => {
                setErrorMessage(null)
            }, 3000)
        }
    }
    function canBeSubmitted() {
        const errors = validate(touched.email, touched.password);
        const isDisabled = Object.keys(errors).some(x => errors[x]);
        return !isDisabled;
    }
    const errors = validate(emaillogin, passwordlogin);
    const isDisabled = Object.keys(errors).some(x => errors[x]);
    const shouldMarkError = field => {
        const hasError = errors[field];
        const shouldShow = touched[field];
        return hasError ? shouldShow : false;
    };
    return (
        <div>
            <ThemeProvider theme={theme}>
                <Container component="main" maxWidth="xs">
                    <CssBaseline />
                    <Box
                        sx={{
                            marginTop: 8,
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                        }}
                    >
                        <Avatar sx={{ m: 1, bgcolor: 'secondary.main' }}>
                            <LockOutlinedIcon />
                        </Avatar>
                        <Typography component="h1" variant="h5">
                            Sign in
                        </Typography>
                        <Notification message={errorMessage} />
                        <Box component="form" onSubmit={handlelogin} noValidate sx={{ mt: 1 }}>
                            {
                                shouldMarkError("email") ?
                                    <TextField
                                        error
                                        margin="normal"
                                        fullWidth
                                        id="filled-error-helper-text"
                                        label="Email Address"
                                        name="email"
                                        autoComplete="email"
                                        helperText="Invalid entry"
                                        variant="filled"
                                        autoFocus
                                        value={emaillogin}
                                        onChange={changeemaillogin}
                                        onBlur={event => settouched({ ...touched, email: true })}
                                    /> :
                                    <TextField
                                        margin="normal"
                                        required
                                        fullWidth
                                        id="email"
                                        label="Email Address"
                                        name="email"
                                        autoComplete="email"
                                        autoFocus
                                        value={emaillogin}
                                        onChange={changeemaillogin}
                                        onBlur={event => settouched({ ...touched, email: true })}
                                    />
                            }
                            {
                                shouldMarkError("password") ?
                                    <TextField
                                        error
                                        margin="normal"
                                        required
                                        fullWidth
                                        helperText="Invalid entry"
                                        variant="filled"
                                        name="password"
                                        label="Password"
                                        type="password"
                                        id="filled-error-helper-text"
                                        autoComplete="current-password"
                                        value={passwordlogin}
                                        onChange={changepasswordlogin}
                                        onBlur={event => settouched({ ...touched, password: true })}
                                    /> :
                                    <TextField
                                        margin="normal"
                                        required
                                        fullWidth
                                        name="password"
                                        label="Password"
                                        type="password"
                                        id="password"
                                        autoComplete="current-password"
                                        value={passwordlogin}
                                        onChange={changepasswordlogin}
                                        onBlur={event => settouched({ ...touched, password: true })}
                                    />
                            }
                            {
                                isDisabled ?
                                    <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}>Sign In</Button> :
                                    <Button
                                        type="submit"
                                        fullWidth
                                        variant="contained"
                                        sx={{ mt: 3, mb: 2 }}
                                        onSubmit={handlelogin}
                                    >
                                        Sign In
                                    </Button>
                            }
                        </Box>
                    </Box>
                </Container>
            </ThemeProvider>
        </div>

    )
}