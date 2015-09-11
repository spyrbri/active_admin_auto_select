class AutoSelect
  constructor: (@options = {}) ->
    @$input = $(@options['input'])
    @width = @options['width'] || 240
    @placeholder = @options['placeholder']

  init: ->
    scope = @$input.attr('data-scope')
    url = @$input.attr('data-url')
    @$input.select2
      placeholder: @placeholder,
      allowClear: true,
      minimumInputLength: 1,
      width: @width,
      ajax:
        url: url,
        quietMillis: 300,
        data: (term, page) ->
          q: term,
          page_limit: 10,
          page: page,
          scope: scope
        results: (data, page) ->
          more = data.length >= 10
          {results: data, more: more}
      formatResult: (item, container, query, escapeFn) =>
        markup = []
        window.Select2.util.markMatch(@detailText(item), query.term, markup, escapeFn)
        text = markup.join('')
      formatSelection: (item, container, escapeFn) =>
        @detailText(item)
      initSelection: (e, callback) =>
        id = $(e).val()
        if id isnt ""
          $.getJSON( url, id: id).done (data) =>
            callback data
            @$input.trigger("autocomplete:ajax:success", data)

    @$input.change 'select2-selecting', () ->
      $(@).closest('.filter_form').submit()

  detailText: (item) ->
    _.reject(_.uniq(_.toArray(item)), (el) ->
      el == ''
    ).join(' - ')
