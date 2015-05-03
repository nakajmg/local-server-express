open = require "open"
path = require "path"
express = require "express"
serveIndex = require "serve-index"
portfinder = require "portfinder"

module.exports =
  activate: (state) ->
    atom.commands.add "atom-workspace", "local-server-express:run", => @start()
    @server = []
    
  start: ->
    portfinder.getPort (err, port) =>
      @run port
  
  deactivate: ->
    @server.forEach (project) ->
      project.server?.close()

    @server = null
  
  serialize: ->

  run: (port) ->
    [projectPath ,filePath] = @getPaths()
    
    if !projectPath
      console.warn "[local-server-express] must be open some project."
      return
    
    unless @server[projectPath]
      server = express()
      server.use express.static projectPath
      server.use serveIndex projectPath,
        icons: true
      server.listen port
      
      @server[projectPath] = {server, port}
      
    open "http://localhost:#{@server[projectPath].port}/#{filePath}"

  getPaths: ->
    editor = atom.workspace.getActivePaneItem()
    file = editor?.buffer.file
    filePath = file?.path
    
    projectPaths = atom.project.getPaths()
    activeProjectPath = null
    
    if filePath
      projectPaths.forEach (projectPath) ->
        if filePath.indexOf(projectPath) isnt -1
          activeProjectPath = projectPath

      if typeof filePath == "string"
        filePath = path.relative(activeProjectPath, filePath)
        filePath = if path.extname(filePath) is ".html" then filePath else ""
      else
        filePath = ""
        
    else
      activeProjectPath = projectPaths[0]
      filePath = ""

    [activeProjectPath, filePath]
