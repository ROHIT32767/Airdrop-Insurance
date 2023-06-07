import React from "react"
import TextField from "@mui/material/TextField";
export default function AgeComp(props) {
    const [age, setage] = React.useState("")
    // const [error, seterror] = React.useState(null) Handle errors
    const HandleAgeChange = event => {
        setage(event.target.value)
        props.setFormValues({ ...props.FormValues, Age: event.target.value })
    }
    return (
        <div>
            <TextField
                id="outlined-number"
                required
                label="Age"
                type="number"
                InputLabelProps={{
                    shrink: true,
                }}
                value={age}
                onChange={HandleAgeChange}
            />
        </div>
    )
}