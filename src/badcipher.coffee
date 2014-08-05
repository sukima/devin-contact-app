require "buffer"
crypto = require "crypto"
xor    = require "bitwise-xor"

class BadCipher
  constructor: (data, key) ->
    return data if data instanceof BadCipher
    @data = if not Buffer.isBuffer(data)
      new Buffer(data, "utf8")
    else
      data
    @key = if key?
      if not Buffer.isBuffer(key)
        new Buffer(key, "binary")
      else
        key

  bind: (fn) ->
    result = fn(@data, @key)
    return this unless result?
    new BadCipher(result, @key)

  toString: (encoding) -> @data.toString(encoding)

  xor: -> @bind (data, key) -> xor(data, key)

  interleave: -> @bind (data, key) ->
    newData = []
    for v,i in data
      newData.push data[i]
      newData.push key[i]
    new Buffer(newData)

  deinterleave: -> @bind (data) ->
    newKey = []
    newData = []
    for v,i in data by 2
      newData.push data[i]
      newKey.push data[i+1]
    new BadCipher(Buffer(newData, "binary"), new Buffer(newKey, "binary"))

  @encrypt: (data, password) ->
    itemsBuf = new Buffer(JSON.stringify(data), "utf8")
    keyBuf   = crypto.pbkdf2Sync(password, "", 500, itemsBuf.length)
    new BadCipher(itemsBuf, keyBuf)
      .xor()
      .interleave()
      .toString("base64")

  @decrypt: (data) ->
    dataBuf = new Buffer(data, "base64")
    new BadCipher(dataBuf)
      .deinterleave()
      .xor()
      .toString("utf8")

module.exports = BadCipher
