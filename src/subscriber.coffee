async           = require 'async'
_               = require 'lodash'
MeshbluFirehose = require 'meshblu-firehose-socket.io'
MeshbluHttp     = require 'meshblu-http'
{EventEmitter}  = require 'events'

class Subscriber extends EventEmitter
  constructor: ({firehoseConfig, meshbluConfig}={}) ->
    throw new Error 'firehoseConfig is required' unless firehoseConfig?
    throw new Error 'meshbluConfig is required' unless meshbluConfig?
    @firehoseConfig = _.clone firehoseConfig
    @meshbluConfig = _.clone meshbluConfig
    @meshblu = new MeshbluHttp {@meshbluConfig}
    @device = {}

  getUuid: =>
    @device.uuid

  init: (emitterUuid, callback) =>
    async.series [
      @_createDevice
      @_subscribeToOwnBroadcastReceived
      async.apply(@subscribeToBroadcastSent, emitterUuid)
      @_establishFirehose
    ], callback

  subscribeToBroadcastReceived: (uuid, callback) =>
    subscription = {
      type: 'broadcast.received'
      emitterUuid: uuid
      subscriberUuid: @getUuid()
    }
    @meshblu.createSubscription subscription, callback

  subscribeToBroadcastSent: (uuid, callback) =>
    subscription = {
      type: 'broadcast.sent'
      emitterUuid: uuid
      subscriberUuid: @getUuid()
    }
    @meshblu.createSubscription subscription, callback

  _createDevice: (callback) =>
    @meshblu.register {}, (error, device) =>
      return callback error if error?
      _.assign @device, device
      _.assign @meshbluConfig, uuid: @device.uuid, token: @device.token
      _.assign @firehoseConfig, uuid: @device.uuid, token: @device.token
      @meshblu = new MeshbluHttp @meshbluConfig
      callback()

  _establishFirehose: (callback) =>
    @firehose = new MeshbluFirehose meshbluConfig: @firehoseConfig
    @firehose.on 'message', (message) => @emit 'message', message
    @firehose.connect uuid: @getUuid(), callback

  _subscribeToOwnBroadcastReceived: (callback) =>
    @subscribeToBroadcastReceived @getUuid(), callback

module.exports = Subscriber
