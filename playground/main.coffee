
view = new RView
view.appendToDomBody()

lastView = view
# mainView = new KDCustomHTMLView
#   partial: 'KD'
#   mouseover: -> console.log 'asfasfas'
#   bind: 'mouseover'

# mainView.appendToDomBody()

start = ({ results }) ->
  console.time 'RView render'
  results.forEach (result) ->
    lastView.addSubview a = new RView
      cssClass : 'falan'
      partial  : "#{result.user.email}"
      bind     : 'mouseover'
      mouseover: -> console.log 'mouseover'
      click : -> console.log 'asd'
    lastView = a
  view.render()
  console.timeEnd 'RView render'

$.ajax
  url         : "http://api.randomuser.me/?results=40"
  type        : 'GET'
  success     : (obj) ->
    obj.results = obj.results.concat obj.results for i in [0...3]
    start obj
    # startKD obj
    KD.utils.defer -> window.scrollTo 0, document.body.scrollHeight
    console.log obj.results.length


# lastView = mainView
# startKD = ({ results }) ->
#   console.time 'KDView render'
#   console.log {results}
#   for result in results
#     lastView.addSubView lastView = new KDCustomHTMLView
#       cssClass : 'falan'
#       partial  : "#{result.user.email}"
#       bind     : 'mouseover mouseout'

#   console.timeEnd 'KDView render'




# mainView = new KDView
#   partial: 'KD'
#   mouseover: -> console.log 'asfasfas'
#   bind: 'mouseover'

# mainView.appendToDomBody()

# id = 0

# lastMainView = mainView
# console.time 'KDView render'
# for i in [0...700]

#   lastMainView.addSubView a = new KDView
#     cssClass : 'falan'
#     partial : Date.now() + " #{i}"

#   lastMainView = a

# lastMainView.addSubView a = new KDView
#   partial: 'yo!'
#   click: -> console.log 'yo!'

# console.timeEnd 'KDView render'
