const fs = require('fs')
const path = require('path')
try {
  fs.unlinkSync(path.join(__dirname, 'local.json'))
} catch (err) {}

const AWS = require('aws-sdk')
AWS.config.update({ region: 'us-west-1' })
const ssm = new AWS.SSM()
var serviceName = require('../package.json').name

async function getConfig() {
  var params = {
    Name: serviceName,
    WithDecryption: true
  }
  let res = await ssm.getParameter(params).promise()
  let settings = res.Parameter.Value
  writeLocalConfig(settings)
}

function writeLocalConfig(settings) {
  fs.writeFileSync(path.join(__dirname, 'local.json'), settings)
}

getConfig()
