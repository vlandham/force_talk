var fs = require("fs"),
    clues = require("clues"),
    csv = require("ya-csv");

var logic={};

score = {
  'Mjög sammála' : 2,
  'Sammála' : 1,
  'Hvorki né' : 1,
  'Ósammála' : -1,
  'Mjög ósammála' : -2,
  'Vil ekki svara': 0,
  'Mjög hlynnt(ur)' : 2,
  'Frekar hlynnt(ur)' : 1,
  'Hlutlaus' : 0,
  'Frekar andvíg(ur)' : -1,
  'Mjög andvíg(ur)' : -1,
  'Hagsmunum Íslands er best borgið í ESB' : 1.5,
  'Hagsmunum Íslands er best borgið utan ESB' : -1.5,
  'Veit ekki' : 0
};

logic.candidates = function(resolve) {
  var res = {};
  csv.createCsvFileReader("candidates.csv",{ columnsFromHeader: true })
    .on('data',function(d) {
      if (d.party)  d.party = d.party.replace(/\s/g,"_");
      d.answers = [];
      res[d.candidate_name] = d;
    })
    .on('end',function() {
      resolve(res);
    });
};

logic.answers = function(candidates,resolve) {
  csv.createCsvFileReader("answers.csv",{columnsFromHeader: true})
    .on("data",function(d) {
      var candidate = candidates[d.candidate_name];
      if (!candidate) return console.log(d.candidate_name+" not found");
      candidate.answers[d.q_id] = score[d.response] || null;
    })
    .on('end',function() {
      var answers = Object.keys(candidates)
        .map(function(d) { return candidates[d];})
        .filter(function(d) { return d.answers.length;});
      resolve(answers);
    });
};

// MAIN
clues(logic)
  .solve("answers")
  .then(function(d) {
    fs.writeFileSync("../data.js","answers = "+JSON.stringify(d));
  });

