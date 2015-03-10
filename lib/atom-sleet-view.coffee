{TextEditor} = require 'atom'
{compileToEditor, isSleet} = require './helper'

module.exports = class AtomSleetView extends TextEditor
    constructor: ->
        super
        @listener = atom.commands.add 'atom-workspace', 'core:save': =>
            @setSourceEditor atom.workspace.getActiveTextEditor()

    getTitle: ->
        'Sleet Preview' + (if @source then ' - ' + @source.getTitle() else '')

    setSourceEditor: (editor) ->
        return unless editor and isSleet(editor)
        return if editor is @source

        if @sourceListener
            @sourceListener.dispose()
            @sourceListener = null

        @source = editor
        @sourceListener = @source.onDidSave => compileToEditor @source, @
        compileToEditor @source, @

    destroyed: ->
        @sourceListener?.dispose()
        @listener.dispose()
        super
