AtomSleetView = require './atom-sleet-view'
{isSleet, compileToFile, haveCompiledFile} = require './helper'
{CompositeDisposable} = require 'atom'
path = require 'path'

module.exports = AtomSleet =
    activate: (state) ->
        @subscriptions = new CompositeDisposable()

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-sleet:compile': => @compile()
        @subscriptions.add atom.commands.add 'atom-workspace', 'core:save': => @whenDidSave()

        @subscriptions.add atom.workspace.addOpener (uri) =>
            editor = if uri is 'atom-sleet://previewer' then AtomSleetView.get() else null
            editor

    deactivate: ->
        @subscriptions.dispose()
        AtomSleetView.destory()

    whenDidSave: ->
        activeEditor = atom.workspace.getActiveTextEditor()
        return unless isSleet activeEditor
        file = activeEditor.getPath()
        return unless haveCompiledFile file
        result = compileToFile activeEditor
        if result isnt true and not AtomSleetView.exists()
            atom.notifications.addError result.message, detail: result.stack
        AtomSleetView.create(activeEditor) if AtomSleetView.exists()

    compile: ->
        activeEditor = atom.workspace.getActiveTextEditor()
        return unless isSleet activeEditor
        compileToFile activeEditor

        @preview activeEditor

    preview: (editor) ->
        atom.workspace.open 'atom-sleet://previewer',
            split: 'right'
            activatePane: true
        .then =>
            AtomSleetView.create(editor)
