'use babel';

import { CompositeDisposable } from 'atom';
import path from 'path';

let subscriptions, ink;

export function activate(state) {
  subscriptions = new CompositeDisposable;

  subscriptions.add(atom.commands.add('atom-workspace', {
    'atom-eval:evaluate': eval
  }));
}

export function deactivate() {
  subscriptions.dispose();
}

export function eval() {
  const editor = atom.workspace.getActiveTextEditor();
  if (editor.getGrammar().scopeName !== 'source.js') {
    atom.notifications.addError("Can't evaluate in this file.",
                                {detail: "Try a JavaScript file instead."});
    return;
  }
  if (editor.getPath() == null) {
    atom.notifications.addError("Can't evaluate in this file.",
                                {detail: "Make sure the file is saved."});
    return;
  }
  mod = require(editor.getPath());
}

export function consumeInk(o) {
  ink = o;
}
