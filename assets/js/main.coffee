define [
  "jquery",
  "backbone",
  "router",
  "exchange",
  "craigslist"
  "marionette" ],
  ($, Backbone, Router, exchange, craigslist) ->

    App= new Backbone.Marionette.Application()
    App.addRegions
      exchangeRegion: "#exchangeRegion"
      searchFormRegion: '#searchFormRegion'
      searchResultsRegion: '#searchResultsRegion'

    App.addInitializer (opts) ->

      exchangeView = new exchange.ExchangeView()
      searchForm = new craigslist.SearchFormView()

      exchangeView.on "rate:change", (newRate) ->
        console.log "New rate", newRate
      
      searchForm.on "search:results", (searchResults) ->
        console.log 'results', searchResults
        view = new craigslist.SearchResultsView(collection: searchResults)
        App.searchResultsRegion.show view

      .on "search:error", () ->
        console.log "search Error"

      App.exchangeRegion.show exchangeView
      App.searchFormRegion.show searchForm
      App.searchResultsRegion.show new craigslist.SearchResultsView()

    App.on "initialize:after", ->
      console.log "Started app", this

    
    App.router = new Router()
    Backbone.history.start()
      
    $(document).ready ->
      App.start()
      $(document).ajaxStart ->
        $("i.fa-spin").show()

      $(document).ajaxStop ->
        $("i.fa-spin").fadeOut()


    return app: App

