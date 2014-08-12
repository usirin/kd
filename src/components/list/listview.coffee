KDView         = require './../../core/view'
KDListViewBox  = require './listviewbox'
KDListItemView = require './listitemview'

module.exports = class KDListView extends KDView

  constructor: (options = {}, data) ->

    options.type        or= "default"
    options.lastToFirst  ?= no
    options.boxed        ?= no
    options.itemsPerBox  ?= 10
    options.itemClass    ?= KDListItemView

    options.cssClass      = if options.cssClass?
    then "kdlistview kdlistview-#{options.type} #{options.cssClass}"
    else "kdlistview kdlistview-#{options.type}"

    super options, data

    @items = []
    @boxes = []

    if @getOptions().boxed
      @on 'viewAppended', =>
        @parent.on 'scroll', @bound 'handleScroll'


  keyDown: (event) ->

    KD.utils.stopDOMEvent event
    @emit "KeyDownOnList", event


  addItemView: (itemInstance, index) ->

    {lastToFirst} = @getOptions()

    unless index?
      if lastToFirst
      then @items.unshift itemInstance
      else @items.push itemInstance

      index = if lastToFirst then 0 else @items.length - 1
    else

      @items.splice index, 0, itemInstance

    @emit 'ItemWasAdded', itemInstance, index
    @insertItemAtIndex itemInstance, index

    return itemInstance


  addItem: (itemData, index) ->

    {itemChildClass, itemChildOptions} = @getOptions()

    if index? and 'number' isnt typeof index
      itemOptions = index
      index       = null
    else
      {itemOptions} = @getOptions()

    itemOptions = @customizeItemOptions?(itemOptions, itemData) or \
                  itemOptions or {}

    itemOptions.delegate     or= this
    itemOptions.childClass   or= itemChildClass
    itemOptions.childOptions or= itemChildOptions

    { itemClass } = @getOptions()

    itemInstance = new itemClass itemOptions, itemData
    @addItemView itemInstance, index

    return itemInstance


  removeItemView: (itemView, index) ->
    @emit "ItemWasRemoved", itemView, index

    # remove itemView from DOM
    itemView.destroy()

    # remove item from items list
    @items.splice index, 1

    return yes


  removeItemByIndex: (index) ->
    return no  unless @items[index]

    return @removeItemView @items[index], index


  removeItemByInstance: (itemInstance) ->
    for item, index in @items
      if itemInstance.getId() is item.getId()
        return @removeItemView itemInstance, index


  removeItemByData: (itemData) ->
    { dataPath } = @getOptions()

    return  unless itemData[dataPath]

    # we need the copy of the array so that while
    # iterating over it we can remove item from
    # listView's instance ~Umut
    items = @items.slice()
    deleted = no
    items.forEach (item, index) =>
      match = item.getData() and
        (item.getData()[dataPath] is itemData[dataPath])

      deleted = yes  if match
      @removeItemView @items[index], index  if match

    return yes  if deleted


  removeItem: (itemInstance, itemData, index) ->

    return @removeItemByIndex index            if index
    return @removeItemByInstance itemInstance  if itemInstance
    return @removeItemByData itemData          if itemData


  empty: ->
    @items.forEach (item) -> item.destroy()
    @items = []


  destroy: ->
    item.destroy() for item in @items
    super


  appendItem: (itemInstance) -> @insertItemAtIndex itemInstance

  getIndex: (index) ->
    { boxed, lastToFirst } = @getOptions()
    if index <= 0
      return if boxed and lastToFirst
      then undefined
      else 0

    if index >= @items.length - 1
      return  if boxed and not lastToFirst
      then undefined
      else @items.length - 1

    return index


  insertView: (itemInstance, index) ->
    item = itemInstance.getElement()
    neighborItem = @items[index + 1].getElement()
    neighborItem.parentNode.insertBefore item, neighborItem
    itemInstance.emit 'viewAppended'  if @parentIsInDom


  appendView: (itemInstance) -> @addSubView itemInstance, null


  putView: (itemInstance, index) ->

    shouldBeLastItem = index >= @items.length - 1

    if shouldBeLastItem
    then @appendView itemInstance
    else @insertView itemInstance, index


  insertItemAtIndex: (itemInstance, index) ->

    {boxed, lastToFirst} = @getOptions()

    index = @getIndex index

    packagable = boxed and not index?

    if packagable
    then @packageItem itemInstance
    else @putView itemInstance, index

    @scrollDown()  if @doIHaveToScroll()


  packageItem: (itemInstance) ->

    {
      lastToFirst
      itemsPerBox
    } = @getOptions()

    operation = if lastToFirst then 'prepend' else 'append'

    newBox = =>
      box = @createBox()
      box.addSubView itemInstance

    if @boxes.last
      items = @boxes.last.subViews.filter (item)-> item instanceof KDListItemView
      if items.length < itemsPerBox
      then @boxes.last.addSubView itemInstance, null, lastToFirst
      else newBox()
    else newBox()


  createBox: ->

    @boxes.push box = new KDListViewBox
    @addSubView box, null, @getOptions().lastToFirst
    box.on 'HeightChanged', (height) => @updateBoxProps box, height
    box.on 'BoxIsEmptied', (id)=>

      index = null
      for b, i in @boxes when b.getId() is id
        index = i
        break
      @boxes.splice(index, 1)[0].destroy()  if index?


    return box


  updateBoxProps: (box, height) ->

    # log @boxes.indexOf(box), height

  # handle vertical and horizontal scrolls separately - SY
  handleScroll:->

    # log box.size for box in @boxes
    # log @parent.fractionOfHeightBelowFold view : @boxes.first

    # log 'scrollaki'
    # log @boxes




  getItemIndex: (targetItem) ->
    for item, index in @items
      return index if item is targetItem
    return -1


  moveItemToIndex: (item, newIndex) ->

    currentIndex = @getItemIndex item
    if currentIndex < 0
      warn "Item doesn't exists", item
      return @items

    newIndex = Math.max(0, Math.min(@items.length-1, newIndex))

    if newIndex >= @items.length-1
      targetItem = @items.last
      targetItem.$().after item.$()
    else
      diff = if newIndex > currentIndex then 1 else 0
      targetItem = @items[newIndex+diff]
      targetItem.$().before item.$()

    @items.splice(currentIndex, 1)
    @items.splice(newIndex, 0, item)

    return @items


  scrollDown: ->

    clearTimeout @_scrollDownTimeout

    @_scrollDownTimeout = KD.utils.wait 50, =>
      scrollView    = @$().closest(".kdscrollview")
      slidingView   = scrollView.find '> .kdview'
      slidingHeight = slidingView.height()

      scrollView.animate
        scrollTop : slidingHeight
      ,
        duration  : 200
        queue     : no


  doIHaveToScroll: ->

    if @getOptions().autoScroll
      scrollView = @$().closest(".kdscrollview")[0]
      if scrollView.length and scrollView.scrollHeight > scrollView.outerHeight()
      then yes
      else @isScrollAtBottom scrollView
    else no

  isScrollAtBottom: (scrollView) ->

    slidingView       = scrollView.find('> .kdview')[0]

    scrollTop         = scrollView.scrollTop
    slidingHeight     = slidingView.clientHeight
    scrollViewheight  = scrollView.clientHeight

    return slidingHeight - scrollViewheight is scrollTop

