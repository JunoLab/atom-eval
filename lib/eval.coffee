vm = require 'vm'
path = require 'path'
coffee = require 'coffee-script'
parse = require './parse'

module.exports =

  getAtomPath: (p) ->
    if m = p.match /atom[\\/]src[\\/](.*)\.coffee/
      [_, name]= m
      p = path.join process.resourcesPath, 'app.asar', 'src', name + '.js'
    p

  module: (path) ->
    return 'window' unless path?
    return "require('#{parse.escape @getAtomPath path}')"

  indent: (code) ->
    code.split('\n').map((n) -> '  ' + n).join('\n')

  coffeestr: (code) ->
    """
    ->
    #{@indent(code)}
    """

  coffee: (code) ->
    # console.log @coffeestr code
    code = coffee.compile(@coffeestr(code), {bare:true}) # -> to treat code as expression
    code = code.substring(0, code.length-2) # remove trailing semicolon

  wrapModule: (mod, code) ->
    "#{code}.call(#{mod})"

  eval: (mod, code, key) ->
    result = vm.runInThisContext @wrapModule mod, @coffee(code)
    if key?
      mod = vm.runInThisContext(mod)
      mod[key] = result
    return result
