h               = require 'virtual-hyperscript'
{ diff, patch } = require 'virtual-dom'
createElement   = require 'virtual-dom/create-element'
KDView          = require './view.coffee'
# TODO: change this to KDTextNode
KDTextObject    = require './textobject.coffee'
_               = require '../../libs/underscore-min.1.3.js'

Delegator = require 'dom-delegator'

delegator = Delegator()

delegator.listenTo 'mouseover'

module.exports = class RView extends KDView

  @mixin = (target) -> _.extend target, RView::prototype

  #############################################
  ############# OVERRIDEN METHODS #############
  #############################################

  constructor: (options = {}, data) ->

    @__tree__     = null
    # this is
    @__rootNode__ = null

    options.attributes or= {}

    super options, data


  defaultInit: ->

    super

    @createElement()


  getTree: -> @__tree__

  setTree: (tree) -> @__tree__ = tree

  getRootNode: -> @__rootNode__

  setRootNode: (node) -> @__rootNode__ = node

  getSubViews: -> @subViews

  unsetParent: -> @parent = undefined

  # setDomElement: -> super

  setDomId: (id) -> @setOption 'domId', id

  # setDataId: (id) ->
  #   attributes = @getOptions().attributes
  #   attributes['data-id'] = id
  #   @setOption 'attributes', attributes


  bindEvents: ->

    eventsToBeBound = "mousedown mouseup click dblclick".split " "

    instanceEvents  = @getOptions().bind
    instanceEvents  = instanceEvents.trim().split " "  if instanceEvents

    for event in instanceEvents
      eventsToBeBound.push event  unless event in eventsToBeBound

    @eventsToBeBound = eventsToBeBound


  addSubView: (args...) ->
    warn 'RView::addSubView is deprecated, use RView::addSubview instead.'
    @addSubview args...


  # this should be a private function,
  # because this a low level pointer assignment.
  # This is just a helpful function for this purpose.
  # TODO: deprecate instance level setParent method. ~U
  setParent = (child, parent) ->
    child.parent = parent


  # TODO: add selector support. Probably a querySelector for vdom? ~U
  # TODO: viewAppended event emition needs to move somewhere else.
  addSubview: (view, selector, shouldPrepend) ->

    throw new Error 'no subview was specified'  unless view?
    throw new Error 'subviews required to have buildTree method'  unless typeof view.buildTree is 'function'

    if shouldPrepend
    then @subViews.unshift view
    else @subViews.push    view

    setParent view, this
    view.parentIsInDom = @parentIsInDom


    view.emit 'viewAppended'
    return view  # TODO: it should be `return this`


  # getAttribute: ->

  # setAttribute: ->

  # setAttributes: ->

  # getWidth: ->

  # getElement: -> @__rootNode__

  # setClass: ->

  # append: ->

  # appendTo: ->

  # appendToSelector: ->

  # # TODO: these needs to be opt-in (mixin)
  # setLazyLoader: -> super
  # setTooltip: -> super
  # setDraggable: -> super
  # observeMutations: -> super
  # putOverlay: -> super



  # TODO: change this method's
  # name to explain that it's binding
  # events from options.
  addEventHandlers: ->


  setParent: (parent) ->
    warn 'RView::setParent is deprecated.'
    setParent this, parent


  removeSubview: (view) ->

    return  if (index = @subViews.indexOf view) is -1

    @subViews.splice index, 1

    return view


  orphanize: -> @parent?.removeSubview this


  destroy: ->

    # instance destroys own subviews
    @destroySubViews()  if @getSubViews().length > 0

    # instance drops itself from its parent's subviews array
    @orphanize()

    # call super to remove instance subscriptions
    # and delete instance from KD.instances registry
    super


  destroySubviews: ->
    view.destroy?() for view in @getSubViews().slice()
    return

  destroySubViews: ->
    warn "RView::destroySubViews is deprecated, use RView::destroySubviews instead"
    @destroySubviews arguments


  setPartial: (partial, selector) ->
    warn "RView::setPartial is deprecated, use RView::addPartial instead"
    @addPartial partial


  addPartial: (partial) -> @addSubview new KDTextObject partial


  updatePartial: (partial) ->

    @destroySubviews()  if @getSubViews().length > 0
    @addSubview new KDTextObject partial


  appendToDomBody: ->

    @parentIsInDom = yes

    root = @getRootNode()

    throw new Error 'there is no root node, call `createElement` before trying to add dom'  unless root

    document.body.appendChild root


  #######################################
  ############# OWN METHODS #############
  #######################################


  # create the dom representation of
  # the virtual dom.
  createElement: ->

    @__tree__     = @buildTree()
    @__rootNode__ = createElement @__tree__

    return @__rootNode__


  render: ->

    tree    = @buildTree()
    patches = diff  @getTree(),     tree
    node    = patch @getRootNode(), patches

    @setTree tree
    @setRootNode node


  # TODO: this method and RView::mapEvents
  # should be moved to a place where our virtual
  # dom extraction happens. It's silly to make something this
  # low level in this code feels bad. ~U
  mapOptions: ->
    options = @getOptions()
    map =
      cssClass : 'className'
      domId    : 'id'

    transformed = {}

    for original, mapped of map
      if options[original]?
      then transformed[mapped] = options[original]

    # we need to carry the attributes if they exist
    transformed = _.extend transformed, options.attributes

    transformed = @mapEvents transformed

    return transformed


  mapEvents: (obj) ->

    for eventName in @eventsToBeBound
      obj["ev-#{eventName}"] = (ev) =>
        willPropagateToDOM = @handleEvent ev
        ev.stopPropagation()  unless willPropagateToDOM
        return yes

    return obj


  # build virtual dom tree of the view, with all of its
  # subviews' virtual dom tree.
  buildTree: ->

    tagName = @getTagName()

    options = @mapOptions()
    args = [tagName, options]

    args.push children = @subViews.map (child) -> child.buildTree()

    result = h.apply null, args

    return result


