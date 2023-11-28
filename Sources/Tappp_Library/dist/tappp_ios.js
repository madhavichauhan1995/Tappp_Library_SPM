function handleMessage(gameId, bookId, width, broadcasterName, userId, widthUnit, appURL, deviceType, env,encodedRequest,UserAuthnToken,device,channelId) {
    console.log("encodedRequest in handleMessage: ",encodedRequest)
    console.log("UserAuthnToken in handleMessage: ",UserAuthnToken)
    try {
        if(!widthUnit) {
            widthUnit = '%';
        }
        if(gameId && bookId){
            //            Dynamically create a placeholder div for panel
            createDivForReactNative(gameId, bookId, width, broadcasterName, userId, widthUnit, env,encodedRequest,UserAuthnToken,device,channelId);
            //            Load all the react native scripts
            loadReactLiveScriptAPI(appURL);
            //            Helper functions
            //            helperTapppFn(gameId, bookId, width);
        }
    } catch(e) {
        console.log('...Error on handle message', e);
    }
}

//    Create root div for the Panel library
function createDivForReactNative(gameId, bookId, width, broadcasterName, userId, widthUnit, env,encodedRequest,UserAuthnToken,device,channelId) {
    const rootDiv = document.createElement('div');
    
//    const rootTag = "<div id='tappp-panel' userid='"+ userId +"' bookid='"+ bookId +"' gameid='"+ gameId +"' width='"+ width +"' widthunit='" + widthUnit +"' broadcastername='" + broadcasterName + "' env='"+ env +"'></div>";
    
    const rootTag = "<div id='tappp-panel' userid='"+ userId +"' bookid='"+ bookId +"' gameid='"+ gameId +"' width='"+ width +"' widthunit='" + widthUnit +"' broadcastername='" + broadcasterName +"' env='" + env + "' UserAuthnToken='" + UserAuthnToken + "' encodedRequest='"+ encodedRequest +"' device='"+ device +"' channelid='"+ channelId +"'></div>";
    
    rootDiv.innerHTML = rootTag;
    
    document.body.appendChild(rootDiv);
    
}

function loadReactLiveScriptAPI(url) {
    const scriptTag = document.createElement('script');
    scriptTag.type = 'text/javascript';
    scriptTag.src = url
//    scriptTag.src = "https://dev-bets.tappp.com/f2p-jwt/bundle.js"
    document.body.appendChild(scriptTag);
}
//    Do specific thing once the script loaded
function callFunctionFromScript(gameId, bookId, width, calledFrom) {
    const scritpTagFn = 'scriptOnloadTag';
    const divErr = document.createElement('div');
    divErr.innerHTML = calledFrom;
    document.getElementById(scritpTagFn).appendChild(divErr);
}

function helperTapppFn(gameId, bookId, width) {
    const helperDiv = document.createElement('div');
    let gameTag = "<input type='text' name='value' id='gameId' value='"+gameId+"' />";
    let bookTag = "<input type='text' name='value' id='bookId' value='"+bookId+"' />";
    let widthTag = "<input type='text' name='value' id='widthId' value='"+width+"' />";
    
    helperDiv.innerHTML = gameTag + bookTag + widthTag +`
            <label>
              <input type="checkbox" name="check" value="1" /> Checked?
            </label>
            <input type="button" value="-" onclick="removeRow(this)" />
          `;
    document.getElementById('parentId').appendChild(helperDiv);
}

function callNative() {
    webkit.messageHandlers.callNative.postMessage({
        "message": "callNative method data passes"
    });
}

function nativeToJs(objPanelData){
    console.log("....objPanelData in js=", objPanelData)
}

function showiOSToast() {
    let nameField = document.getElementById('nameField').value;
    webkit.messageHandlers.toggleMessageHandler.postMessage({
        "message": nameField
    });
}

function sendMessageToNative(valueReceived) {
    window.webkit.messageHandlers.tapppPanelAction.postMessage(valueReceived);
}
