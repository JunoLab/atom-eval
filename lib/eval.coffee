vm = require 'vm'
coffee = require 'coffee-script'

module.exports =
  escape: (path) ->
    path.replace /\\/g, "\\\\"

  module: (path) ->
    return 'window' unless path?
    return "require('#{@escape(path)}')"

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
    result = vm.runInThisContext (@wrapModule mod, @coffee(code))
    if key?
      mod = vm.runInThisContext(mod)
      mod[key] = result
    return result
