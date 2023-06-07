const bcrypt = require('bcrypt')
const { request } = require('express')
const usersRouter = require('express').Router()
const User = require('../models/User.model')

usersRouter.post('/', async (request, response) => {
  console.log(request.body)
  const {
    Username,
    Email,
    role,
    password } = request.body
  if (!Username || !Email || !role || !password) {
    return response.status(400).json({
      error: 'Error in Input Fields for User Creation'
    })
  }
  const existingUser = await User.findOne({ Email })
  if (existingUser) {
    return response.status(400).json({
      error: 'Email must be unique'
    })
  }
  const saltRounds = 10
  const passwordHash = await bcrypt.hash(password, saltRounds)
  const user = new User({
    Username,
    Email,
    passwordHash,
    role
  })
  const savedUser = await user.save()
  console.log(savedUser)
  response.status(201).json(savedUser)
})

usersRouter.get('/', async (request, response) => {
  const users = await User
    .find({})
  response.json(users)
})

usersRouter.get('/:id', async (request, response) => {
  const ID = request.params.id
  const users = await User.findById(ID)
  users.id = ID
  console.log(users)
  response.status(201).json(users)
})

usersRouter.put('/update/:id', async (request, response) => {
  // * For Updating Profile Data
  console.log(request.body)
  const {
    Username,
    Email,
    role,
    password } = request.body
  // TODO: Have to Check Validity of Email
  if (!Username || !Email || !role || !password) {
    return response.status(400).json({
      error: 'Error in Input Fields for User Edit'
    })
  }
  const existingUser = await User.find({ Email })
  if (existingUser.length > 1) {
    return response.status(400).json({
      error: 'Email must be unique'
    })
  }
  const saltRounds = 10
  const passwordHash = await bcrypt.hash(password, saltRounds)
  const UserProfile = await User.findById(request.params.id)
  UserProfile.Username = Username
  UserProfile.Email = Email
  UserProfile.passwordHash = passwordHash
  UserProfile.role = role
  const updateduser = await User.findByIdAndUpdate(UserProfile._id, UserProfile, { new: true })
  console.log(updateduser)
  response.status(201).json(updateduser)
})

usersRouter.put('/connect/:id', async (request, response) => {
  // * For Updating Profile Data
  // console.log("entered connect")
  // console.log("connect",request.body)
  const {
    metamaskWAddress } = request.body
  // console.log("metamaskWalletAddress",metamaskWAddress)
  const UserProfile = await User.findById(request.params.id)
  // console.log("UserProfile",UserProfile)
  UserProfile.metamaskWAddress = metamaskWAddress
  const updateduser = await User.findByIdAndUpdate(UserProfile._id, UserProfile, { new: true })
  // console.log("Updateduser",updateduser)
  response.status(201).json(updateduser)
})

module.exports = usersRouter