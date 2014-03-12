window.MarketLiveTradesUI = flight.component ->
  @defaultAttrs
    templateName: 'market_live_trades'
    partialName: 'partial_market_live_trade'

  @format_data = (data) ->
    for d in data
      d.total = d.amount * d.price
    data

  @render = (data) ->
    template = JST[@attr.templateName]
    @$node.html(template(trades: @format_data(data))).timeago()

  @prepend = (event, data) ->
    for trade in @format_data(data.trades)
      str = JST[@attr.partialName](trade)
      $(str).prependTo(@$node.find('tbody')).timeago()

  @after 'initialize', ->
    @render(gon.trades)
    @on document, 'pusher::trades', @prepend
