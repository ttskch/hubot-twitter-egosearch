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
hubot> hubot egosearch add hubot script

# Stop searching with "hubot script"
hubot> hubot egosearch rm hubot script

# List searching keywords
hubot> hubot egosearch list

# Also can use advanced search query
hubot> hubot egosearch add "hubot-twitter-egosearch" -from:qckanemoto
```
