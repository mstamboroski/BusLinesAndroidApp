
function getRequestResponseText(url, requestBody, parseFunction) {
    var xmlhttp = new XMLHttpRequest();
    xmlhttp.open("POST", url, true, "WKD4N7YMA1uiM8V", "DtdTtzMLQlA0hk2C1Yi5pLyVIlAQ68");
    xmlhttp.setRequestHeader("Content-Type", "application/json");
    xmlhttp.setRequestHeader("X-AppGlu-Environment", "staging");
    xmlhttp.send(requestBody);

    xmlhttp.onreadystatechange=function() {
        if (xmlhttp.readyState == 4) {
            parseFunction(xmlhttp.responseText);
        }
    }
}
