/*
* NB: This version horribly hacked into a jQuery UI widget by Alisdair Owens
* Probably has bugs in it, so check it over before using for anything important
* TODO - fix it up.
*
* Released under the same license as the original, which is reproduced below:
*
* jQuery.splitter.js - animated splitter plugin
*
* version 1.0 (2010/01/02) 
* 
* Dual licensed under the MIT and GPL licenses: 
*   http://www.opensource.org/licenses/mit-license.php 
*   http://www.gnu.org/licenses/gpl.html 
*/

/**
* jQuery.splitter() plugin implements a two-pane resizable animated window, using existing DIV elements for layout.
* For more details and demo visit: http://krikus.com/js/splitter
*
* @example $("#splitterContainer").splitter({splitVertical:true,A:$('#leftPane'),B:$('#rightPane'),closeableto:0});
* @desc Create a vertical splitter with toggle button
*
* @example $("#splitterContainer").splitter({minAsize:100,maxAsize:300,splitVertical:true,A:$('#leftPane'),B:$('#rightPane'),slave:$("#rightSplitterContainer"),closeableto:0});
* @desc Create a vertical splitter with toggle button, with minimum and maximum width for plane A and bind resize event to the slave element
*
* @name splitter
* @type jQuery
* @param Object options Options for the splitter ( required)
* @cat Plugins/Splitter
* @return jQuery
* @author Kristaps Kukurs (contact@krikus.com)
*/

//.width() gets computed width 

$(function(){
	$.widget("custom.splitter", {
		options: {
			minAsize:0, //minimum width/height in PX of the first (A) div.
			maxAsize:Infinity, //maximum width/height  in PX of the first (A) div.
			minBsize:0, //minimum width/height in PX of the second (B) div.
			maxBsize:Infinity, //maximum width/height  in PX of the second (B) div.
			ghostClass: 'working',// class name for this._ghosted splitter and hovered button
			invertClass: 'invert',//class name for invert splitter button
			animSpeed: 250 //animation speed in ms
		},
		_create: function() {
			var self = this;
			this.ismovingNow = false;
			this.direction = (this.options.splitHorizontal? 'h':'v');
			this.opts = $.extend({}, {
					v:{ // Vertical
						moving:"left",sizing: "width", eventPos: "pageX",splitbarClass:"splitbarV",buttonClass: "splitbuttonV", cursor: "e-resize"
					},
					h: { // Horizontal 
						moving:"top",sizing: "height", eventPos: "pageY",splitbarClass:"splitbarH",buttonClass: "splitbuttonH",  cursor: "n-resize"
					}
				}[this.direction], this.options);
			this.splitter = this.element;
			this.mychilds =this.splitter.children(); //$(">*", splitter[0]);
			this.A = this.options.A;	// left/top frame
			this.B = this.options.B;// right/bottom frame
			if(typeof(this.options.onresizefunc) == "undefined") {
				this.onresizefunc = function() {};
			} else {
				this.onresizefunc = this.options.onresizefunc;
			}
			this.slave=this.options.slave;//optional, elemt forced to receive resize event
			//Create splitbar 
			this.C=$('<div><span></span></div>');
			this.A.after(this.C);
			this.C.attr({"class": this.opts.splitbarClass,unselectable:"on"}).css({"cursor":this.opts.cursor,"user-select": "none", "-webkit-user-select": "none","-khtml-user-select": "none", "-moz-user-select": "none"}).bind("mousedown.splitter", function(e) {self.startDrag(e);});
			if(this.opts.closeableto!=undefined){
				this.Bt=$('<div></div>').css("cursor",'pointer');
				this.C.append(this.Bt);
				this.Bt.attr({"class": this.opts.buttonClass, unselectable: "on"});
				this.Bt.hover(function(){
						$(this).addClass(self.opts.ghostClass);
					},
					function(){
						$(this).removeClass(self.opts.ghostClass);
					});
				this.Bt.mousedown(function(e){
					if(e.target != this)
						return;
					self.Bt.toggleClass(self.opts.invertClass).hide();
					self.splitTo((self.splitPos==self.opts.closeableto)?self._splitPos:self.opts.closeableto,true, true);
					return false;
				});
			}		
	 		
			//reset size to default.			
			var perc=(((this.C.position()[this.opts.moving])/this.splitter[this.opts.sizing]())*100).toFixed(1);
			this.splitTo(perc,false,true); 
			// resize  event handlers;
			this.splitter.bind("resize.splitter",function(e, size){
					if(e.target!=this)
						return;
					self.splitTo(self.splitPos,false,true);
				});
				
			$(window).bind("resize.splitter",function(){self.splitTo(self.splitPos,false,true);});
		},

		startDrag : function(e) {
			if(e.target != this.C[0])
				return;
			var self = this;
			this._ghost = this._ghost || this.C.clone(false).insertAfter(this.A);
			this.splitter._initPos=this.C.position();
			this.splitter._initPos[this.opts.moving]-=this.C[this.opts.sizing]();
			this._ghost.addClass(this.opts.ghostClass).css('position','absolute').css('z-index','250').css("-webkit-user-select", "none").width(this.C.width()).height(this.C.height()).css(this.opts.moving,this.splitter._initPos[this.opts.moving]);
			this.mychilds.css("-webkit-user-select", "none");	// webkit selects A/B text on a move
			this.A._posSplit = e[this.opts.eventPos];

			$(document).bind("mousemove.splitter", function(e){self.performDrag(e);}).bind("mouseup.splitter", function(e) {self.endDrag(e);});
		},
			//document.onmousemove=this.performDrag
		performDrag : function(e) {
			if (!this._ghost||!this.A) 
				return;
			var splitsize=this.splitter[this.opts.sizing]();
			var max = Math.min(splitsize, this.opts.maxAsize) -10;
			var min = 0;
			var incr = e[this.opts.eventPos]-this.A._posSplit;
			var init = this.splitter._initPos[this.opts.moving];
			var moveTo = init+incr;
			if(moveTo > max) {
				moveTo = max;
			}
			if(moveTo < min) {
				moveTo = min;
			}
			this._ghost.css(this.opts.moving, moveTo);

		},
		//this.C.onmouseup=this.endDrag			
		endDrag : function(e) {
			var p=this._ghost.position();
			this._ghost.remove(); this._ghost = null;	
			this.mychilds.css("-webkit-user-select", "");// let webkit select text again
			$(document).unbind("mousemove.splitter").unbind("mouseup.splitter");
			var perc=(((p[this.opts.moving])/this.splitter[this.opts.sizing]())*100).toFixed(1);
			if(perc > 100) {
				perc = 100;
			}
			if(perc < 0) {
				perc = 0;
			}
			this.splitTo(perc,(this.splitter._initPos[this.opts.moving]>p[this.opts.moving]),false); 
		},

		splitTo : function (perc,reversedorder,fast) {
			if(this._ismovingNow||perc==undefined)
				return;//generally MSIE problem

			var self = this;

			this._ismovingNow=true;
			if(this.splitPos&&this.splitPos>10&&this.splitPos<90)//do not save accidental events
				this._splitPos=this.splitPos;
			this.splitPos=perc;
			

			var barsize=this.C[this.opts.sizing]()+(2*parseFloat(this.C.css('border-'+this.opts.moving+'-width')));//+ border. cehap&dirty
			var splitsize=this.splitter[this.opts.sizing]();
			if(this.opts.closeableto!=perc){
				var percpx=Math.max(parseInt((splitsize/100)*perc),this.opts.minAsize);
				if(this.opts.maxAsize)
					percpx=Math.min(percpx,this.opts.maxAsize);
				}else{
					percpx=parseInt((splitsize/100)*perc,0);
				}
				if(this.opts.maxBsize){
					if((splitsize-percpx)>this.opts.maxBsize)
						percpx=splitsize-this.opts.maxBsize;
				}
				if(this.opts.minBsize){
					if((splitsize-percpx)<this.opts.minBsize)
						percpx=splitsize-this.opts.minBsize;
				}
				//var sizeA = percpx
				//var sizeB = splitsize-percpx-barsize;
				var sizeA = (percpx-barsize);
				var sizeB = (splitsize-percpx);
				if(sizeB > splitsize - barsize) {
					sizeB = splitsize - barsize;
				}

				sizeA=Math.max(0,sizeA);
				sizeB=Math.max(0,sizeB);
				splitsize=(splitsize-barsize);

					//this.A.attr('title','- '+sizeA);  this.B.attr('title','- '+sizeB);
				 if(fast){
					this.A.show().css(this.opts.sizing,sizeA+'px');
					this.B.show().css(this.opts.sizing,sizeB+'px');
					if(this.Bt) {
						this.Bt.show();
					}
					if (!$.browser.msie ){
						this.mychilds.trigger("resize");
						if(this.slave)
							this.slave.trigger("resize");
					}
					this._ismovingNow=false;	
					this.onresizefunc();
					return true;
				}				
				if(reversedorder){//reduces flickering if total percentage becomes more  than 100 (possible while animating)
					
					var anob={};
					anob[this.opts.sizing]=sizeA+'px';
					this.A.show().animate(anob, {
						duration: this.opts.animSpeed,
						complete: function(){
							if(self.Bt) {
								self.Bt.fadeIn('fast');
							}
							if(self.B[self.opts.sizing]()<2){
								self.B[0].style.display='none';
								self.B.stop(true,true);
								self.B[self.opts.sizing]((splitsize-10)+'px');
							}
						},
					        progress: self.onresizefunc
					});
					var anob2={};
					anob2[this.opts.sizing]=sizeB+'px';
					this.B.show().animate(anob2, {
						duration: this.opts.animSpeed,
						complete: function(){
							if(self.Bt) {
								self.Bt.fadeIn('fast');
							}
							if(self.A[self.opts.sizing]()<2){
								self.A[0].style.display='none';
								self.A.stop(true,true);
								self.A[self.opts.sizing](splitsize+'px')
							}
						},
					        progress: self.onresizefunc
					});

					this.onresizefunc();
				}else{
					var anob={};
					anob[this.opts.sizing]=sizeB+'px';
					this.B.show().animate(anob, {
					    duration: this.opts.animSpeed,
					    complete: function(){
								if(self.Bt) {
									self.Bt.fadeIn('fast');
								}
								if(self.A[self.opts.sizing]()<2){
									self.A[0].style.display='none';
									self.A.stop(true,true);
									self.A[self.opts.sizing](splitsize+'px')
								}
							},
					    progress: self.onresizefunc
					});

						
					var anob={};
					anob[this.opts.sizing]=sizeA+'px';
					this.A.show().animate(anob, {
						duration: this.opts.animSpeed,
						complete: function(){
							if(self.Bt) {
								self.Bt.fadeIn('fast');
							}
							if(self.B[self.opts.sizing]()<2){
								self.B[0].style.display='none';
								self.B.stop(true,true);
								self.B[self.opts.sizing]((splitsize-10)+'px');
							}
						},
						progress: self.onresizefunc
					});					
					this.onresizefunc();
				}	
				//trigger resize evt
				this.splitter.queue(function(){  
					setTimeout(function(){  
						self.splitter.dequeue();
						self._ismovingNow=false;
						self.mychilds.trigger("resize");
						if(self.slave)
							self.slave.trigger("resize");		
					}, self.opts.animSpeed+5);  
				});
 
			}//end self.splitTo()

	});

});
