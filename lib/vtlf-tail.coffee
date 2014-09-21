
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
      console.log 'sticky-bar add', {botLineNum: @fileView.botLineNum, lineCount: @fileView.lineCount}
      if atom.workspaceView.find('.item-views .sticky-bar').length is 0
        @fileView.find '.vtlf-inner'
            .after "<div class='sticky-bar highlight text-info'
                         style='height:#{@fileView.chrH}px; color:#666;
                                -webkit-order:3;
                                background-color:rgb(175,175,175,0.3);
                                text-align:center; position:relative'>-- Tailing --</div>"
      @atBottom = yes
      # worlds worst kludge
      count = 20
      do stabilize = =>
        @fileView.setScroll 9e99
        if --count > 0 then setTimeout stabilize, 50
      return
  	     
    if @atBottom and @fileView.botLineNum < @fileView.lineCount-1
      console.log 'sticky-bar remove', {botLineNum: @fileView.botLineNum, lineCount: @fileView.lineCount}
      atom.workspaceView.find('.item-views .sticky-bar').remove()
      @atBottom = no
      @fileView.setScrollRelative -1
    
  destroy: -> 
    @isDestroyed = yes
    console.log 'tail destroyed'
    atom.workspaceView.find('.item-views .sticky-bar').remove()
    fs.unwatchFile @fileView.filePath, @watcher
    
    