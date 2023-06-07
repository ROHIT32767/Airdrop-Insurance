const config = require('./utils/config')
const express = require('express')
require('express-async-errors')
const app = express()
const cors = require('cors')
const usersRouter = require('./controllers/UserRouter')
const loginRouter = require('./controllers/login')
const InsuranceOptionRouter = require('./controllers/InsuranceOptionRouter')
const middleware = require('./utils/middleware')
const logger = require('./utils/logger')
const mongoose = require('mongoose')
const mongoUrl = config.MONGODB_URI
const connection = mongoose.connection
mongoose.set("strictQuery", false)
mongoose.connect(mongoUrl, { useNewurlParser: true }).then(() => {
  logger.info('connected to MongoDB')
})
  .catch((error) => {
    logger.error('error connecting to MongoDB:', error.message)
  })
connection.once('open', () => {
  logger.info(`MongoDB Database connection Established Successfully`)
})
app.use(cors())
app.use(express.json())
app.use(middleware.requestLogger)
app.use('/api/users', usersRouter)
app.use('/api/login', loginRouter)
app.use(middleware.tokenExtractor)
app.use(middleware.userExtractor)
app.use('/api/InsuranceOption',InsuranceOptionRouter)
app.use(middleware.unknownEndpoint)
app.use(middleware.errorHandler)
module.exports = app