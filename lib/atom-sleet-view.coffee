{TextEditor} = require 'atom'
{compileToEditor, isSleet} = require './helper'

view = null
targetChangeListener = null
viewDisposedListener = null
changeEditor = (editor) ->
    targetChangeListener.dispose() if targetChangeListener
    targetChangeListener = editor.onDidSave => compileToEditor(editor, view)
    compileToEditor editor, view

createView = ->
    v = atom.workspace.buildTextEditor()
    viewDisposedListener = v.onDidDestroy ->
        targetChangeListener?.dispose()
        viewDisposedListener?.dispose()
        view = null;
    v

module.exports =
    create: (editor) ->
        view = createView() if not view
        return unless editor and isSleet(editor)
        changeEditor editor
        view

    destory: ->
        view?.dispose()

    exists: -> view isnt null

    get: -> view or= createView()
