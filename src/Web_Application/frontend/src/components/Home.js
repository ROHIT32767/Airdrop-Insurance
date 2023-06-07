import React from 'react';
import { Tab, Tabs, TabList, TabPanel } from "react-tabs";
import Login from "./Login"
import Register from "./Register"
export default function Home(props){
    return (
        <div>
            {!props.user ?
                <div className="App">
                    <Tabs className="Tabs">
                        <TabList>
                            <Tab>Login</Tab>
                            <Tab>Signup</Tab>
                        </TabList>
                        <TabPanel>
                            <Login user={props.user} setuser={props.setuser} />
                        </TabPanel>
                        <TabPanel>
                            <Register  />
                        </TabPanel>
                    </Tabs>
                </div>
                :
                <div>
                Welcome {props.user.Email}    
                </div>
            }
        </div>
    );
};
