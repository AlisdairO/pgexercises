function clearLocalStoredInfo() {
	if(typeof window.localStorage != 'undefined') { 
		if (confirm('Really clear all saved data?')) { 
			localStorage.clear();
		}
	}
}
