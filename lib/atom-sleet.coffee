AtomSleetView = require './atom-sleet-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomSleet =
  atomSleetView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomSleetView = new AtomSleetView(state.atomSleetViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomSleetView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-sleet:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomSleetView.destroy()

  serialize: ->
    atomSleetViewState: @atomSleetView.serialize()

  toggle: ->
    console.log 'AtomSleet was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
