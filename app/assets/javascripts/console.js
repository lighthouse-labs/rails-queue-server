var hijackConsole = function(win) {

  var ncon = win.console;

  // check if already applied (force idempotence)
  if(typeof(ncon.direct) === 'function') return false;

  var con = win.console = {
    backlog: [],
    container: $('#console'),
    display: function(args) {
      var output = [];
      for (arg in args) {
        output.push(JSON.stringify(args[arg]));
      }
      this.container.append(output.join(', ') + ' <br>');
    },
    clearDisplay: function() {
      this.container.html('');
    },
    direct: function(msg) {
      this.container.append('<span style="color: red;">' + msg + '</span><br>');
    }
  };

  ['log'].forEach( function(k) {
    con[k] = (function(fn) {
      return function() {
        // clone/dupe the data being stored in backlog
        var data = arguments[0];
        if (data instanceof Array) {
          data = data.slice(0);
        } else if (typeof(data) == 'object') {
          data = jQuery.extend({}, data);
        }
        con.backlog.push([new Date(), fn, data]);
        ncon[fn].apply(ncon, arguments);
        con.display(arguments);
      };
    })(k);
    con['clear'] = (function(fn) {
      return function() {
          con.backlog = [];
          con.clearDisplay();
          ncon['clear'].apply(ncon, arguments);
      };
    })('clear');
  });
};

$(document).on('turbolinks:load', function() {
  if ($('#console')[0]) {
    hijackConsole(window);
  }
});
