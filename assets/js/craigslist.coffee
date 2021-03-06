define [
  "jquery",
  "text!regions.json",
  "text!categories.json",
  "backbone",
  "elbow",
  'form',
  'select2',
  'backbone_cache'],
  ($, regions, categories, Backbone, Elbow) ->

    Post = Backbone.Model.extend(
        defaults:
          link : null
          title : ""
          timestamp : new Date()
          price : 0
          calc_price : NaN
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

      initialize: (opts) ->
        @remember = window.localStorage?
        try
          localStorage.setItem 'test','test'
          localStorage.removeItem 'test'

          @params = JSON.parse localStorage.getItem("last_search")

        catch e
          @remember = false

      serializeData: () ->
        categories: JSON.parse categories
        regions: JSON.parse regions

      ui:
        searchForm: '#searchForm'
        searchQuery: 'input[name="query"]'
        regionSelect: 'select[name="region"]'
        categorySelect: 'select[name="category"]'

      events:
        'submit @ui.searchForm': 'doSearch'
        'click #searchBtn': 'doSearch'

      onDomRefresh: ->
        if @params
          @ui.searchQuery.val @params.query
          @ui.regionSelect.val(@params?.region).select2()
          @ui.categorySelect.val(@params?.category).select2()
        else
          @ui.regionSelect.select2()
          @ui.categorySelect.select2()

      doSearch: (e) ->
        e.preventDefault()
        @params = @ui.searchForm.form2obj()
        console.log "Form params",e, @params

        if @remember
          localStorage.setItem "last_search", JSON.stringify(@params)

        new Search(
          params: @params
        ).fetch(
          prefill: true
          success: (collection, response, options) =>
            console.debug "Search success", collection
            @trigger "search:results", collection

          error: (collection, response, options) =>
            console.debug "Search error", collection, response
            @trigger "search:error", collection
        )
    )

    ResultItemView = Elbow.ItemView.extend(
      template: "#searchResultItemTmpl"
    )

    NoResultsView = Elbow.ItemView.extend(
      template: "#noSearchResultsTmpl"
    )
    FirstSearchView = Elbow.ItemView.extend(
      template: "#doSearchTmpl"
    )

    SearchResultsView = Elbow.CollectionView.extend(
      template: "#searchResultsTmpl"
      # appendSelector: '.searchResults'
      itemView: ResultItemView
      currentRate: null

      getEmptyView: () ->
        return FirstSearchView unless @collection
        return NoResultsView

      updateRate: (model) ->
        @currentRate = model.get 'rate'
        return unless @collection?
        @collection.each (item,i) =>
          item.set "calc_price", (item.get('price')* @currentRate).toFixed(4)
          #console.log "updated rate", item, @currentRate

      onRender: () ->
        console.log "render collection", @
    )

    return {
      Post : Post
      Search : Search
      SearchFormView : SearchFormView
      SearchResultsView : SearchResultsView
    }
