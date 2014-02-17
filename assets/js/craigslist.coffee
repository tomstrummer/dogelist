define [
  "jquery",
  "underscore",
  "backbone",
  "elbow",
  'form' ],
  ($, _, Backbone, Elbow) ->

    Post = Backbone.Model.extend(
        defaults:
          link : null
          title : ""
          timestamp : new Date()
          price : 0
          description : ''

        urlRoot: 'craigslist/item'
    )

    Search = Backbone.Collection.extend(
        model: Post

        initialize: (opts) ->
          console.log "Search opts", opts
          @params = opts.params

        # search parameters, filled during initialize
        params:
          query: null
          category: null
          region: null

        urlRoot: '/search'
        url: () ->
          "#{@urlRoot}/#{encodeURIComponent @params.region}\
           /#{encodeURIComponent @params.category}\
           ?q=#{encodeURIComponent @params.query}"
    )

    SearchFormView = Elbow.ItemView.extend(
      template: '#searchTmpl'

      ui:
        searchForm: '#searchForm'

      events:
        'submit @ui.searchForm': 'doSearch'
        'click #searchBtn': 'doSearch'

      doSearch: (e) ->
        e.preventDefault()
        params = @ui.searchForm.form2obj()
        console.log "Form params",e, params

        new Search(
          params: params
        ).fetch(
          success: (collection, response, options) =>
            console.debug "Search success", collection
            @trigger "search:results", collection

          error: (collection, response, options) =>
            console.debug "Search error", collection
            @trigger "search:error", collection
        )
    )

    ResultItemView = Elbow.ItemView.extend(
      template: "#searchResultItemTmpl"
      initialize: () ->
        console.log "Created search result item"

      onRender: () ->
        console.log "Render item", @
    )

    NoResultsView = Elbow.ItemView.extend(
      template: "#noSearchResultsTmpl"
    )

    SearchResultsView = Elbow.CollectionView.extend(
      template: "#searchResultsTmpl"
#      appendSelector: '.searchResults'
      itemView: ResultItemView
      emptyView: NoResultsView

      onRender: () ->
        console.log "render collection", @
    )

    return {
      Post : Post
      Search : Search
      SearchFormView : SearchFormView
      SearchResultsView : SearchResultsView
    }
