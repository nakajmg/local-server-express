open = require 'open'
path = require 'path'
express = require 'express'
serveIndex = require 'serve-index'
portfinder = require 'portfinder'

module.exports =
  activate: (state) ->
    atom.commands.add "atom-workspace", "local-server-express:run", => @start()
    
  start: ->
    portfinder.getPort (err, port) =>
      @run port
  
  deactivate: ->
    @app?.close()
    @app = null
  
  serialize: ->

  run: (port) ->
    [projectPath ,filePath] = @getPaths()
    
    unless @app
      @app = express()
      @port = port
      @app.use express.static projectPath
      @app.use serveIndex projectPath,
        icons: true
      @app.listen port

    open "http://localhost:#{@port}/#{filePath}"

  getPaths: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path
    
    projectPaths = atom.project.getPaths()
    activeProjectPath = null
    
    projectPaths.forEach (projectPath) ->
      if filePath.indexOf(projectPath) isnt -1
        activeProjectPath = projectPath

    if typeof filePath == 'string'
      
      filePath = path.relative(activeProjectPath, filePath)
      filePath = if path.extname(filePath) is '.html' then filePath else ''
    else
      filePath = ''

    return [activeProjectPath, filePath]
