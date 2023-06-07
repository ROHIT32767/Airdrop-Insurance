const InsuranceOption = require("../models/InsuranceOption.model")
const config = require('../utils/config')
const { request } = require('express')
const InsuranceOptionRouter = require('express').Router()
InsuranceOptionRouter.post('/', async (request, response) => {
    const { Name,
        Description,
        Price,
        Provider,
        Payout, 
        Automated } = request.body
    if (!Name || !Description) {
        return response.status(400).json({
            error: 'Name or Description is Null'
        })
    }
    const Creationdate = Date.now()
    const NewInsuranceOption = new InsuranceOption({
        Name,
        Description,
        Price,
        Creationdate,
        Provider,
        Payout,
        Users:[],
        Automated
    })
    const savedInsuranceOption = await NewInsuranceOption.save()
    console.log(savedInsuranceOption)
    response.status(201).json(savedInsuranceOption)
})

InsuranceOptionRouter.get('/', async (request, response) => {
    const AllInsuranceOptions = await InsuranceOption
        .find({}).populate('Users').populate('ClaimRequests')
    response.json(AllInsuranceOptions)
})

InsuranceOptionRouter.get('/:id', async (request, response) => {
    const ID = request.params.id
    const GetInsuranceOption = await InsuranceOption.findById(ID).populate('Users').populate('ClaimRequests')
    console.log(GetInsuranceOption)
    response.json(GetInsuranceOption)
})

InsuranceOptionRouter.delete('/:id', async (request, response) => {
    const ID = request.params.id
    const DeleteInsuranceOption = await InsuranceOption.findByIdAndDelete(ID).populate('Users').populate('ClaimRequests')
    response.json(DeleteInsuranceOption)
})

// * Related to Accepting/Rejecting Join Requests
InsuranceOptionRouter.put('/accept/:id', async (request, response) => {
    console.log(request.body)
    const { UserID } = request.body
    if (!UserID) {
        return response.status(400).json({
            error: 'UserID is empty in Accept Request'
        })
    }
    const GetInsuranceOption = await InsuranceOption.findById(request.params.id)
    GetInsuranceOption.ClaimRequests = GetInsuranceOption.ClaimRequests.filter(element => element != UserID)
    GetInsuranceOption.Users = GetInsuranceOption.Users.filter(element => element!=UserID)
    const updatedInsuranceOption = await InsuranceOption.findByIdAndUpdate(GetInsuranceOption._id, GetInsuranceOption, { new: true }).populate('Users').populate('ClaimRequests')
    console.log(updatedInsuranceOption)
    response.status(201).json(updatedInsuranceOption)
})

InsuranceOptionRouter.put('/reject/:id', async (request, response) => {
    console.log(request.body)
    const { UserID } = request.body
    if (!UserID) {
        return response.status(400).json({
            error: 'UserID is empty in Reject Request'
        })
    }
    const GetInsuranceOption = await InsuranceOption.findById(request.params.id)
    GetInsuranceOption.ClaimRequests = GetInsuranceOption.ClaimRequests.filter(element => element != UserID)
    const updatedInsuranceOption = await InsuranceOption.findByIdAndUpdate(GetInsuranceOption._id, GetInsuranceOption, { new: true }).populate('Users').populate('ClaimRequests')
    console.log(updatedInsuranceOption)
    response.status(201).json(updatedInsuranceOption)
})

InsuranceOptionRouter.put('/claim/:id', async (request, response) => {
    console.log(request.body)
    const { UserID } = request.body
    if (!UserID) {
        return response.status(400).json({
            error: 'UserID is empty in Reject Request'
        })
    }
    const GetInsuranceOption = await InsuranceOption.findById(request.params.id)
    GetInsuranceOption.ClaimRequests = GetInsuranceOption.ClaimRequests.concat(UserID)
    const updatedInsuranceOption = await InsuranceOption.findByIdAndUpdate(GetInsuranceOption._id, GetInsuranceOption, { new: true }).populate('Users').populate('ClaimRequests')
    console.log(updatedInsuranceOption)
    response.status(201).json(updatedInsuranceOption)
})

InsuranceOptionRouter.put('/buy/:id', async (request, response) => {
    console.log(request.body)
    const { UserID } = request.body
    if (!UserID) {
        return response.status(400).json({
            error: 'UserID is empty in Reject Request'
        })
    }
    const GetInsuranceOption = await InsuranceOption.findById(request.params.id)
    GetInsuranceOption.Users = GetInsuranceOption.Users.concat(UserID)
    const updatedInsuranceOption = await InsuranceOption.findByIdAndUpdate(GetInsuranceOption._id, GetInsuranceOption, { new: true }).populate('Users').populate('ClaimRequests')
    console.log(updatedInsuranceOption)
    response.status(201).json(updatedInsuranceOption)
})

module.exports = InsuranceOptionRouter










