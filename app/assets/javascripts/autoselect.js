var AutoSelect;

AutoSelect = (function() {
  function AutoSelect(options) {
    this.options = options != null ? options : {};
    this.$input = $(this.options['input']);
    this.width = this.options['width'] || 240;
    this.placeholder = this.options['placeholder'];
    this.multiple = this.options['multiple'];
  }

  AutoSelect.prototype.init = function() {
    var scope, url;
    scope = this.$input.attr('data-scope');
    url = this.$input.attr('data-url');
    this.$input.select2({
      placeholder: this.placeholder,
      allowClear: true,
      minimumInputLength: 1,
      width: this.width,
      multiple: this.multiple,
      ajax: {
        url: url,
        delay: 300,
        data: function(params) {
          return {
            q: params.term,
            page_limit: 10,
            page: params.page || 1,
            scope: scope,
          };
        },
        processResults: function(data, params) {
          return {
            results: data,
            pagination: {
              more: data.length >= 10,
            },
          };
        },
      },
    });
    return this.$input.change('select2-selecting', function() {
      return $(this).closest('.filter_form').submit();
    });
  };

  return AutoSelect;

})();
