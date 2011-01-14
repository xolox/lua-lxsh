function LXSH_GetAllStyles() {
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

function LXSH_GetActiveStyle() {
  var elements = LXSH_GetAllStyles();
  for (var i = 0; i < elements.length; i++)
    if (!elements[i].disabled)
      return elements[i].getAttribute('title');
}

function LXSH_ChangeStyle(newstyle) {
  var head = document.getElementsByTagName('head')[0];
  var elements = LXSH_GetAllStyles();
  for (var i = elements.length - 1; i >= 0; i--)
    elements[i].disabled = (elements[i].getAttribute('title') != newstyle);
}

function createCookie(name, value, days) {
  if (days) {
    var date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    var expires = "; expires=" + date.toGMTString();
  } else
    expires = "";
  document.cookie = name + "=" + value + expires + "; path=/";
}

function readCookie(name) {
  var nameEQ = name + "=";
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) == ' ')
      c = c.substring(1, c.length);
    if (c.indexOf(nameEQ) == 0)
      return c.substring(nameEQ.length, c.length);
  }
  return null;
}

window.onload = function() {
  var styles = LXSH_GetAllStyles();
  var active = readCookie('lxsh_colors');
  if (active != null)
    LXSH_ChangeStyle(active);
  else
    active = LXSH_GetActiveStyle();
  var elements = document.getElementsByTagName('pre');
  for (var i = elements.length - 1; i >= 0; i--)
    if (elements[i].getAttribute('class').indexOf('sourcecode') >= 0) {
      var select = document.createElement('select');
      select.style.cssFloat = 'right';
      select.style.padding = '5px';
      select.onclick = function() {
        var elements = select.getElementsByTagName('option');
        for (var j = 0; j < elements.length; j++)
          if (elements[j].selected) {
            var name = elements[j].innerHTML;
            LXSH_ChangeStyle(name);
            createCookie('lxsh_colors', name, 365);
            break;
          }
      }
      var group = document.createElement('optgroup');
      group.label = 'Colors:';
      select.appendChild(group);
      for (var j = styles.length - 1; j >= 0; j--) {
        var option = document.createElement('option');
        var name = styles[j].getAttribute('title');
        option.innerHTML = name;
        option.title = 'Select the "' + name + '" color scheme';
        if (name == active)
          option.selected = true;
        group.appendChild(option);
      }
      elements[i].insertBefore(select, elements[i].firstChild);
    }
}
