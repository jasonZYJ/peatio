helpers =
  format_trade: (ask_or_bid) ->
    gon.i18n[ask_or_bid]

  format_time: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("HH:mm")}#{m.format(":ss")}"

  format_fulltime: (timestamp) ->
    m = moment.unix(timestamp)
    "#{m.format("YY-MM-DD HH:mm")}#{m.format(":ss")}"

  format_time_iso: (timestamp) ->
    moment.unix(timestamp).toISOString()

  format_mask_number: (number, length = 7) ->
    fractional_len = length - 2
    fractional_part = Array(fractional_len).join '0'
    numeral(number).format("0.#{fractional_part}").substr(0, length).replace(/\..*/, "<g>$&</g>")

  format_mask_fixed_number: (number, length = 4) ->
    fractional_part = Array(length).join '0'
    numeral(number).format("0.#{fractional_part}").replace(/\..*/, "<g>$&</g>")

  format_fix_ask: (volume) ->
    fixAsk volume

  format_fix_bid: (price) ->
    fixAsk price

  format_volume: (origin, volume) ->
    if (origin is volume) or (BigNumber(volume).isZero())
      fixAsk origin
    else
      "#{fixAsk volume} / #{fixAsk origin}"

partials =
  partial_market_live_trade: JST['partial_market_live_trade']

for name, fun of helpers
  Handlebars.registerHelper name, fun

for name, template of partials
  Handlebars.registerPartial name, template
