# hubot-twitter-egosearch

[![npm version](https://img.shields.io/npm/v/hubot-twitter-egosearch.svg)](https://www.npmjs.com/package/hubot-twitter-egosearch)
[![npm downloads](https://img.shields.io/npm/dm/hubot-twitter-egosearch.svg)](https://www.npmjs.com/package/hubot-twitter-egosearch)

Twitter ego-searching for hubot.

## Installation

Install via npm.

```bash
$ cd /path/to/hubot
$ npm install --save hubot-twitter-egosearch
```

And add to `external-scripts.json`.

```bash
$ cat external-scripts.json
["hubot-twitter-egosearch"]
```

## Configuration

```bash
# required
$ export HUBOT_TWITTER_EGOSEARCH_CONSUMER_KEY="twitter_consumer_key_here"
$ export HUBOT_TWITTER_EGOSEARCH_CONSUMER_SECRET="twitter_consumer_secret_here"
$ export HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN="twitter_access_token_here"
$ export HUBOT_TWITTER_EGOSEARCH_ACCESS_TOKEN_SECRET="twitter_access_token_secret_here"

# optional
$ export HUBOT_TWITTER_EGOSEARCH_SHOW_DETAIL="true" # if "true" then response will be more detailed
$ export HUBOT_TWITTER_EGOSEARCH_SEARCH_INTERVAL="1000 * 60 * 5" # defaults to "1000 * 60" msec
```

## Usage

```bash
# Start searching with "hubot script"
human> hubot egosearch add hubot script
hubot> [13551] Now searching for hubot script

# Stop searching with "hubot script"
human> hubot egosearch rm 13551
hubot> Stopped searching for hubot script

# List searching keywords
human> hubot egosearch list
hubot> [13551] hubot script @room
hubot> [53595] some search word @room

# Also can use advanced search query
human> hubot egosearch add "hubot-twitter-egosearch" -from:ttskch
hubot> [29107] Now searching for "hubot-twitter-egosearch" -from:ttskch
```
