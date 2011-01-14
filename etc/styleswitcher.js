function LXSH_GetStyles() {
  var elements = document.getElementsByTagName('link');
  var selected = new Array();
  for (var i = elements.length - 1; i >= 0; i--)
    if (elements[i].getAttribute('rel').indexOf('stylesheet') >= 0) {
      var href = elements[i].getAttribute('href');
      if (href && href.indexOf('http://peterodding.com/code/lua/lxsh/styles/') == 0)
        selected.push(elements[i]);
    }
  return selected;
}

function LXSH_ChangeStyle(newstyle) {
  var head = document.getElementsByTagName('head')[0];
  var elements = LXSH_GetStyles();
  for (var i = elements.length - 1; i >= 0; i--)
    elements[i].disabled = (elements[i].getAttribute('title') != newstyle);
}

window.onload = function() {
  var styles = LXSH_GetStyles();
  var elements = document.getElementsByTagName('pre');
  for (var i = elements.length - 1; i >= 0; i--)
    if (elements[i].getAttribute('class').indexOf('sourcecode') >= 0)
      for (var j = styles.length - 1; j >= 0; j--) {
        var name = styles[j].getAttribute('title');
        var link = document.createElement('a');
        link.style.padding = '3px';
        link.style.cssFloat = 'right';
        link.innerHTML = name;
        link.title = 'Switch to the ' + name + ' color scheme';
        link.href = 'javascript:LXSH_ChangeStyle("' + name + '");';
        elements[i].insertBefore(link, elements[i].firstChild);
      }
}
