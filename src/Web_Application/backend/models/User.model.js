const mongoose = require('mongoose')

const userSchema = new mongoose.Schema({
  Username: {type:String,required:true},
  Email:{type:String,required:true,unique:true},
  passwordHash: {type:String,required:true},
  metamaskPK: {type:String},
  metamaskWAddress: {type:String},
  role: {type:String,required:true},
  Kycverified : {type:Boolean},
  CoinbaseVerified : {type:Boolean},
  Coinbase_id: {type:String},
  creationdate:{type:Number}
})

userSchema.set('toJSON', {
  transform: (document, returnedObject) => {
    returnedObject.id = returnedObject._id.toString()
    delete returnedObject.__v
    // the passwordHash should not be revealed
    delete returnedObject.passwordHash
  }
})

const User = mongoose.model('User', userSchema)

module.exports = User