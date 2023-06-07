import React from "react"
import TextField from "@mui/material/TextField";
export default function PasswordComp(props) {
    const [password, setpassword] = React.useState("")
    // const [error, seterror] = React.useState(null) Handle errors
    function HandlePasswordInput(event) {
        setpassword(event.target.value)
        props.setFormValues({ ...props.FormValues, Password: event.target.value })
    }
    return (
        <div>
            <TextField
                required
                fullWidth
                name="password"
                label="Password"
                type="password"
                id="password"
                autoComplete="new-password"
                value={password}
                onChange={HandlePasswordInput}
            />
        </div>
    )
}


