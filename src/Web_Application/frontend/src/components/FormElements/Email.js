import React from "react"
import TextField from "@mui/material/TextField";
export default function EmailComp(props) {
    const [email, setemail] = React.useState("")
    // const [error, seterror] = React.useState(null) Handle errors
    function HandleEmailInput(event){
        setemail(event.target.value)
        props.setFormValues({...props.FormValues,Email:event.target.value})
    }
    return (
        <div>
            <TextField
                required
                fullWidth
                id="email"
                label="Email Address"
                name="email"
                autoComplete="email"
                value={email}
                onChange={HandleEmailInput}
            />
        </div>
    )
}