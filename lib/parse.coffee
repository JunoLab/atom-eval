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
        .replace(/'\.\.\//g, "'#{dir}/../")

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
    if start == -1 then return {}
    if ls[start].match /^module\.exports\s*=|^class/
      if ls[start].startsWith 'class' then isClass = true
      start++
      while start < ls.length and ls[start].match /^\s*$/
        start++
      return {} unless ls[start]
      indent = ls[start].match(/^\s*/)[0]
      start = @walkBack ls, row, indent
    end = @walkForward ls, start+1, indent

    code: ls.slice(start, end).join('\n')
    start: start
    end: end-1
    isClass: isClass

  parsekey: (code) ->
    match = code.match /^\s*@?(\w*):\s*([^]*)/
    isStatic = code.match(/^\s*@/)?
    return {code: code} unless match?
    [_, key, code] = match
    return {key, code, isStatic}

  firstLine: (code) ->
    code = code.split('\n')
    line = code[0]
    if code.length > 1
      line += ' ...'
    return line
