const mongoose = require('mongoose')

const InsuranceOptionSchema = new mongoose.Schema({
    Name: { type: String, required: true },
    Description: { type: String, required: true },
    Price: { type: Number, required: true },
    Creationdate: { type: Date, required: true },
    Provider:{type:String},
    Payout:{type:Number,required:true},
    Users:  [
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User'
        }],
    ClaimRequests:[
        {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User'
        },
  
    ],
    Automated:{type:Boolean},

})
InsuranceOptionSchema.set('toJSON', {
    transform: (document, returnedObject) => {
        returnedObject.id = returnedObject._id.toString()
        delete returnedObject.__v 
    }
})

const InsuranceOption = mongoose.model('InsuranceOption', InsuranceOptionSchema)

module.exports = InsuranceOption