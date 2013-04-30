var svg = d3.select("svg"),
    m = 20,
    left = 150,
    padding = 2,
    charge = 25;

var questions = [
  {title:"STÓRIÐJA",no:1},
  {title:"ESB",no:6},
  {title:"NATO",no:8},
  {title:"FRELSI",no:59},
  {title:"STRANDVEIÐAR",no:41},
  {title:"STJÓRNLAGARÁÐ",no:41},
  {title:"HJÁLPARSTARF",no:53},
  {title:"SKULDANIÐURFÆRSLA",no:28},
  {title:"ÞJÓÐKIRKJA",no:64},
  {title:"EITT KJÖRDÆMI",no:43}
];

questions.forEach(function(d,i) {
  d.fixed = true;
  d.radius = 25;
  d.class = "question";
  d.x = 75,
  d.y = 65+i*75;
});

answers.forEach(function(d) {
  d.radius = 8;
  d.class ="candidate "+ d.party;
  d.title = d.candidate_name+" "+d.party;
});

var force = d3.layout.force()
  .nodes(answers.concat(questions))
  .charge(0)
  .gravity(0)
  .on("tick",tick);

svg.append("rect")
  .attr({x:0,y:0,width:left,height:3000})
  .style("fill","#D8D8D8");

svg.append("text")
  .attr({x:left/2,y:20,class:"label"})
  .text("Drag/drop circles ->");

circles = svg.append("g")
  .selectAll(".candidate")
    .data(force.nodes())
  .enter()
    .append("g")
   .attr("class",function(d) { return d.class;})
    .call(force.drag);

circles.append("circle")
  .attr("r",function(d) { return d.radius;})
  .attr("x",function(d) { return -d.radius/2;})
  .attr("y",function(d) { return -d.radius/2;})
  .call(function(g) {
    g.append("title")
      .text(function(d) { return d.title;});
  });

var candidates = d3.selectAll(".candidate"),
    questions = d3.selectAll(".question");


questions.append("text")
  .text(function(d) { return d.title;})
  .attr({class:"white label",dy:5});

questions.append("text")
  .text(function(d) { return d.title;})
  .attr({"class":"label",dy:5});

function tick(e) {
  force.resume();
  candidates
    .each(function(d) {
      questions.each(function(q) {
        if (q.x < 150) return;
        var dx = d.x - q.x,
            dy = d.y - q.y,
            dn = 1 / Math.sqrt(dx * dx + dy * dy);
        d.px += charge * dx * Math.pow(dn,2) * d.answers[q.no]|| 0;
        d.py += charge * dy * Math.pow(dn,2) * d.answers[q.no]|| 0;
      });
    })
    .each(collide(0.5))
    .each(function(node) {
      node.x = Math.max(150+node.radius/2,Math.min(container.offsetWidth-m,node.x));
      node.y = Math.max(m,Math.min(container.offsetHeight-m,node.y));
    });

  circles.attr("transform", function(d) {
    return "translate(" + d.x + "," + d.y + ")";
  });
}

// Resolve collisions between nodes.
function collide(alpha) {
  var quadtree = d3.geom.quadtree(force.nodes());
  return function(d) {
    var r = d.radius +  padding,
        nx1 = d.x - r,
        nx2 = d.x + r,
        ny1 = d.y - r,
        ny2 = d.y + r;
    d.last = new Date();
    quadtree.visit(function(quad, x1, y1, x2, y2) {
      if (quad.point && (quad.point !== d)) {
        var x = d.x - quad.point.x,
            y = d.y - quad.point.y,
            l = Math.sqrt(x * x + y * y),
            r = (d.radius + quad.point.radius+padding);
        if (l < r) {
          l = (l - r) / l * 0.5;
          d.x -= x *= l;
          d.y -= y *= l;
          if (!quad.point.fixed && quad.point.last != d.last) {
            quad.point.x += x;
            quad.point.y += y;
          }
        }
      }
      return x1 > nx2
          || x2 < nx1
          || y1 > ny2
          || y2 < ny1;
    });
  };
}


function resize() {
  force.size([container.offsetWidth, container.offsetHeight]).start();
}

d3.select(window).on("resize",resize);
resize();
