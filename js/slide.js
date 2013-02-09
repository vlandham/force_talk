
if(typeof this.substeps == 'undefined') {
  this.substeps = [];
}

var src = null;
var parentWindow = window.parent;

window.onload = setup;

function setup() {
  src = parentWindow.document.getElementById(window.name).src;
  console.log('loaded:' + src);
  setupCode();
  // loadSubSteps();
  
  window.onmessage = receiveMessage;
}

function setupCode() {

  var codeSection = d3.select("#code");

  console.log(codeSection);

  if(!codeSection.empty()) {

    this.code = d3.select("body").append("div")
      .attr("class", "codeWall hide")
      // .style("display", "none")
    this.code.append("pre").append("code")
      .attr("class", codeSection.attr("class"))
      .html(codeSection.html())
    this.code.selectAll("code").each(function(d) { hljs.highlightBlock(this);});
  }
}

// function setupSubsteps() {
//   d3.select(this.contentWindow).on("keydown", function() {
//     switch (d3.event.keyCode) {
//       case 83: { // s
//         console.log('s');
//         break;
//       }
//       default: return;
//     }
// 
//       d3.event.preventDefault();
//   });
// }


function loadSubSteps() {
  if(window.name == "current") {
    console.log(window.name);
    parentWindow.setSubSteps(this.substeps);
  }
}

function isDone()
{
  return this.substeps.length == 0;
}

function receiveMessage(event)
{
  if(event.data.type == 'substep') {

    console.log('message received:' + window.name);
    parentWindow.setSubSteps(this.substeps);

  } else if(event.data.type == 'code') {
    if(typeof this.code != 'undefined') {
      var isOn = this.code.classed('hide');
      this.code.classed('hide', !isOn);
    }
  } else if(event.data.type == 'update') {
    console.log('update:' + src);
    var c_event = new CustomEvent('substep', {});
    window.dispatchEvent(c_event);
  }
  return true;
}

// function substep(name) {
// }

// window.onmessage = function(e) {
//   console.log(e);
// }
