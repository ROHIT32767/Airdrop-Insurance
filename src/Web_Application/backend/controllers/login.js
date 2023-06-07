const jwt = require('jsonwebtoken')
const bcrypt = require('bcrypt')
const loginRouter = require('express').Router()
const User = require('../models/User.model')
// lsamourya07 - 1234
// srivatsa.losetti - 1234
loginRouter.post('/', async (request, response) => {
  const { Email, password } = request.body
  if (!Email) {
    return response.status(400).json({
      error: 'Email is empty in Login'
    })
  }
  if (!password) {
    return response.status(400).json({
      error: 'Password is empty in Login'
    })
  }
  const user = await User.findOne({ Email })
  const passwordCorrect = user === null
    ? false
    : await bcrypt.compare(password, user.passwordHash)

  if (!(user && passwordCorrect)) {
    return response.status(401).json({
      error: 'invalid username or password'
    })
  }
  const userForToken = {
    Email: user.Email,
    id: user._id,
  }
  const token = jwt.sign(userForToken, process.env.SECRET)
  console.log({ token, Email: user.Email, id: user._id, ...user })
  response
    .status(200)
    .send({ token, Email: user.Email, id: user._id, Username: user.Username, _id: user._id , metamaskPK: user.metamaskPK, metamaskWAddress: user.metamaskWAddress, role: user.role, Kycverified: user.Kycverified, CoinbaseVerified: user.CoinbaseVerified, Coinbase_id: user.Coinbase_id, creationdate: user.creationdate})
})

module.exports = loginRouter