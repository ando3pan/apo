//autocomplete

var app = window.app = {};
app.Users = function() {
    this._input = $('#user-search-txt');
    this._initAutocomplete();
};

app.Users.prototype = {
    _initAutocomplete: function() {
        this._input
            .autocomplete({
                source: '/event/autocomplete_user_displayname.json',
                appendTo: '#user-search-results',
                select: $.proxy(this._select, this)
            })
            .autocomplete('instance')._renderItem = $.proxy(this._render, this);
    },

    _select: function(e, ui) {
        //this._input.val(ui.item.title + ' - ' + ui.item.author);
        return false;
    },

    _render: function(ul, item) {
        var markup = [
            '<span class="displayname">', item.displayname, '</span>'
        ];
        return $('<li>')
            .append(markup.join(''))
            .appendTo(ul);
    }

};

