# Meshblu Firehose Broadcast Example

Example project that creates 2 devices with appropriate whitelists and subscriptions, then sends from one to the other

## Install

Assumes Node.js (>= 5.x.x) is already installed

```shell
git clone https://github.com/octoblu/example-meshblu-firehose-broadcast.git
cd example-meshblu-firehose-broadcast
npm install
```

## To Run

```shell
# To run with defaults
npm start
# To print help
npm start -- --help
# Example using HTTP instead of HTTPS
npm start -- --meshblu-http-port 80 --meshblu-http-protocol http
# To run directly, so passing in args is prettier
./command.js --help
```

## What's happening

This program creates two devices, an emitter and a subscriber. The emitter broadcasts a message every second. The subscriber subscribes to the emitter's broadcasts, printing them out in the command line as it receives them.

In order for this to happen, a number of things have to happen:

1. Create `Emitter`
2. Create `Subscriber`
3. Add `Subscriber` to `Emitter's` broadcast.sent whitelist
4. Subscribe the `Subscriber` to the `Emitter's` broadcast.sent
5. Subscribe the `Subscriber` to its own broadcast.received
6. Connect the `Subscriber` to the Firehose
7. Send a message from the `Emitter`
8. Print out the message from the `Subscriber`
