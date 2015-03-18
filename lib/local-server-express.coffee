LocalServerExpress = require './local-server-express-view'

module.exports =
  localServerExpressView: null
  
  activate: (state) ->
    @localServerExpressView = new LocalServerExpress(state.atomBrowserSyncViewState)
  
  deactivate: ->
    @localServerExpressView.destroy()
  
  serialize: ->
    localServerExpressViewState: @localServerExpressView.serialize()
