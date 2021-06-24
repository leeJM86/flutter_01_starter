var xmlHttp = new XMLHttpRequest();
var txt1 = document.querySelector("#txt");
var message;

xmlHttp.onreadystatechange = function(e){
    if(this.readyState == 4){
        if(this.status == 200){
            postmsg(this.responseText);
        }else{
            postmsg("status...");
        }
    }else{
        postmsg("readyState...");
    }
}

function postmsg(str1){
    if (window.flutterMessage && window.flutterMessage.postMessage) {
      flutterMessage.postMessage(message+str1);
      txt1.innerHTML = message+str1;
    }
}

function message1(str2){
    message = str2;
    //postmsg(" ");
    xmlHttp.open("GET","test.txt",true);
    xmlHttp.send();
}

var t = document.querySelector("#btn1");
t.addEventListener("click", function(e){
    message1("webClick=====================");
});