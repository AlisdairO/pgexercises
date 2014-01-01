$(document).ready(function() {

	initLocalStoredInfo();

});

function initLocalStoredInfo() {
	if(typeof window.localStorage != 'undefined') { 
		var listingDom = $(".topiclisting").children();
		for(var i = 0; i < App.pageIDs.length; i++) {
			if (localStorage.getItem(App.pageIDs[i]+".success") == "true") {
				
				var img = $("<img class='listingtick' src='../../assets/tick2.svg'></img>");
				listingDom[i].appendChild(img.get(0));
			}
		}
	}
}
