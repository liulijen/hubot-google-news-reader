path   = require 'path'
assert = require 'assert'

RSSReader  = require path.resolve 'libs', 'rss-reader'

describe 'RSSReader', ->

  it 'fetch test', ->
    @timeout 10000

    reader = new RSSReader {}

    reader.fetch 'http://news.google.com/news?cf=all&hl=zh-TW&pz=1&ned=tw&output=rss'
    .then (entries) ->
      assert.ok entries instanceof Array
      for entry in entries
        assert.equal typeof entry.url, 'string', '"url" property not exists'
        assert.equal typeof entry.title, 'string', '"title" property not exists'
