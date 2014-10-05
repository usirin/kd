{ assert } = require 'chai'
sinon      = require 'sinon'

KDObject   = require '../../src/core/object'

describe 'KDObject', ->

  describe 'setOptions', ->

    it 'sets options', ->

      obj = new KDObject

      obj.setOptions { foo: 'bar', baz: 'qux' }

      assert.equal obj.options['foo'], 'bar'
      assert.equal obj.options['baz'], 'qux'


  describe 'getOptions', ->

    it 'returns the options', ->

      obj = new KDObject { foo: 'bar' }

      result = obj.getOptions()

      assert.deepEqual result, { foo: 'bar' }


  describe 'setOption', ->

    it 'sets a single option', ->

      obj = new KDObject

      assert.deepEqual obj.options, {}

      obj.setOption 'foo', 'bar'

      assert.deepEqual obj.getOptions(), { foo: 'bar' }


  describe 'getOption', ->

    it 'returns the value of given key on options', ->

      obj = new KDObject

      obj.setOption 'foo', 'bar'

      assert.equal (obj.getOption 'foo'), 'bar'

    context 'when there is no property with that key', ->

      it 'returns null', ->

        obj = new KDObject

        assert.isNull obj.getOption 'foo'


  describe 'unsetOption', ->

    it 'unsets the option', ->

      obj = new KDObject { foo: 'bar' }

      assert.equal (obj.getOption 'foo'), 'bar'

      obj.unsetOption 'foo'

      assert.isNull obj.getOption 'foo'


  describe 'setData', ->

    it 'sets data', ->

      obj = new KDObject
      obj.setData { foo: 'bar' }

      assert.equal obj.data['foo'], 'bar'


  describe 'getData', ->

    it 'returns the data', ->

      obj = new KDObject

      obj.setData { foo: 'bar' }

      result = obj.getData()

      assert.equal result['foo'], 'bar'


  describe 'setDelegate', ->

    it 'sets delegate', ->

      delegate = new KDObject
      obj      = new KDObject

      obj.setDelegate delegate

      assert.equal obj.delegate, delegate


  describe 'getDelegate', ->

    it 'returns the delegate', ->

      delegate = new KDObject
      obj      = new KDObject

      obj.setDelegate delegate

      result = obj.getDelegate()

      assert.equal result, delegate


  describe 'constructor', ->

    it 'should instantiate without error', ->

      obj = new KDObject
      assert.ok obj

    it 'sets the id from options', ->

      obj = new KDObject { id: 777 }
      assert.equal obj.id, 777

    it 'sets options passed to instance level options', ->

      opts = { foo: 'bar', baz: 'qux' }

      obj = new KDObject opts

      assert.equal obj.options['foo'], 'bar'
      assert.equal obj.options['baz'], 'qux'

    context 'when data is provided', ->

      it 'sets data', ->

        data = { foo: 'bar', baz: 'qux' }

        obj = new KDObject {}, data

        assert.equal obj.data['foo'], 'bar'
        assert.equal obj.data['baz'], 'qux'

    context 'when data is not provided', ->

      it 'does not set data', ->

        obj = new KDObject {}

        assert.isUndefined obj.data

    it 'sets delegate', ->

      delegate = new KDObject

      obj = new KDObject { delegate }

      assert.equal obj.delegate, delegate

      assert.isUndefined (new KDObject).delegate

    it 'registers itself to object registry', ->

      obj = new KDObject { id: 'foo-bar' }

      assert.equal KD.instances['foo-bar'], obj

    it 'registers itself for testing when testPath is provided from options', ->

      obj = new KDObject {testPath: 'foo-bar'}

      assert.equal KD.instancesToBeTested['foo-bar'], obj


  describe 'bound', ->

    context 'when given method does not exist', ->

      it 'throws', ->

        obj = new KDObject
        assert.throws (-> obj.bound 'foo'), 'bound: unknown method! foo'


    it 'saves the method with __bound__ prefix', ->

      obj = new KDObject

      obj.bound 'getData'

      assert.property obj, '__bound__getData'


  describe 'lazyBound', ->

    it 'returns a function that wraps given method', ->

      obj = new KDObject

      fn = obj.lazyBound 'setData', { foo: 'bar' }

      assert.isUndefined obj.data

      fn()

      assert.equal obj.getData().foo, 'bar'


  describe 'forwardEvent', ->

    it 'emits given named event from target', ->

      foo = new KDObject
      bar = new KDObject

      bar.on 'foo:event', -> bar.dummyProperty = yes

      foo.emit 'foo:evet'

      assert.isUndefined bar.dummyProperty

      bar.forwardEvent foo, 'foo:event'

      foo.emit 'foo:event'

      assert.ok bar.dummyProperty


  describe 'forwardEvents', ->

    it 'forwards multiple events', ->

      foo = new KDObject
      bar = new KDObject

      bar.on 'foo:change', -> bar['foo:change'] = yes
      bar.on 'foo:submit', -> bar['foo:submit'] = yes

      foo.emit 'foo:change'
      foo.emit 'foo:submit'

      assert.isUndefined bar['foo:change']
      assert.isUndefined bar['foo:submit']

      bar.forwardEvents foo, ['foo:change', 'foo:submit']

      foo.emit 'foo:change'
      foo.emit 'foo:submit'

      assert.ok bar['foo:change']
      assert.ok bar['foo:submit']


  # TODO: enhance this method's tests.
  describe 'ready', ->

    it "calls the passed listener after it's ready", ->

      obj = new KDObject

      foo = null
      obj.ready -> foo = yes

      assert.isNull foo

      obj.emit 'ready'

      assert.equal foo, yes

  describe 'changeId', ->

    it 'deletes the instance with given id first', ->

      obj = new KDObject


