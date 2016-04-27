async         = require 'async'
commander     = require 'commander'
MeshbluConfig = require 'meshblu-config'
Conductor     = require './src/conductor'
PACKAGE_JSON  = require './package.json'

class Command
  constructor: (@argv) ->

  getOptions: =>
    commander
      .version PACKAGE_JSON.version
      .option '--meshblu-firehose-hostname <hostname>', 'Meshblu Socket.io Firehose Hostname', 'meshblu-firehose-socket-io.octoblu.com'
      .option '--meshblu-firehose-port <port>',     'Meshblu Socket.io Firehose Port', '443'
      .option '--meshblu-firehose-protocol <protocol>', 'Meshblu Socket.io Firehose Protocol', 'https'
      .option '--meshblu-http-hostname <hostname>', 'Meshblu HTTP Hostname', 'meshblu.octoblu.com'
      .option '--meshblu-http-port <port>',     'Meshblu HTTP Port', '443'
      .option '--meshblu-http-protocol <protocol>', 'Meshblu HTTP Protocol', 'https'
      .parse @argv

    return {
      firehoseConfig:
        hostname: commander.meshbluFirehoseHostname
        port: commander.meshbluFirehosePort
        protocol: commander.meshbluFirehoseProtocol
      meshbluConfig:
        hostname: commander.meshbluHttpHostname
        port: commander.meshbluHttpPort
        protocol: commander.meshbluHttpProtocol
    }

  panic: (error) =>
    try
      throw new Error error.message
    catch newError
      console.error newError.stack
      console.error code: error.code if error.code?
      process.exit 1

  run: =>
    {firehoseConfig, meshbluConfig} = @getOptions()

    @conductor = new Conductor {firehoseConfig, meshbluConfig}
    @conductor.on 'emitter:message', @onEmitterMessage
    @conductor.on 'subscriber:message', @onSubscriberMessage

    console.log 'Setting up meshblu devices. Takes ~5 seconds'
    async.series [
      @conductor.init
      @conductor.startMessaging
    ], (error) =>
      return @panic error if error?
      console.log 'Setup complete. Messaging'

  onEmitterMessage: (message) =>
    console.log '\nemitter received a message: '
    console.log JSON.stringify(message, null, 2)

  onSubscriberMessage: (message) =>
    console.log '\nsubscriber received a message: '
    console.log JSON.stringify(message, null, 2)

module.exports = Command
