{ assert, expect } = require 'chai'
sinon              = require 'sinon'
RView              = require '../../src/core/rview'
KDView             = require '../../src/core/view'
KDTextObject       = require '../../src/core/textobject'
VirtualNode        = require 'vtree/vnode'
createEvent        = require 'synthetic-dom-events'
document           = require 'global/document'
createElement      = require 'virtual-dom/create-element'

describe.only 'RView', ->

  describe 'constructor', ->

    it 'has new defaults', ->

      r = new RView

      assert.isDefined r.__tree__,     '__tree__ is defined'
      assert.isDefined r.__rootNode__, '__rootNode__ is defined'

  describe 'setDomId', ->

    it 'sets domId', ->

      r = new RView
      assert.isNull r.getOptions().domId

      r.setDomId 'foo-bar'
      assert.equal r.getOptions().domId, 'foo-bar'


  describe 'setDataId', ->

    it 'sets data id', ->

      r = new RView
      assert.isNull


  describe 'bindEvents', ->

    defaultEvents = [
      'mousedown', 'mouseup', 'click', 'dblclick'
    ]

    it 'has default events', ->
      r = new RView
      assert.deepEqual r.eventsToBeBound, defaultEvents, 'it has default events'

    it "adds view's bind option to events to be bound", ->

      r = new RView bind: 'keydown keyup'

      assert.include r.eventsToBeBound, 'keydown' , 'keydown is a bound event'
      assert.include r.eventsToBeBound, 'keyup'   , 'keyup is a bound event'


  describe 'addSubview', ->

    it 'throws an error when there is no subview', ->

      r = new RView
      assert.throws (-> r.addSubview()), 'no subview was specified'

    it 'adds given view to subviews collection', ->

      r = new RView
      assert.equal r.subViews.length, 0

      r.addSubview new RView
      assert.equal r.subViews.length, 1

    it 'should throw if subview does not have a buildTree method', ->

      r = new RView

      assert.throws (-> r.addSubview new KDView), /subviews required to have buildTree method/
      assert.doesNotThrow (-> r.addSubview new RView)
      assert.doesNotThrow (-> r.addSubview new KDTextObject)

    it 'should append by default', ->

      r = new RView
      r.addSubview new RView
      r.addSubview new KDTextObject

      assert.ok r.subViews[0] instanceof RView
      assert.ok r.subViews[1] instanceof KDTextObject

    it 'should prepend to subviews when needed', ->

      r = new RView

      r.addSubview new RView
      r.addSubview (new KDTextObject), null, yes

      assert.ok r.subViews[0] instanceof KDTextObject

    it 'emits viewAppended', ->

      r = new RView
      subview = new RView

      sinon.spy subview, 'emit'

      r.addSubview subview

      assert.ok subview.emit.calledWith 'viewAppended'

    it 'sets itself as subviews\' parent', ->

      r = new RView
      s = new RView

      r.addSubview s

      assert.equal s.parent, r


  describe 'removeSubview', ->

    it 'removes given subview', ->

      r = new RView

      r.addSubview child1 = new RView
      r.addSubview child2 = new RView
      r.addSubview child3 = new RView

      r.removeSubview child2

      assert.equal r.subViews.length, 2
      assert.equal (r.subViews.indexOf child3), 1


    it 'returns when view is not in subviews', ->

      r = new RView
      r.addSubview new RView

      foo = new RView
      result = r.removeSubview foo

      assert.isUndefined result


  describe 'orphanize', ->

    context 'when there is a parent', ->

      it 'removes itself from its parent view', ->

        r = new RView
        s = new RView

        r.addSubview s

        assert.equal r.subViews.length, 1
        s.orphanize()

        assert.equal r.subViews.length, 0


    context 'when there is not a parent', ->

      it 'does nothing', ->

        r = new RView

        assert.isNull r.parent
        result = r.orphanize()

        assert.isUndefined result


  describe 'destroySubviews/destroy', ->

    it 'destroys subviews', ->

      r = new RView

      r.addSubview new RView
      r.addSubview new RView
      r.addSubview new KDTextObject

      assert.equal r.subViews.length, 3

      r.destroySubviews()

      assert.equal r.subViews.length, 0

    it 'orphanizes itself', ->

      r = new RView
      r.addSubview s = new RView

      assert.equal r.subViews.length, 1

      s.destroy()

      assert.equal r.subViews.length, 0


  describe 'addPartial', ->

    it 'adds a text object to subviews', ->


      r = new RView

      r.addPartial 'foo'

      assert.instanceOf r.subViews[0], KDTextObject
      assert.equal r.subViews[0].text, 'foo'

      r.addSubview new RView
      r.addPartial 'bar'

      assert.instanceOf r.subViews[2], KDTextObject
      assert.equal r.subViews[2].text, 'bar'


  describe 'updatePartial', ->

    it 'destroys all subviews', ->

      r = new RView

      r.addSubview new RView
      r.addSubview new RView

      assert.equal r.subViews.length, 2

      r.updatePartial 'foo bar'

      assert.equal r.subViews.length, 1


  describe 'createElement', ->

    # FIXME: this test needs to be thought again.
    it 'creates the dom element of view', ->

      r = new RView cssClass: 'foo-rview', partial: 'foo bar'

      element = r.createElement()

      document.body.appendChild element
      result = document.querySelector '.foo-rview'

      assert.equal result.innerHTML, 'foo bar'


  describe 'mapEvents', ->
    # TODO: Please move this method to its own class.

    it 'returns virtual dom compatible version of internal events', ->

      r = new RView bind: 'keydown keyup'

      mappedEvents = r.mapEvents {}

      assert.isDefined mappedEvents['ev-keydown']
      assert.isDefined mappedEvents['ev-keyup']
      assert.isDefined mappedEvents['ev-click']


  describe 'mapOptions', ->
    # TODO: Please move this method to its own class.

    it 'maps view options to work correctly with virtual dom.', ->

      r = new RView { cssClass: 'foo', domId: 'bar' }

      result = r.mapOptions()

      assert.equal result.className, 'foo'
      assert.equal result.id, 'bar'

    it 'maps attributes to new transformed options', ->

      r = new RView { cssClass: 'foo', attributes: { href: '/Bar', style: 'padding: 10px' } }

      result = r.mapOptions()

      assert.equal result.className, 'foo'
      assert.equal result.href, '/Bar'
      assert.equal result.style, 'padding: 10px'

    it "doesn't map an option if it doesn't exist", ->

      r = new RView { cssClass: 'foo' }

      result = r.mapOptions()

      assert.ok result.hasOwnProperty 'className'
      assert.notOk result.hasOwnProperty 'id'


    it 'maps events', ->

      r = new RView { domId: 'foo', mouseover: ((ev) -> ev), bind: 'mouseover' }

      result = r.mapOptions()

      assert.isDefined result['ev-mouseover']
      assert.isDefined result['ev-click'] # default event


  describe 'buildTree', ->

    it 'builds its tree when there is no subview', ->

      r = new RView tagName: 'span'
      tree = r.buildTree()

      assert.instanceOf tree, VirtualNode
      assert.equal tree.tagName, 'span'

    it "builds its subviews' trees too", ->

      r = new RView
      s = new RView {partial: 'foo'}

      r.addSubview s
      childTree = s.buildTree()

      tree = r.buildTree()

      # FIXME: probably we need our own abstraction around
      # virtual node object so that we don't have to depend on
      # VirtualNode itself at all. But for now, this is
      # the only way I can find to test this behavior. ~U
      assert.equal tree.children[0].children[0].text, childTree.children[0].text

    it 'hooks up events', ->

      arr = []
      fn = (ev) -> arr.push 'foo'

      r = new RView {click: fn}

      clickEvent = createEvent 'click'

      tree = r.buildTree()

      element = createElement tree
      document.body.appendChild element

      element.dispatchEvent clickEvent
      assert.equal arr.length, 1

      element.dispatchEvent clickEvent
      assert.equal arr.length, 2


