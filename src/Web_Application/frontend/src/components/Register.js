import * as React from 'react';
import Avatar from '@mui/material/Avatar';
import Button from '@mui/material/Button';
import CssBaseline from '@mui/material/CssBaseline';
import TextField from '@mui/material/TextField';
import Grid from '@mui/material/Grid';
import Box from '@mui/material/Box';
import LockOutlinedIcon from '@mui/icons-material/LockOutlined';
import Typography from '@mui/material/Typography';
import Container from '@mui/material/Container';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import UserService from "../services/Users"
import Radio from '@mui/material/Radio';
import RadioGroup from '@mui/material/RadioGroup';
import FormControlLabel from '@mui/material/FormControlLabel';
import FormControl from '@mui/material/FormControl';
import FormLabel from '@mui/material/FormLabel';

const theme = createTheme();
function validate(Username, Email, role, password) {
  // true means invalid, so our conditions got reversed
  return {
    Email: Email.length === 0,
    password: password.length === 0,
    Username: Username.length === 0,
    role : role.length === 0
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
export default function Register(props) {
  const [errorMessage, setErrorMessage] = React.useState(null)
  const [FormValues, setFormValues] = React.useState({
    Username: "",
    Email: "",
    role:"speculator",
    password: ""
  })
  const [touched, settouched] = React.useState({
    Username: false,
    Email: false,
    role:true,
    password: false
  })
  function canBeSubmitted() {
    const errors = validate(touched.Username, touched.Email,touched.role,touched.password);
    const isDisabled = Object.keys(errors).some(x => errors[x]);
    return !isDisabled;
  }
  const errors = validate(FormValues.Username, FormValues.Email,FormValues.role,FormValues.password);
  console.log(errors)
  const isDisabled = Object.keys(errors).some(x => errors[x]);
  const shouldMarkError = field => {
    const hasError = errors[field];
    const shouldShow = touched[field];
    return hasError ? shouldShow : false;
  };
  function handleSubmit(event) {
    console.log(FormValues)
    event.preventDefault()
    if (!canBeSubmitted()) {
      setFormValues({
        Username: "",
        Email: "",
        role:"speculator",
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
      const sendData = async () => {
        try {
          console.log("props user = ", props.user)
          const data = await UserService.create({ ...FormValues })
          console.log(FormValues)
          console.log("recieved", data)
          setFormValues({
            Username: "",
            Email: "",
            role:"speculator",
            password: ""
          })
        }
        catch (error) {
          console.log("In Register.js", error)
        }
      }
      sendData();
    }
  }
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
              Sign up
            </Typography>
            <Notification message={errorMessage} />
            <Box component="form" onSubmit={handleSubmit} sx={{ mt: 3 }}>
              <Grid container spacing={2}>
                <Grid item xs={12}>
                  {
                    shouldMarkError("Username") ?
                      <TextField
                        error
                        id="Username"
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
                <Grid item xs={12} sm={6}>
                  <FormControl component="fieldset">
                  <FormLabel id="demo-controlled-radio-buttons-group">Role</FormLabel>
                    <RadioGroup aria-label="role" name="role" value={FormValues.role} onChange={event => setFormValues({ ...FormValues, role: event.target.value })}>
                      <FormControlLabel value="member" control={<Radio />} label="Member" />
                      <FormControlLabel value="admin" control={<Radio />} label="Admin" />
                    </RadioGroup>
                  </FormControl>
                </Grid>
                <Grid item xs={12}>
                  {
                    shouldMarkError("Email") ?
                      <TextField
                        variant="filled"
                        error
                        id="Email"
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
                        id="password"
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
                  <Button fullWidth disabled sx={{ mt: 3, mb: 2 }}> Sign Up </Button>
                  :
                  <Button
                    type="submit"
                    fullWidth
                    variant="contained"
                    sx={{ mt: 3, mb: 2 }}
                    onSubmit={handleSubmit}
                  >
                    Sign Up
                  </Button>
              }
            </Box>
          </Box>
        </Container>
      </ThemeProvider>
    </div>
  )
}