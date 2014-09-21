
# vtlf-tail

fs = require 'fs-plus'

module.exports =
class Tail
  
  constructor: (@fileView) ->
    @watcher = => 
      if @isDestroyed then return
      if not @fileIsOpen then setTimeout @watcher, 100; return
      @fileView.reader.buildIndex null, => @fileView.haveNewLines()
    fs.watch @fileView.filePath, persistent: no, @watcher

    @fileView.onDidOpenFile    => @didOpenFile()
    @fileView.onDidGetNewLines => @didGetNewLines()
    @fileView.onDidScroll      => @didScroll()

  didOpenFile: -> 
    @fileView.setScroll @fileView.lineCount
    @fileIsOpen = yes
  	 
  didGetNewLines: -> 
    if @atBottom then @fileView.setScroll @fileView.lineCount
  
  didScroll: ->
    if @isDestroyed then return
    
    if not @atBottom and @fileView.botLineNum is @fileView.lineCount-1 
      if atom.workspaceView.find('.item-views .sticky-bar').length is 0
        @fileView.find '.vtlf-inner'
            .after "<div class='sticky-bar highlight text-info'
                         style='height:#{@fileView.chrH-4}px; color:#666;
                                -webkit-order:3;
                                background-color:rgb(175,175,175,0.3);
                                text-align:center; position:relative'>-- Tailing --</div>"
      @atBottom = yes
      return
  
    if @atBottom and @fileView.botLineNum isnt @fileView.lineCount-1 
      atom.workspaceView.find('.item-views .sticky-bar').remove()
      @atBottom = no
    
  destroy: -> 
    @isDestroyed = yes
    atom.workspaceView.find('.item-views .sticky-bar').remove()
    fs.unwatchFile @fileView.filePath, @watcher
    
    