//addLoadEvent(CurrentTab);

function CurrentTab(){
    //var current = $();
    //current.id = "current";

    var i = 0;
    var form = $("aspnetForm");
    var url = form.action.substring(form.action.lastIndexOf('/')+1);
    var navlinks = $("a");
    while(i < navlinks.length){
        if(navlinks[i].getAttribute("href") == "/TeamRaile/" + url){
            navlinks[i].id = "current";
            break;            
        }
        i = i+1;
    }
}

function addLoadEvent(func) {
	var oldonload = window.onload;
	if (typeof window.onload != 'function') {
		window.onload = func;
	}
	else {
		window.onload = function() {
			oldonload();
			func();
		}
	}
}

function addEvent(elm, evType, fn, useCapture) {
	if (elm.addEventListener) {
		elm.addEventListener(evType, fn, useCapture);
		return true;
	}
	else if (elm.attachEvent) {
		var r = elm.attachEvent('on' + evType, fn);
		return r;
	}
	else {
		elm['on' + evType] = fn;
	}
}

function $() {
    var elements = new Array();
    for (var i=0,len=arguments.length;i<len;i++) {
        var element = arguments[i];
        if (typeof element == 'string') {
            var matched = document.getElementById(element);
            if (matched) {
                elements.push(matched);
            } else {
                var allels = (document.all) ? document.all : document.getElementsByTagName('*');
                var regexp = new RegExp('(^| )'+element+'( |$)');
                for (var i=0,len=allels.length;i<len;i++) if (regexp.test(allels[i].className)) elements.push(allels[i]);
            }   
            if (!elements.length) elements = document.getElementsByTagName(element);
            if (!elements.length) {
            elements = new Array();
            var allels = (document.all) ? document.all : document.getElementsByTagName('*');
            for (var i=0,len=allels.length;i<len;i++) if (allels[i].getAttribute(element)) elements.push(allels[i]);
        }
    if (!elements.length) {
        var allels = (document.all) ? document.all : document.getElementsByTagName('*');
        for (var i=0,len=allels.length;i<len;i++) if (allels[i].attributes) for (var j=0,lenn=allels[i].attributes.length;j<lenn;j++) if (allels[i].attributes[j].specified) if (allels[i].attributes[j].nodeValue == element) elements.push(allels[i]);
            }
        } else {
            elements.push(element);
        }
    }
    if (elements.length == 1) {
      return elements[0];
    } else {
        return elements;
    }
}
