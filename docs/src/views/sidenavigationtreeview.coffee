
module.exports = class SideNavigationTreeView extends JTreeViewController

  constructor: (options = {}, data) ->

    options.addListsCollapsed = no

    super options, data

    @adaptData()

  collapse : ->

  adaptData : ->

    nodes             = []
    mdRegExp          = /\d+\-([a-z\-]+)\.(md|markown)/
    {toTitleCase}     = KD.utils

    for node, subNodes of @getData()

      id    = node.split('.')[0]
      title = toTitleCase node.split('.')[1].replace('-', ' ')

      nodes.push {
        title
        id
      }

      for subNode in subNodes

        if mdRegExp.test subNode

          parentId = id
          title    = toTitleCase subNode.split(mdRegExp)[1].replace('-', ' ')

          nodes.push {
            title
            parentId
          }

    @setData nodes




