_              = require 'lodash'
MeshbluHttp    = require 'meshblu-http'
{EventEmitter} = require 'events'

class Emitter extends EventEmitter
  constructor: ({meshbluConfig}={}) ->
    throw new Error 'meshbluConfig is required' unless meshbluConfig?
    @meshbluConfig = _.clone meshbluConfig
    @meshblu = new MeshbluHttp {@meshbluConfig}
    @device  = {}

  addToBroadcastSentWhitelist: (uuid, callback) =>
    update = {
      $addToSet:
        'meshblu.whitelists.broadcast.sent': {uuid}
    }
    @meshblu.updateDangerously @getUuid(), update, callback


  getUuid: =>
    @device.uuid

  init: (callback) =>
    device = {
      meshblu:
        version: '2.0.0'
    }

    @meshblu.register device, (error, device) =>
      return callback error if error?
      _.assign @device, device
      _.assign @meshbluConfig, uuid: @device.uuid, token: @device.token
      @meshblu = new MeshbluHttp @meshbluConfig
      callback()

  message: (callback) =>
    message = {
      devices: ['*']
      payload:
        temperature: _.random(0, 100)
    }

    @meshblu.message message, callback


module.exports = Emitter
