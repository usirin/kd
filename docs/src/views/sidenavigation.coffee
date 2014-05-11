SideNavigationTreeView = require './sidenavigationtreeview'

module.exports = class SideNavigation extends KDView

  constructor : (options = {}) ->

    options.tagName  = 'aside'
    options.cssClass = 'main-sidebar'

    super options

    @menu = new SideNavigationTreeView
      cssClass            : 'side-menu'

    ,
      KD.sitemap

  viewAppended : ->
    @addSubView @menu.getView()
