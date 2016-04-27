async          = require 'async'
{EventEmitter} = require 'events'
Emitter = require './emitter'
Subscriber = require './subscriber'

class Conductor extends EventEmitter
  constructor: ({firehoseConfig, meshbluConfig}={}) ->
    throw new Error 'firehoseConfig is required' unless firehoseConfig?
    throw new Error 'meshbluConfig is required' unless meshbluConfig?
    @emitter = new Emitter {meshbluConfig}
    @subscriber = new Subscriber {firehoseConfig, meshbluConfig}
    @subscriber.on 'message', (message) => @emit 'subscriber:message', message

  init: (callback) =>
    async.series [
      @_createEmitter
      @_createSubscriber
      @_updateEmitter
    ], callback

  message: =>
    @emitter.message (error) =>
      @emit 'error', error if error?

  startMessaging: (callback) =>
    setInterval @message, 1000

  _createEmitter: (callback) =>
    @emitter.init callback

  _createSubscriber: (callback) =>
    @subscriber.init @emitter.getUuid(), callback

  _updateEmitter: (callback) =>
    @emitter.addToBroadcastSentWhitelist @subscriber.getUuid(), callback

module.exports = Conductor
