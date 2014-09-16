
# plugins/vtlf-tail

fs = require 'fs-plus'

module.exports =
class Tail
  
  constructor: (state, vtlfLibPath, @pluginMgr, @filePath, @fileView, reader, @lineMgr) ->
    console.log 'new Tail', @filePath
    @watcher = => 
      reader.buildIndex null, => @lineMgr.updateLinesInDOM()
    fs.watch @filePath, persistent: no, @watcher

  checkSticky: ->
    if @botLineNum > @lineCount
      if @fileView.find('.sticky-bar').length is 0
        width = @fileView.width()
        @fileView.append '<div class="sticky-bar highlight text-info" ' +
                         'style="width:'  + width + 'px; color:#666; ' +
                                 'height:' + @chrH + 'px; background-color:rgb(175,175,175,0.3); ' +
                                 'text-align:center">-- Tailing --</div>'
      @lineMgr.setScrollPos @lineCount
    else
      @fileView.find('.sticky-bar').remove()
  
  newLines: (@fileView, lineNumCharCount, @lineCount, @maxLineLen, @botLineNum) -> @checkSticky()
  scroll: (@fileView, topLineNum, linesVis, @botLineNum) -> @checkSticky()
  postFileOpen: -> @lineMgr.setScrollPos @lineCount
  
  destroy: -> 
    @fileView.find('.sticky-bar').remove()
    fs.unwatchFile @filePath, @watcher
    
    