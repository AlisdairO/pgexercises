
var answershown = false;
var splitCont;
var splitContV;
var editor;
var isMSIE = 0;
var schemareminder = true;
/*@cc_on isMSIE=1;@*/

$(document).ready(function() {
	//start up the editor
	editor = initCodeMirror();
	$( "#codewrapper" ).dblclick(function(e) {
		e.stopPropagation();
	});

	//start up the two splitters
	splitCont = $("#splittercontainer").splitter({minAsize:100, splitVertical:true,A:$('#expres'),B:$('#codediv'),onresizefunc: sizeCodeMirror});
	splitContV = $("#codediv").splitter({minAsize:100, splitHorizontal:true,A:$('#youranswerdiv'),B:$('#yourresultsdiv'),onresizefunc: sizeCodeMirror});

	setOptimalExpectedResultsSize(false);

	initYourResults();
	initHint();
	initHelp();
	initExpRes();
	initSchema();

	initLocalStoredInfo();

	//make sure code editor resizes when its div resizes
//	$("#youranswerdiv").resize(function() {
//		sizeCodeMirror();				
//	});
	sizeCodeMirror();				

        initKeyHandler();
});

//size the left-right splitter to initially show all of the Expected Results
//table if we can.
function setOptimalExpectedResultsSize(fast) {
	if (typeof(fast) == "undefined") {
		fast = false;
	}
	deselectText()
	var tableWidth = $("#exprestable").width() + 20;
	var windowWidth = $("#splittercontainer").width();
	var perc = (tableWidth/windowWidth)*100;
	if(perc > 55) {
	perc = 55;
	}
	if(perc < 35) {
	perc = 35;
	}
	$("#splittercontainer").splitter("splitTo", perc, false, fast);
	$("#codediv").splitter("splitTo", 50, false, fast);
}

function setOptimalYourAnswerSize() {
	deselectText()
	$("#splittercontainer").splitter("splitTo", 35, false, false);
	$("#codediv").splitter("splitTo", 70, false, false);
}

function setOptimalYourResultsSize() {
	deselectText()
	$("#splittercontainer").splitter("splitTo", 35, false, false);
	$("#codediv").splitter("splitTo", 30, false, false);

}

function deselectText() {
	if(!isMSIE) {
		window.getSelection().removeAllRanges()
	} else {
		document.selection.empty()
	}
}

function initLocalStoredInfo() {
	if(typeof window.localStorage != 'undefined') { 
		if (localStorage.getItem(App.pageID+".success") == "true") {
			setPageSuccess();
		}
		var queryfield = localStorage.getItem(App.pageID+".queryfield");
		if(queryfield) {
			editor.setValue(queryfield);
		}
	}
}

function sizeCodeMirror() {
	var element = $("#youranswerdiv");
	var height = element.height() - element.find('h3').outerHeight(true)-4;
	editor.setSize(null, height + "px");
}

function initCodeMirror() {
	return CodeMirror.fromTextArea(document.getElementById('code'), {
		mode: "text/x-sql",
		indentWithTabs: true,
		smartIndent: true,
		matchBrackets : true,
		autofocus: false,
		viewportMargin: Infinity,
		onKeyEvent: function(cm, e) {
			if(e.altKey && e.type == "keydown") {
				e.preventDefault();
				var queryStr = "";
				if(e.which == 88) { //alt-x run selected
					queryStr = editor.getSelection();
				} else if (e.which == 82) { //alt-r, run everything
					queryStr = editor.getValue();
				} else if(e.which == 72) { // alt-h, show/hide help
					help();
				} else if (e.which == 83) { //alt-s run 'near cursor' - a best effort to find a queryStr near the cursor
					//queries can be bounded by semicolons or empty lines.
					//doesn't handle semicolons in quotes - but none of our questions
					//require those, so not bothering for now.  TODO?

					var cursorPos = editor.getCursor(); //returns a {line, ch} object
					var foundHead = false;
					var foundTail = false;
					var lineNo = cursorPos["line"];

					//we always assume the line the cursor is on is part of our queryStr
					//unless it's empty, in which case we track backwards.
					//not entirely reliable, but makes it easier to handle cases like
					//when the user alt+s immediately after the semi-colon.  Could certainly
					//improve on this behaviour in future
					var lineStr = editor.getLine(lineNo);
					while(lineNo >= 0 && $.trim(lineStr) === "") {
						lineNo--;
						lineStr = editor.getLine(lineNo);
					}

					initLineNo = lineNo;


					queryStr = editor.getLine(lineNo);
					if(queryStr.indexOf(";") != -1) {
						foundTail = true; //our first line is the end of the queryStr!
					}

					//handle lines behind the cursor
					lineNo--;
					while(!foundHead && lineNo >= 0) {
						lineStr = editor.getLine(lineNo);
						if($.trim(lineStr) === "") {
							foundHead = true;
						} else if (lineStr.indexOf(";") !== -1) {
							var startChr = lineStr.indexOf(";");
							var lineFragment = lineStr.substring(startChr + 1);
							queryStr = lineFragment + "\n" + queryStr;
							foundHead = true;
						} else {
							queryStr = lineStr + "\n" + queryStr;
						}
						lineNo--;
					}

					//handle lines ahead of the cursor
					lineNo = initLineNo + 1;
					while(!foundTail && lineNo < editor.lineCount()) {
						lineStr = editor.getLine(lineNo);
						if($.trim(lineStr) === "") {
							foundTail = true;
						} else if (lineStr.indexOf(";") !== -1) {
							var endChr = lineStr.indexOf(";");
							var lineFragment = lineStr.substring(0, endChr+1);
							queryStr = queryStr + "\n" + lineFragment;
							foundTail = true;
						} else {
							queryStr = queryStr + "\n" + lineStr;
						}
						lineNo++;

					}

				}
				queryStr = $.trim(queryStr);
				if(queryStr !== "") {
					if(queryStr.indexOf(";", queryStr.length - 1) === -1) {
						queryStr = queryStr + ";";
					}
					 
					//console.log(queryStr);
					//run queryStr
					query(queryStr);
				}
			}
		}
	});
}

function initHint() {
	$("#hint").dialog({autoOpen:false});
}

function initHelp() {
	$("#help").dialog({autoOpen:false, width:760, height:380});
}

//initialises expected results scrollbar
function initExpRes() {
	$("#expres").perfectScrollbar({wheelPropagation:true, wheelSpeed: 18});
	$("#expres").on('resize', function(e) { 
		$("#expres").perfectScrollbar('update');
	});
}

function initSchema() {
        schemareminder = localStorage.getItem("schemareminder") != "false";
        if(schemareminder) {
                $("#schemaremindercontents").slideToggle(0, function () {
                        setSchemaReminderArrow(false);
                });
        }
}

function setSchemaReminderArrow(arrow) {
        $("#schemareminderarrow").text(arrow ? "\u25BC" : "\u25B2");
}

function initYourResults() {
	//add scrollbar to the query results table
	$("#yourresultsdiv").perfectScrollbar({wheelPropagation:true, wheelSpeed: 18});
	$("#yourresultsdiv").on('resize', function(e) { 
		$("#yourresultsdiv").perfectScrollbar('update');
	});
}


function hint() {
	$("#hint").dialog('open');
}

function schema() {
	$("#schemaremindercontents").slideToggle(function () {
                setSchemaReminderArrow(schemareminder);
                schemareminder = !schemareminder;
                localStorage.setItem("schemareminder", schemareminder);
        });
}

function help() {
	var isOpen = $( "#help" ).dialog( "isOpen" );

	// Show Dialog if Closed, Hide Dialog if Open
	if(isOpen) {
		$("#help").dialog('close'); 
	} else {
		$("#help").dialog('open');
	}
}

function toggleAnswers(forceSetValue) {
	var setValue = answershown;
	//forcesetvalue is used to say 'set this to on or off, 
	//rather than toggling'
	if (typeof forceSetValue === 'undefined') {
		setValue = !answershown;
	} else {
		setValue = forceSetValue;
	}
	// Function linked to the button to trigger the fade.
	if(!setValue) {
		$(".answerdiv").fadeTo(300, 0);
		$("#answerbtn").text("Show");
	} else {
		$(".answerdiv").fadeTo(300, 1);
		$("#answerbtn").text("Hide");
	}
	$("#answerbtn").toggleClass("active", setValue);

	answershown = setValue;
}

function save() {
	if(typeof window.localStorage != 'undefined') {
		localStorage.setItem(App.pageID+".queryfield", editor.getValue());
	}
}

function query(str) {
	//whenever the user runs a query, save the contents of the editor
	save();

	//run the user query against our server
	if(!str) {
		str = editor.getValue();
	}
        
        var is_writeable = App.writeable == 1 ? 1 : 0;
        var table_to_return = is_writeable == 1 ? App.tableToReturn : null;

        //table emptied in advance + timeout used to force screen flicker to make a user
        //aware that a query has definitely been performed.
	var table = $("#yourresultstable");
	table.empty();
	window.setTimeout(function() {
		$.get("/SQLForwarder/SQLForwarder", {query:str, writeable:is_writeable, tableToReturn:table_to_return}, function(data) {
			//empty the error field, and fill the table with the JSON-formatted results!
			$("#yourresultserror").hide();

			var tbl_head = document.createElement('thead');
			var tbl_row = document.createElement('tr');
			tbl_head.appendChild(tbl_row);
			$.each(data["headers"], function(k, v) {
				var tbl_cell = document.createElement('th');
				var cell_text = document.createTextNode(v);
				tbl_cell.appendChild(cell_text);
				tbl_row.appendChild(tbl_cell);
			});
			table.get(0).appendChild(tbl_head);

			var tbl_body = document.createElement('tbody');
			$.each(data["values"], function() {
				var tbl_row = document.createElement('tr');
				tbl_body.appendChild(tbl_row);
				$.each(this, function(k , v) {
					var tbl_cell = document.createElement('td');
					var cell_text = document.createTextNode(v);
					tbl_cell.appendChild(cell_text);
					tbl_row.appendChild(tbl_cell);
				})
			})

			var correct = checkQueryResult(data);

			if(correct) {
				if(typeof window.localStorage != 'undefined') {
					localStorage.setItem(App.pageID+".success", "true");
				}
				setPageSuccess();

				$("#youranswertickspan").empty();
				$("#youranswertickspan").append($('<img class="youranswertick" src="../../assets/tick2.svg">'));
			} else {
				$("#youranswertickspan").empty();
				$("#youranswertickspan").append($('<img class="youranswertick" src="../../assets/cross.svg">'));
			}
			//make the 'Your Answer' tick/cross visible
			$("#youranswertickspan").css('visibility', 'visible');
			table.get(0).appendChild(tbl_body);
			table.show();
			$("#yourresultsdiv").perfectScrollbar('update');
		},"json").fail(function(xhr, status, error) {
			//handle errors coming back from the tomcat server
                        errText = xhr.responseText;
			errText += "\n\n Query was: " + str;

			$("#yourresultstable").empty();
			$("#yourresultstable").hide();
			$("#yourresultserror").empty();
			$("#yourresultserror").get(0).appendChild(document.createTextNode(errText));
			$("#yourresultserror").show();
			$("#yourresultsdiv").perfectScrollbar('update');
			$("#youranswertickspan").empty();
			$("#youranswertickspan").append($('<img class="youranswertick" src="../../assets/cross.svg">'));
			$("#youranswertickspan").css('visibility', 'visible');
		})
	}, 10);
}

//When the user runs a query, does it match what we'd expect?
function checkQueryResult(queryResult) {
	//sort the results of the query if necessary.  It's necessary when
	//the exercise doesn't require sorting, in which case the results
	//might come back in any order.
	queryResult.values = sortJSONResults(queryResult.values);

	//console.dir(queryResult.values);
	//console.dir(App.jsonResults);

	if(queryResult.values.length != App.jsonResults.length) {
	return false;
	}

	for(var i = 0; i < queryResult.values.length; i++) {
		if(queryResult.values[i].length !== App.jsonResults[i].length) {
		return false;
	}
		for(var j = 0; j < queryResult.values[i].length; j++) {
			if(queryResult.values[i][j] !== App.jsonResults[i][j]) {
				return false;
			}
		}

	}
	return true;
}

//sort a query result set.  Only need to do this when
//it's not already sorted by the database.
function sortJSONResults(jsonResults) {
	var jRes = jsonResults;
	if(!App.sorted) {
		jRes.sort(function(a,b) {
			for(var i = 0; i < a.length; i++) {
				if(a[i] > b[i]) {
					return 1;
				}
				if(a[i] < b[i]) {
					return -1;
				}
			}
			return 0;
		});
	}
	return jRes;
}


function setPageSuccess() {
	//if we've got it right, make the header tick visible and show the answers
	$(".headertick").css('visibility', 'visible');
	toggleAnswers(true)
}

function initKeyHandler() {
    // toggle the help window shortcut
    $(document).on("keydown", function (e) {
        if (e.altKey && e.type == "keydown" && e.which == 72) {
            help();
        }
    });
}
