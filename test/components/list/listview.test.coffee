{assert, expect}     = require 'chai'
sinon                = require 'sinon'
KDListView           = require '../../../src/components/list/listview.coffee'
KDListItemView       = require '../../../src/components/list/listitemview.coffee'

describe 'KDListView', ->

  describe 'constructor', ->

    it 'should instantiate without error', ->
      listView = new KDListView
      assert.isDefined listView

    # it 'defaults type to `default`', ->
    #   listView = new KDListView { type: 'falan' }
    #   assert.equal listView.getOption 'type', 'falan'

