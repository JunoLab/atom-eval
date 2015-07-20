path = require 'path'

module.exports =
  getHeader: (code) ->
    header = ''
    for l in code.split '\n'
      return header if l.match /^module\.exports\s*=/
      header += l + '\n'
    return ''

  patchHeader: (file, code) ->
    dir = path.dirname file
    code.replace(/'\.\//g, "'#{dir}/")

  insertHeader: (header, code) -> "#{header}\n(#{code}\n)"

  walkBack: (ls, i, indent) ->
    r = new RegExp "^" + indent + "[^\\s]"
    while i >= 0 and not ls[i].match r
      i--
    return i

  walkForward: (ls, i, indent) ->
    r = new RegExp "^" + indent + "[^\\s]"
    while i < ls.length and not ls[i].match r
      i++
    return i

  getBlock: (code, row) ->
    ls = code.split('\n')
    indent = ""
    start = @walkBack ls, row, indent
    if start == -1 then return
    if ls[start].match /^module\.exports\s*=/
      start++
      while start < ls.length and ls[start].match /^\s*$/
        start++
      indent = ls[start].match(/^\s*/)[0]
      start = @walkBack ls, row, indent
    end = @walkForward ls, start+1, indent
    ls.slice(start, end).join('\n')

  parsekey: (code) ->
    match = code.match /\s*(\w*):\s*([^]*)/
    return {code: code} unless match?
    [_, key, code] = match
    return {key: key, code: code}

  firstLine: (code) ->
    code = code.split('\n')
    line = code[0]
    if code.length > 1
      line += ' ...'
    return line
