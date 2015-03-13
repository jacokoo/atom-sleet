AtomSleetView = require './atom-sleet-view'
{sleetConfig, isSleet, compileToFile, haveCompiledFile} = require './helper'
{CompositeDisposable} = require 'atom'
path = require 'path'

module.exports = AtomSleet =
    config:
        compileUse:
            type: 'string'
            default: 'sleet'
            enum: ['sleet', 'sleet-handlebars']
        handlebarsBlockHelpers:
            type: 'array'
            default: []
        handlebarsInlineHelpers:
            type: 'array'
            default: []
        handlebarsPrecompile:
            type: 'boolean'
            default: false
        handlebarsPrecompileUseAmd:
            type: 'boolean'
            default: false
        handlebarsPrecompileUseCommonJs:
            type: 'boolean'
            default: false

    activate: (state) ->
        @subscriptions = new CompositeDisposable()

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace', 'atom-sleet:compile': => @compile()
        @subscriptions.add atom.commands.add 'atom-workspace', 'core:save': => @whenDidSave()

        @subscriptions.add atom.workspace.addOpener (uri) =>
            editor = if uri is 'atom-sleet://previewer' then @sleetView else null
            editor

    deactivate: ->
        @subscriptions.dispose()

    whenDidSave: ->
        activeEditor = atom.workspace.getActiveTextEditor()
        return unless isSleet activeEditor
        file = activeEditor.getPath()
        return unless haveCompiledFile file
        result = compileToFile activeEditor
        if result isnt true and not @sleetView
            atom.notifications.addError result.message, detail: result.stack

    compile: ->
        activeEditor = atom.workspace.getActiveTextEditor()
        return unless isSleet activeEditor
        compileToFile activeEditor

        @preview activeEditor

    preview: (editor) ->
        return @sleetView.setSourceEditor editor if @sleetView

        @sleetView = new AtomSleetView({})
        listener = @sleetView.onDidDestroy =>
            @sleetView = null
            listener.dispose()

        atom.workspace.open 'atom-sleet://previewer',
            split: 'right'
            activatePane: true
        .then =>
            @sleetView.setSourceEditor editor
