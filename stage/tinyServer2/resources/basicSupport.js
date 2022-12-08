
function includeHTML() {
  /* Loop through a collection of all HTML elements: */
  var z = document.getElementsByTagName("*");
  for (var i = 0; i < z.length; i++) {
    var elmnt = z[i];
    /*search for elements with a certain atrribute:*/
    var file = elmnt.getAttribute("w3-include-html");
    var interval = elmnt.getAttribute("include-interval");
    if (file) {
      console.log('Processing label '+file);
      /* Make an HTTP request using the attribute value as the file name: */
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
          if (this.status == 200) {elmnt.innerHTML = this.responseText; elmnt.removeAttribute("w3-include-html");}
        }
      }
      elmnt.removeAttribute("w3-include-html");
      if (interval) {
        console.log(file+' Should be updated every ms: '+interval);
        setInterval(function() {
           var xmlHttp = new XMLHttpRequest();
           xmlHttp.onreadystatechange = function() {
               if (xmlHttp.readyState == 4 && xmlHttp.status == 200) {elmnt.innerHTML = xmlHttp.responseText;}
           }
           xmlHttp.open("GET", file, true);
           xmlHttp.send(null);
         },interval);
      }
      xhttp.open("GET", file, true);
      xhttp.send();
      includeHTML();
      /* Exit the function: */
      return;
    }
  }
}

function asyncGet(url, withResponseDo) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4) {
      if (this.status == 200) {withResponseDo(this.responseText);}
    }
  }
  xhttp.open("GET", url, true);
  xhttp.send();
}

function setupCollapsibles() {
  var coll = document.getElementsByClassName("collapsible");
  for (var i = 0; i < coll.length; i++) {
    coll[i].addEventListener("click", function() {
      this.classList.toggle("active");
      var content = this.nextElementSibling;
      if (content.style.maxHeight){
        content.style.maxHeight = null;
      } else {
        content.style.maxHeight = content.scrollHeight + "px";
      }
    });
  }
}

function getUrlVars() {
  var vars = {};
  var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
      vars[key] = value;
  });
  return vars;
}

