
module.exports = class SideNavigationTreeView extends JTreeViewController

  constructor: (options = {}, data) ->

    options.addListsCollapsed = no

    super options, data

  collapse : ->


