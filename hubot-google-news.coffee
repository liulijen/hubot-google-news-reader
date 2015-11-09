# Description:
#   Hubot WeirdMeetup Blog Reader
#
# Commands:
#   hubot news
#   hubot news category|help
#
# Author:
#   @golbin

'use strict'

path      = require 'path'
_         = require 'lodash'
Promise   = require 'bluebird'
RSSReader = require path.join __dirname, '/libs/rss-reader'

NEWS_FEED = {
  all: 'http://news.google.com/news?cf=all&hl=zh-TW&pz=1&ned=tw&output=rss',
  it: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=t&output=rss',
  politics: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=p&output=rss',
  business: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=b&output=rss',
  society: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=y&output=rss',
  life: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=l&output=rss',
  world: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=w&output=rss',
  enter: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=e&output=rss',
  sports: 'http://news.google.com/news?pz=1&cf=all&ned=tw&hl=zh-TW&topic=s&output=rss',
}

CATEGORY = []

for key, val of NEWS_FEED
  CATEGORY.push(key)

  NEWS_FEED[key] = {
    url: val,
    updated: 0,
    entries: []
  }

CACHE_EXPIRES = 60 * 1000# milliseconds
DEFAULT_NEWS_NUM = 3

module.exports = (robot) ->
  reader = new RSSReader robot

  robot.respond /news(\s*[a-z]*)/i, (msg) ->
    if msg.match[1]
      if msg.match[1].trim() == 'help'
        msg.send "Category: " + CATEGORY.join(', ')
        return
      else if NEWS_FEED[msg.match[1].trim()]
        category = msg.match[1].trim()
      else
        msg.send msg.match[1].trim() + " There are no categories.\nCategory: " + CATEGORY.join(',')
        return
    else
      category = 'all'

    if Date.now() > NEWS_FEED[category].updated + CACHE_EXPIRES
      reader.fetch(NEWS_FEED[category].url)
      .then (entries) ->
        NEWS_FEED[category].entries = entries
        NEWS_FEED[category].updated = Date.now()
        for entry in NEWS_FEED[category].entries.splice(0, DEFAULT_NEWS_NUM)
          msg.send entry.toString()
      .catch (err) ->
        msg.send "Failed to get the news."
    else
      for entry in NEWS_FEED[category].entries.splice(0, DEFAULT_NEWS_NUM)
        msg.send entry.toString()
      msg.send "Update Time: " + new Date(NEWS_FEED[category].updated)
