# Description:
#   Pugme is the most important thing in life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot pug me - Receive a pug
#   hubot pug bomb N - get N pugs

module.exports = (robot) ->

  robot.respond /pug me/i, (msg) ->
    msg.http("http://pugme.herokuapp.com/random")
      .get() (err, res, body) ->
        if robot.adapterName is "telegram"
          _pug = JSON.parse(body).pug.replace(new RegExp('[0-9][0-9].media', 'g'), 'media')
          robot.emit 'telegram:invoke', 'sendPhoto', {
            chat_id: msg.envelope.room
            photo: _pug
          }, (error, response) ->
            if error != null
              robot.logger.error error
            robot.logger.debug response
        else
          msg.send JSON.parse(body).pug

  robot.respond /pug bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    msg.http("http://pugme.herokuapp.com/bomb?count=" + count)
      .get() (err, res, body) ->
        if robot.adapterName is "telegram"
          for pug in JSON.parse(body).pugs
            pug = pug.replace(new RegExp('[0-9][0-9].media', 'g'), 'media')
            robot.emit 'telegram:invoke', 'sendPhoto', {
              chat_id: msg.envelope.room
              photo: pug
            }, (error, response) ->
              if error != null
                robot.logger.error error
              robot.logger.debug response
        else
          msg.send pug for pug in JSON.parse(body).pugs

  robot.respond /how many pugs are there/i, (msg) ->
    msg.http("http://pugme.herokuapp.com/count")
      .get() (err, res, body) ->
        msg.send "There are #{JSON.parse(body).pug_count} pugs."

