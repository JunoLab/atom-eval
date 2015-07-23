{CompositeDisposable} = require 'atom'

parse = require './parse'
run = require './eval'

module.exports = AtomEval =
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-eval:evaluate': =>
      @eval()

  deactivate: ->
    @subscriptions.dispose()

  eval: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor.getGrammar().scopeName != 'source.coffee'
      atom.notifications.addError("Can't evaluate in this file."
                                  {detail: "Try a CoffeeScript file instead."})
      return
    if not editor.getPath()?
      atom.notifications.addError("Can't evaluate in this file."
                                  {detail: "Make sure the file is saved."})
      return

    mod = run.module editor.getPath()
    header = parse.patchHeader editor.getPath(),
                               parse.getHeader editor.getText()

    for sel in editor.getSelections()

      if sel.isEmpty()
        {code, start, end} = parse.getBlock editor.getText(),
                                            sel.cursor.getBufferPosition().row
        continue unless code?
        @ink?.highlight editor, start, end
      else
        code = sel.getText()
      first = parse.firstLine(code)
      {code, key} = parse.parsekey code
      code = parse.insertHeader(header, code)
      console.log first + ' ='
      console.log run.eval mod, code, key

  consumeInk: (ink) ->
    @ink = ink
