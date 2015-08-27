# Description:
#   Twitter ego-searching for hubot
#
# Configuration:
#   HUBOT_TWITTER_EGOSEARCH_CONSUMER_KEY
#   HUBOT_TWITTER_EGOSEARCH_CONSUMER_SECRET
#   HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN
#   HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN_SECRET
#   HUBOT_TWITTER_EGOSEARCH_SEARCH_INTERVAL # defaults to "1000 * 60" msec
#
# Commands:
#   hubot egosearch add <query string> - Start searching
#   hubot egosearch rm <query string> - Stop searching
#   hubot egosearch list - List searching queries
#
# Author:
#   qckanemoto

sha1 = require 'sha1'
twitter = require 'twitter'

queries = {}
config =
  consumer_key: process.env.HUBOT_TWITTER_EGOSEARCH_CONSUMER_KEY
  consumer_secret: process.env.HUBOT_TWITTER_EGOSEARCH_CONSUMER_SECRET
  access_token_key: process.env.HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN
  access_token_secret: process.env.HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN_SECRET
maxTweets = 5
client = new twitter config

getSearchUrl = (q) ->
  "https://twitter.com/search?q=#{encodeURI(q)}"

getTweetUrl = (user, id_str) ->
  "https://twitter.com/#{user.screen_name}/status/#{id_str}"

createQuery = (robot, msg, q, user) ->
  query = new Query(q, null, user)
  key = sha1(q)
  queries[key] = query
  robot.brain.data.egosearch[key] = query.serialize()
  msg.send "Now searching for #{q} (#{getSearchUrl(q)})"

updateQuery = (robot, query) ->
  key = sha1(query.q)
  queries[key] = query
  robot.brain.data.egosearch[key] = query.serialize()

deleteQuery = (robot, msg, q) ->
  key = sha1(q)
  if queries[key]?
    delete queries[key]
    delete robot.brain.data.egosearch[key]
    msg.send "Stopped searching"
  else
    msg.send "Searcing job does not exist"

loadQueriesFromBrain = (robot) ->
  for own key, serialized of robot.brain.data.egosearch
    query = new Query(serialized[0], serialized[1], serialized[2])
    queries[key] = query

loopSearching = (robot) ->
  setInterval ->
    searchQueries(robot)
  , eval(process.env.HUBOT_TWITTER_EGOSEARCH_SEARCH_INTERVAL) or 1000 * 60

searchQueries = (robot) ->
  for key, query of queries
    robot.brain.data.egosearch[key] = query.serialize()
    client.get 'search/tweets', {q: query.q, count: maxTweets, since_id: query.since_id}, (error, tweets, response) ->
      if error
        console.log error
      else if tweets.statuses? and tweets.statuses.length > 0
        # remember last tweet
        query.since_id = tweets.statuses[0].id_str
        updateQuery robot, query
        envelope = user: query.user, room: query.user.room
        for tweet in tweets.statuses.reverse()
          robot.send envelope, getTweetUrl(tweet.user, tweet.id_str)

class Query
  constructor: (q, since_id, user) ->
    @q = q
    @since_id = since_id
    # cloning user because adapter may touch it later
    clonedUser = {}
    clonedUser[k] = v for k, v of user
    @user = clonedUser

  serialize: ->
    [@q, @since_id, @user]

module.exports = (robot) ->
  robot.brain.data.egosearch or= {}

  robot.brain.on 'loaded', =>
    loadQueriesFromBrain robot
    loopSearching robot

  robot.respond /egosearch (?:add|new|start) (.+)/i, (msg) ->
    createQuery robot, msg, msg.match[1], msg.message.user

  robot.respond /egosearch (?:rm|remove|del|delete|stop) (.+)/i, (msg) ->
    deleteQuery robot, msg, msg.match[1]

  robot.respond /egosearch (?:list|ls)/i, (msg) ->
    text = ''
    for key, query of queries
      if msg.message.user.room == query.user.room
        text += "\"#{query.q}\" (#{getSearchUrl(query.q)}) @#{query.user.room}\n"
    if text.length > 0
      msg.send text
    else
      msg.send 'Nothing here'
