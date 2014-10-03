
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
    @tailing = @fileIsOpen = yes
    @fileView.setScroll @fileView.lineCount
  	 
  didGetNewLines: -> 
    if @tailing then @fileView.setScroll @fileView.lineCount
    
  didScroll: ->
    @tailing = (@fileView.botLineNum is @fileView.lineCount-1)
    $lineNums = @fileView.find '.line-num'
    $lineNums.removeClass 'tail-hilite'
    # console.log 'didScroll', @tailing, $lineNums.length, @fileView.botLineNum, @fileView.lineCount
    if @tailing then $lineNums.last().addClass 'tail-hilite'
    
  destroy: -> 
    @isDestroyed = yes
    atom.workspaceView.find('.item-views .sticky-bar').remove()
    fs.unwatchFile @fileView.filePath, @watcher
    
    