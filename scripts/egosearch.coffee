# Description:
#   Twitter ego-searching for hubot
#
# Configuration:
#   HUBOT_TWITTER_EGOSEARCH_CONSUMER_KEY
#   HUBOT_TWITTER_EGOSEARCH_CONSUMER_SECRET
#   HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN
#   HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN_SECRET
#   HUBOT_TWITTER_EGOSEARCH_SHOW_DETAIL # if "true" then response will be more detailed
#   HUBOT_TWITTER_EGOSEARCH_SEARCH_INTERVAL # defaults to "1000 * 60" msec
#
# Commands:
#   hubot egosearch add <query string> - Start searching
#   hubot egosearch rm <query string> - Stop searching
#   hubot egosearch list - List searching queries
#
# Author:
#   ttskch

twitter = require 'twitter'
dateformat = require 'dateformat'

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

persistQuery = (robot, id, query) ->
  queries[id] = query
  robot.brain.data.egosearch[id] = query.serialize()

createQuery = (robot, msg, q, user) ->
  query = new Query(q, null, user)
  id = Math.floor(Math.random() * 100000) while !id? || queries[id]?
  persistQuery robot, id, query
  msg.send "[#{id}] Now searching for #{q} (#{getSearchUrl(q)})"

deleteQuery = (robot, msg, id) ->
  if queries[id]?
    q = queries[id].q
    delete queries[id]
    delete robot.brain.data.egosearch[id]
    msg.send "Stopped searching for #{q}"
  else
    msg.send "Searcing job does not exist"

loadQueriesFromBrain = (robot) ->
  for own id, serialized of robot.brain.data.egosearch
    query = new Query(serialized[0], serialized[1], serialized[2])
    queries[id] = query

loopSearching = (robot) ->
  setInterval ->
    searchQueries(robot)
  , eval(process.env.HUBOT_TWITTER_EGOSEARCH_SEARCH_INTERVAL) or 1000 * 60

searchQueries = (robot) ->
  for id, query of queries
    searchQueryAsync(id, query)
      .then (data) ->
        data.query.since_id = data.tweets.statuses[0].id_str
        persistQuery robot, data.id, data.query
        envelope = user: data.query.user, room: data.query.user.room
        for tweet in data.tweets.statuses.reverse()
          text = "[#{data.id}] #{data.query.q}\n" + getTweetUrl(tweet.user, tweet.id_str)
          if process.env.HUBOT_TWITTER_EGOSEARCH_SHOW_DETAIL
            date = dateformat(new Date(tweet.created_at), 'yyyy-mm-dd')
            text += "\n> #{tweet.text}\n> \n> - #{tweet.user.name} (@#{tweet.user.screen_name}) #{date}"
          robot.send envelope, text
      .catch (error) ->
        console.log error

searchQueryAsync = (id, query) ->
  new Promise (resolve, reject) ->
    client.get 'search/tweets', {q: query.q, count: maxTweets, since_id: query.since_id}, (error, tweets, response) ->
      if error
        reject error
      else if !tweets.statuses? or tweets.statuses.length <= 0
        reject 'No results'
      else
        resolve {id: id, query: query, tweets: tweets}

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
    for id, query of queries
      if msg.message.user.room == query.user.room
        text += "[#{id}] #{query.q} (#{getSearchUrl(query.q)}) @#{query.user.room}\n"
    if text.length > 0
      msg.send text
    else
      msg.send 'Nothing here'
