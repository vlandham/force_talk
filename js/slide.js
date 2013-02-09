
if(typeof this.substeps == 'undefined') {
  this.substeps = [];
}
var parentWindow = window.parent;
// var src = window.parent.document.getElementsByName(window.name)[0].src;

window.onload = setup;

function setup() {
  loadSubSteps();
  
  window.onmessage = receiveMessage;
}


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

  } else if(event.data.type == 'update') {
    console.log('update:' + window.name);
    var c_event = new CustomEvent('substep', {});
    window.dispatchEvent(c_event);
  }
  // loadSubSteps();
  return true;
  // console.log(event);
 
  // event.source is popup
  // event.data is "hi there yourself!  the secret response is: rheeeeet!"
}

// function substep(name) {
// }

// window.onmessage = function(e) {
//   console.log(e);
// }
