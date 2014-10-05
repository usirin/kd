KDObject = require './object'

VText    = require 'vtree/vtext'

module.exports = class KDTextObject extends KDObject

  constructor: (text) ->
    @text = text or ""

    super text

  buildTree: -> new VText @text

  setParent: (parent) -> @parent = parent

  orphanize: -> @parent?.removeSubview this

  destroy: ->

    @orphanize()

    super


