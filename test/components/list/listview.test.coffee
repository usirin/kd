{assert, expect} = require 'chai'
sinon            = require 'sinon'
KDListView       = require '../../../src/components/list/listview.coffee'
KDListItemView   = require '../../../src/components/list/listitemview.coffee'

describe.only 'KDListView', ->

  describe 'constructor', ->

    it 'should instantiate without error', ->
      listView = new KDListView
      assert.isDefined listView


    context 'the defaults', ->

      it 'defaults type to `default`', ->
        listView = new KDListView
        { type } = listView.getOptions()

        assert.equal type, 'default'

      it 'defaults lastToFirst to no', ->
        listView = new KDListView
        { lastToFirst } = listView.getOptions()

        assert.equal lastToFirst, no

      it 'defaults boxed to no', ->
        listView = new KDListView
        { boxed } = listView.getOptions()

        assert.equal boxed, no

      it 'defaults boxed to no', ->
        listView = new KDListView
        { boxed } = listView.getOptions()

        assert.equal boxed, no

      it 'defaults itemsPerBox to 10', ->
        listView = new KDListView
        { itemsPerBox } = listView.getOptions()

        assert.equal itemsPerBox, 10

      it 'defaults itemClass to KDListItemView', ->
        listView = new KDListView
        { itemClass } = listView.getOptions()

        assert.equal itemClass, KDListItemView

      context 'when there is css class', ->

        it 'adds css class with some default classes', ->
          listView = new KDListView { cssClass: 'awesome-list' }
          { cssClass } = listView.getOptions()

          expected = "kdlistview kdlistview-default awesome-list"

          assert.equal cssClass, expected



      context 'when there is not css class', ->

        it 'adds only default css classes', ->
          listView = new KDListView
          { cssClass } = listView.getOptions()

          expected = "kdlistview kdlistview-default"

          assert.equal cssClass, expected


      it 'has empty items', ->
        listView = new KDListView
        assert.deepEqual listView.items, []

      it 'has empty boxes', ->
        listView = new KDListView
        assert.deepEqual listView.boxes, []


  describe 'keyDown', ->

    it 'emits event', ->
      listView = new KDListView
      sinon.spy listView, 'emit'

      listView.keyDown()
      assert.ok listView.emit.calledWith 'KeyDownOnList'


  describe 'addItemView', ->

    context 'when there is not index', ->

      context 'when it is lastToFirst', ->

        it 'prepends to items array', ->
          listView = new KDListView { lastToFirst: yes }

          listView.addItemView itemView = new KDListItemView {}, 1
          assert.equal listView.items[0].data, 1

          listView.addItemView itemView = new KDListItemView {}, 2
          assert.equal listView.items[0].data, 2
          assert.equal listView.items[1].data, 1


      context 'when it is not lastToFirst', ->

        it 'appends to items array', ->
          listView = new KDListView { lastToFirst: no }

          listView.addItemView itemView = new KDListItemView {}, 1
          assert.equal listView.items[0].data, 1

          listView.addItemView itemView = new KDListItemView {}, 2
          assert.equal listView.items[0].data, 1
          assert.equal listView.items[1].data, 2


    context 'when there is index', ->
      # when there is an index
      # lastToFirst options is not relevant.
      # lastToFirst is always about appending
      # or prepending.

      it 'inserts item to given index', ->
        listView = new KDListView
        [0..10].forEach (index) ->
          listView.addItemView new KDListItemView {}, index

        listItem = new KDListItemView {}, 'awesome'
        listView.addItemView listItem, index = 3

        assert.equal listView.items[3].data, 'awesome'

    it 'emits an event', ->
      listView = new KDListView
      sinon.spy listView, 'emit'

      listView.addItemView itemView = new KDListItemView {}, 'awesome'

      assert listView.emit.calledWith 'ItemWasAdded', itemView, 0

    it 'calls insertItemAtIndex', ->
      listView = new KDListView
      sinon.spy listView, 'insertItemAtIndex'

      listView.addItemView itemView = new KDListItemView {}, 'awesome'

      assert listView.insertItemAtIndex.calledWith itemView, 0

    it 'returns itemView', ->
      listView = new KDListView
      itemView = new KDListItemView {}, 'awesome'

      result = listView.addItemView itemView

      assert.equal result, itemView

  describe 'addItem', ->

    it 'transfers itemOptions to item as options', ->
      listView = new KDListView itemOptions: { dummyOption: 'awesome' }
      result = listView.addItem 'data'
      { dummyOption } = result.getOptions()

      assert.equal dummyOption, 'awesome'

    it 'defaults items delegate to list itself', ->
      listView = new KDListView
      result   = listView.addItem 'data'
      { delegate } = result

      assert.equal delegate, listView

    it "defaults item's childClass to listView's itemChildClass", ->
      class ChildClass extends KDListItemView # can be any type of KDView
      listView = new KDListView { itemChildClass: ChildClass }
      result = listView.addItem 'data'

      { childClass } = result.getOptions()

      assert.equal childClass, ChildClass

    it "defaults to item's childOptions to listView's itemChildOptions", ->
      class ChildClass extends KDListItemView # can be any type of KDView

      listView = new KDListView
        itemChildClass   : ChildClass
        itemChildOptions :
          dummy          : 'awesome'

      result    = listView.addItem 'data'
      { dummy } = result.getOptions().childOptions

      assert.equal dummy, 'awesome'

    it "creates a KDListItemView by default", ->
      listView = new KDListView
      result = listView.addItem 'data'

      assert.instanceOf result, KDListItemView

    it "creates the itemInstance and adds it to items array", ->
      listView = new KDListView
      result = listView.addItem 'data'

      assert.equal listView.items[0].data, 'data'


    context 'when index exists but not a number', ->

      it 'uses index as itemOptions', ->
        listView = new KDListView
        result = listView.addItem 'awesome', { dummyOption: 'so-awesome' }

        { dummyOption } = result.getOptions()

        assert.equal dummyOption, 'so-awesome'


  describe 'removeItemView', ->

    listView = new KDListView
    beforeEach -> [0...5].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    it 'emits an event', ->
      sinon.spy listView, 'emit'
      item = listView.items[2]
      listView.removeItemView item, 2

      assert.ok listView.emit.calledWith 'ItemWasRemoved', item, 2
      listView.emit.restore()

    it 'destroys the item view', ->
      item = listView.items[2]
      listView.removeItemView item, 2

      assert.equal item.isDestroyed, yes

    it 'removes item from items list', ->
      item = listView.items[2]
      listView.removeItemView item, 2

      index = listView.items.indexOf item

      assert.equal index, -1

    it 'returns true for success signal', ->
      item = listView.items[2]
      result = listView.removeItemView item, 2

      assert.equal result, yes

  describe 'removeItemByIndex', ->

    listView = new KDListView
    beforeEach -> [0...5].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    it 'returns no if index is not given', ->
      result = listView.removeItemByIndex()
      assert.equal result, no

    it 'returns no if index is out of bounds', ->
      result = listView.removeItemByIndex 7
      assert.equal result, no

    it 'removes item view', ->
      result = listView.removeItemByIndex 2
      assert.equal result, yes


  describe 'removeItemByInstance', ->

    listView = new KDListView
    beforeEach -> [0...5].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    it 'returns undefined if item instance is not in items array', ->
      dummyInstance = new KDListItemView
      result = listView.removeItemByInstance dummyInstance

      assert.isUndefined result

    it 'removes item', ->
      instance = listView.items[2]
      result = listView.removeItemByInstance instance

      assert.equal result, yes


  describe 'removeItemByData', ->

    listView = new KDListView
    beforeEach -> [1...6].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    context 'when data path is not specified', ->

      it "retuns undefined and doesn't remove item", ->
        result = listView.removeItemByData {} # no 'dataPath' property
        assert.isUndefined result

    context 'when there is not a match in items list', ->

      it 'returns undefined', ->
        listView.setOption 'dataPath', 'result'
        result = listView.removeItemByData { result: 111 }

        assert.isUndefined result

     context 'when there is a match in items list', ->

       it 'removes every match', ->

         listView.setOption 'dataPath', 'result'
         [1, 2].forEach (i) -> listView.items[i].data = { result: 100 }

         result = listView.removeItemByData { result: 100 }

         assert.equal result, yes
         assert.equal listView.items.length, 3


  describe 'removeItem', ->

    context 'when there is index', ->

      it 'returns false if there is no item with that index', ->
        listView = new KDListView
        result = listView.removeItem null, null, 1

        assert.equal result, no

      it 'removes item at that index', ->
        listView = new KDListView
        [0...5].forEach (index) -> listView.addItem data = index

        item = listView.items[2]
        result = listView.removeItem null, null, 2

        assert.equal result, yes
        assert.equal listView.items.length, 4

    context 'when there is itemInstance', ->

      it 'finds index and removes that itemInstance', ->
        listView = new KDListView
        [0...5].forEach (index) -> listView.addItem data = index

        item = listView.items[2]

        result = listView.removeItem item

        assert.equal result, yes
        assert.equal listView.items.length, 4

    context 'when there is itemData', ->

      it.only 'finds item by itemData and removes it', ->
        listView = new KDListView { dataPath: 'result' }
        [0...5].forEach (index) ->
          listView.addItem data = { result: index }

        item = listView.items[2]

        result = listView.removeItem null, { result: 2 }

        assert.equal result, yes
        assert.equal listView.items.length, 4


  describe 'empty', ->

    it 'empties the list', ->
      listView = new KDListView
      [0, 1, 2].forEach (data) -> listView.addItem data

      items = listView.items

      listView.empty()
      assert.equal listView.items.length, 0

      items.forEach (item) -> assert.equal item.isDestroyed, yes

  describe 'destroy', ->

    it 'empties the list and destroys itself', ->
      listView = new KDListView
      [0, 1, 2].forEach (data) -> listView.addItem data

      items = listView.items

      listView.destroy()

      items.forEach (item) -> assert.equal item.isDestroyed, yes
      assert.equal listView.isDestroyed, yes


  describe '@getIndex', ->

    listView = new KDListView
    beforeEach -> [1...6].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    it 'returns itself if it is not special', ->
      result = listView.getIndex 2
      assert.equal result, 2


    context 'when index is equal to and below zero', ->

      context 'when boxed and lastToFirst', ->

        it 'is undefined', ->
          listView.setOption 'boxed', yes
          listView.setOption 'lastToFirst', yes

          result = listView.getIndex 0
          assert.isUndefined result

          result = listView.getIndex -2
          assert.isUndefined result

      context 'when opposite of the above', ->

        it 'is 0', ->
          result = listView.getIndex 0
          assert.equal result, 0

          result = listView.getIndex -2
          assert.equal result, 0

    context 'when index is equal to or greater than length', ->

      context 'when it is boxed and not lastToFirst', ->

        it 'is undefined', ->
          listView.setOption 'boxed', yes
          listView.setOption 'lastToFirst', no

          result = listView.getIndex 4
          assert.isUndefined result

          result = listView.getIndex 1000
          assert.isUndefined result

      context 'when opposite of the above', ->

        it 'is length - 1', ->
          listView.setOption 'boxed', no

          result = listView.getIndex 4
          assert.equal result, 4

          result = listView.getIndex 1000
          assert.equal result, 4


  describe 'insertView', ->

    listView = new KDListView
    beforeEach -> [1...6].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    it 'inserts view at given index', ->
      item = new KDListItemView {}, { dummy: 'awesome' }
      listView.insertView item, 2

      expected = listView.items[3].getElement().parentNode.childNodes[3]
      assert.equal expected, item.getElement()


    context 'when parent is in dom', ->

      it 'emits event', ->
        item = new KDListItemView {}, { dummy: 'awesome' }
        sinon.spy item, 'emit'

        listView.parentIsInDom = yes
        listView.insertView item, 2

        assert.ok item.emit.calledWith 'viewAppended'

  describe 'appendView', ->

    listView = new KDListView
    beforeEach -> [1...6].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    it 'adds view to the bottom', ->
      item = new KDListItemView
      listView.appendView item

      assert.equal listView.subViews[5], item


  describe 'putView', ->

    listView = new KDListView
    beforeEach -> [1...6].forEach (index) -> listView.addItem data = index
    afterEach -> listView = new KDListView

    context 'when it needs to be last item', ->

      it 'appends view', ->
        item = new KDListItemView
        sinon.spy listView, 'appendView'

        listView.putView item, 8

        assert.ok listView.appendView.calledWith item

    context 'when it does not need to be last item', ->

      it 'insertsView', ->
        item = new KDListItemView
        sinon.spy listView, 'insertView'

        listView.putView item, 2

        assert.ok listView.insertView.calledWith item, 2

  describe 'createBox', ->

    it 'adds a box to boxes array', ->
      listView = new KDListView
      assert.equal listView.boxes.length, 0

      listView.createBox()


  describe 'packageItem', ->




  describe 'insertItemAtIndex', ->



