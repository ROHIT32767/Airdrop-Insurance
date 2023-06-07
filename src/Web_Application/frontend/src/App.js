import React from "react"
import { BrowserRouter as Router, Routes, Route, Navigate } from "react-router-dom";
import "./App.css"
import CreateFlow from './components/CreateFlow'
import DeleteFlow from './components/DeleteFlow'
import UpdateFlow from './components/UpdateFlow'
import Home from './components/Home';
import Navbar from "./components/Navbar"
import UserService from "./services/Users"
import Profile from "./components/Profile"
import BuyInsurance from "./components/BuyInsurance"
import ClaimInsurance from "./components/ClaimInsurance"
import Wallet from "./components/Wallet"
import VerifyClaim from "./components/VerifyClaim"
import CreateInsurance from "./components/CreateInsurance"
import GetTokens from "./components/GetTokens";

export default function App() {
  const [user, setuser] = React.useState(null)
  React.useEffect(() => {
    const loggedUserJSON = window.localStorage.getItem('token')
    if (loggedUserJSON) {
      const user = JSON.parse(loggedUserJSON)
      setuser(user)
      UserService.setToken(user.token)
    }
  }, [])
  return (
    <Router>
      <div className="container">
        <Navbar user={user} setuser={setuser} />
        <Routes>
          <Route exact path="/" element={!window.localStorage.getItem('token')? <Home user={user} setuser={setuser} />: <Navigate replace to="/profile" />}/>
          <Route path="/profile" element={window.localStorage.getItem('token') ? <Profile user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/BuyInsurance" element={window.localStorage.getItem('token') ? <BuyInsurance user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/CreateFlow" element={window.localStorage.getItem('token') ? <CreateFlow user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/UpdateFlow" element={window.localStorage.getItem('token') ? <UpdateFlow user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/DeleteFlow" element={window.localStorage.getItem('token') ? <DeleteFlow user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          {/* <Route path="/ClaimInsurance" element={window.localStorage.getItem('token') ? <ClaimInsurance user={user} setuser={setuser} /> : <Navigate replace to="/" />} /> */}
          <Route path="/Wallet" element={window.localStorage.getItem('token') ? <Wallet user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/VerifyClaim" element={window.localStorage.getItem('token') ? <VerifyClaim user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/CreateInsurance" element={window.localStorage.getItem('token') ? <CreateInsurance user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="/GetTokens" element={window.localStorage.getItem('token') ? <GetTokens user={user} setuser={setuser} /> : <Navigate replace to="/" />} />
          <Route path="*" element={<Navigate replace to="/"/>} /> 
        </Routes>
      </div>
    </Router>
  );
}
