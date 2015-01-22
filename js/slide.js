
if(typeof this.substeps == 'undefined') {
  this.substeps = [];
  console.log(this.substeps);
}

var src = null;
var parentWindow = window.parent;

window.onload = setup;

function setup() {
  // src = parentWindow.document.getElementById(window.name).src;
  // setupCode();
  
  window.onmessage = receiveMessage;
}

function setupCode() {

  var codeSection = d3.select("#code");

  if(!codeSection.empty()) {

    this.code = d3.select("body").append("div")
      .attr("class", "codeWall hide")
    this.code.append("pre").append("code");
    updateCode("#code");
  }
}

function updateCode(code_id) {
  var codeSection = d3.select(code_id);
  if(!codeSection.empty()) {
    var new_code = codeSection.html();
    // console.log(new_code);
    this.code.select("code")
      .html(new_code)
      .attr("class", codeSection.attr("class"))
      .attr("style", codeSection.attr("style"))
      .classed("hide", false);
    this.code.selectAll("code").each(function(d) { hljs.highlightBlock(this);});
  }
}

function receiveMessage(e) {
  if(e.data.type == 'code') {
    if(typeof this.code != 'undefined') {
      var isOn = this.code.classed('hide');
      this.code.classed('hide', !isOn);
    }
  } else if(e.data.type == 'substep') {
    // console.log('update:' + src);
    var cur_step = this.substeps.shift();
    if(typeof step == 'function' && typeof cur_step != 'undefined') {
      step(cur_step);
    } else {
      parentWindow.step(+1);
    }
  }
  return true;
}

/**
 * Returns a random number between min and max
 */
function getRandomArbitary (min, max) {
    return Math.random() * (max - min) + min;
}

/**
 * Returns a random integer between min and max
 * Using Math.round() will give you a non-uniform distribution!
 */
function getRandomInt (min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

