
root = exports ? this

$ ->
  disciplines =
    "abmayr lab": "development"
    "baumann lab": "chromosome dynamics"
    "blanchette lab": "rna"
    "conaway lab": "transcription"
    "gerton lab": "chromosome dynamics"
    "gibson lab": "development"
    "hawley lab": "chromosome dynamics"
    "jaspersen lab": "chromosome dynamics"
    "krumlauf lab": "development"
    "li l lab": "stem cells"
    "li r lab": "cell biology"
    "mak lab": "lipid metabolism"
    "piotrowski lab": "development"
    "sanchez lab": "stem cells"
    "shilatifard lab": "transcription"
    "si lab": "neurobiology"
    "trainor lab": "development"
    "workman lab": "transcription"
    "xie lab": "stem cells"
    "yu lab": "neurobiology"
    "zeitlinger lab": "transcription"

  current_labs =
    "abmayr lab": true
    "baumann lab": true
    "blanchette lab": true
    "conaway lab": true
    "gerton lab": true
    "gibson lab": true
    "hawley lab": true
    "jaspersen lab": true
    "krumlauf lab": true
    "li l lab": true
    "li r lab": true
    "mak lab": true
    "shilatifard lab": true
    "si lab": true
    "trainor lab": true
    "workman lab": true
    "xie lab": true
    "yu lab": true
    "zeitlinger lab": true

  old_labs =
    "coffman lab": true
    "cowan lab": true
    "du lab": true
    "pourquie lab": true
    "eggan lab": true
    "sauer lab": true
    "golic lab": true
    "davidson 1 lab":true
    "davidson lab":true

  cores =
    "cytometry facility": true
    "research advisor": true
    "kulesa imaging": true
    "proteomics center": true
    "bioinformatics center": true
    "molecular biology facility": true
    "histology facility": true
    "microscopy center": true
    "reptile & aquatics facility": true
    "tissue culture facility": true
    "laboratory animal services": true
    "president emeritus": true

  importance =
    "robert krumlauf": 2
    "susan abmayar": 2
    "peter baumann": 2
    "marco blanchette": 2
    "joan conaway": 2
    "ronald conaway": 2
    "jennifer gerton": 2
    "matthew gibson": 2
    "r hawley": 2
    "sue jaspersen": 2
    "linheng li": 2
    "rong li": 2
    "ho mak": 2
    "tatjana piotrowski": 2
    "alejandro sanchez": 2
    "ali shilatifard": 2
    "kausik si": 2
    "paul trainor": 2
    "jerry workman": 2
    "ting xie": 2
    "ron yu": 2
    "julia zeitlinger": 2
    "paul kulesa": 2
    "arcady mushegian": 2
    "michael washburn": 2
    "william neaves": 2
    "leanne wiedemann": 2
    "kevin eggan": 2
    "chunying du": 2
    "james coffman": 2
    "brian sauer": 2
    "susan abmayr": 2
    "olivier pourquie": 2
    "chad cowan": 2
            

  d3.select("#generate")
    .on("click", writeDownloadLink)

  w = 960
  h = 900
  r = 6
  stroke_opacity = 0.6
  stroke_width = 0.8
  inner_circle_cutoff = 13
  link_color = "#ddd"

  outer_radius = w / 2
  inner_radius = w / 4

  circle = d3.svg.line.radial()
    .radius( w / 2 )
    .angle( (d) -> d)

  radial_location = (v, rad) ->
    x = ((w / 2) + rad * Math.cos( v * Math.PI / 180))
    y = ((h / 2) + rad * Math.sin( v * Math.PI / 180))
    [x,y]

  spiral_location = (rad, theta) ->
    x = ((w / 2) + rad * Math.cos( v * Math.PI / 180))
    y = ((h / 2) + rad * Math.sin( v * Math.PI / 180))
    [x,y]

  data = null
  center_nodes = {}
  edge_counts = {}
  node = []
  node_group = null
  link = []
  node_links = {}
  force = null
  tick_count = 0

  current_color_type = "group"
  current_show_type = "current"
  current_sort_type = "size"

  fill20 = d3.scale.category20()
  fill_lab = d3.scale.category10()
  fill_dis = d3.scale.category10()

  vis = d3.select("#vis")
    .append("svg")
      .attr("id", "vis-svg")
      .attr("width",w)
      .attr("height", h)

  vis.append("rect")
    .attr("width", w)
    .attr("height", h)
    .attr("fill", "none")
    .attr("pointer-events","all")

  force = d3.layout.force()
    .charge(-20)
    .size([w,h])
    .linkDistance(50)

  setup_bounding_box = (d, i, dom_element) ->
    bBox = dom_element.getBBox()
    box = { "height": bBox.height, "width": bBox.width, "x": bBox.x, "y" : bBox.y}
    box.x = Math.round(box.x) + 0
    box.y = Math.round(box.y) + 0
    box.width = Math.round(box.width)
    box.height = Math.round(box.height)

    personal_links = node_links[d.name_hash]
    if personal_links
      highlight_links personal_links, true

    tooltipWidth = parseInt(d3.select('#tooltip').style('width').split('px').join(''))

    msg = '<table>'
    msg += '<tr><td>' + d["first_name"] + ' ' + d["last_name"] + '</td></tr>'
    msg += '<tr><td>' +  d["group"] + '</td></tr>'
    if personal_links
      msg += '<tr><td>' +  personal_links[0].length + ' connections' + '</td></tr>'
    msg += '</table>'

    d3.select('#tooltip').classed('hidden', false)
    d3.select('#tooltip .content').html(msg)
    d3.select('#tooltip')
      .style('left', box.x + Math.round(box.width / 2) - (tooltipWidth / 2) - 4  + 'px')
      .style('top', box.y + (box.height / 3) + 25  + 'px')

    d3.select('#box')
      .style('left', box.x + 'px')
      .style('top', box.y  + 'px')
      .style('width', box.width + 'px')
      .style('height', box.height + 'px')
      .classed('hidden', false)

  hide_edges = (edges) ->
    edges.attr("stroke-opacity", 0)
      .attr("x1",0)
      .attr("x2",0)
      .attr("y1",0)
      .attr("y2",0)

  color_for = (type, d) =>
    if type == "group"
      fill20(d.group)
    else if type == "function"
      type = if cores[d.group] then "core" else "lab"
      fill_lab(type)
    else if type == "discipline"
      dis = disciplines[d.group] ? "other"
      fill_dis(dis)
    else
      fill20(d.group)

  update_key = (type) =>
    key_data = []

    if type == "group"
      active_groups = []
      if current_show_type == "current"
        active_groups = d3.merge([d3.keys(current_labs), d3.keys(cores)])
      else if current_show_type == "all"
        active_groups = d3.merge([d3.keys(current_labs), d3.keys(old_labs), d3.keys(cores)])
      else if current_show_type == "labs_only"
        active_groups = d3.merge([d3.keys(current_labs)])
      else if current_show_type == "cores_only"
        active_groups = d3.merge([d3.keys(cores)])
      else
        active_groups = d3.merge([d3.keys(current_labs), d3.keys(old_labs), d3.keys(cores)])

      key_data = active_groups.map (d) -> {"group":d, "name":d, "color": fill20(d)}
    else if type == "function"
      key_data = [{"group": "bioinformatics center", "name": "core", "color":fill_lab("core")}, {"group": "lab", "name": "lab", "color":fill_lab("lab")}]
    else if type == "discipline"
      diss = {}
      d3.values(disciplines).forEach (d) -> diss[d] = true
      key_data = d3.keys(diss).map (d) -> {"name": d, "color":fill_dis(d)}
      key_data = d3.merge([key_data, [{"name":"other", "color":fill_dis("other")}]])
    else
      key_data = []

    key_w = 220
    key_h = 30
    key_r = 15

    d3.select("#key").selectAll('.key').remove()

    keys = d3.select("#key").selectAll('.key')
      .data(key_data)
    .enter().append('div')
      .attr('class', 'key')

    keys_vis = keys.append("svg")
      .attr("width", key_w)
      .attr("height", key_h)
    .append("g")
      .attr("transform", "translate(#{key_r},#{key_r})")

    keys_vis.append("circle")
      .attr("r", 5)
      .attr("fill", (d) -> d.color)

    keys_vis.append("text")
      .attr("class", "key_title")
      .text( (d) -> d.name)
      .attr("dy", (key_r / 2) - 3)
      .attr("dx", key_r )

  root.color_nodes = (type) =>
    current_color_type = type
    node.each (d) ->
      d3.select(this)
        .style("fill", (d) -> color_for(current_color_type, d))
    update_key(current_color_type)

  root.show_groups = (type) =>
    setup_nodes(type)
    setup_edges()
    setup_edge_counts()
    current_show_type = type
    root.move_groups(current_sort_type)
    update_key(current_color_type)

  root.move_groups = (type) =>
    current_sort_type = type
    hide_edges(link)
    set_centers type
    tick_count = 0
    force.start()

  root.find_nodes = (search_term) =>
    found_nodes = node.each (d) ->
      match = -1
      if search_term.length > 0
        full_name = d.first_name + ' ' + d.last_name
        match = full_name.toLowerCase().search(new RegExp(search_term.toLowerCase()))
      if match < 0
        d3.select(this)
          .style("fill", (d) -> color_for(current_color_type, d))
          .attr("stroke-width", 0)
          .attr("stroke-opacity", 0.0)
      else
        d3.select(this).style("fill", "#F38630")
          .attr("stroke", "#444")
          .attr("stroke-width", 2.5)
          .attr("stroke-opacity", 1.0)
    
  setup_nodes = (type) =>
    filter_data = data.nodes
    if type == "current"
      filter_data = filter_data.filter (d) -> !old_labs[d["group"]]
    if type == "labs_only"
      filter_data = filter_data.filter (d) -> !old_labs[d["group"]] and !cores[d["group"]]
    if type == "cores_only"
      filter_data = filter_data.filter (d) -> !old_labs[d["group"]] and cores[d["group"]]
    if type == "pi_only"
      filter_data = filter_data.filter (d) ->
        key = d.first_name.toLowerCase() + " " + d.last_name.toLowerCase()
        importance[key] and !old_labs[d["group"]]


    force.nodes(filter_data)

    node = node_group.selectAll("circle.node")
      .data(filter_data, (d) -> d["name_hash"])

      
    node.enter().append("circle")
      .attr("class", "node")
      .attr("cx", (d) -> d.x)
      .attr("cy", (d) -> d.y)
      .attr("r", (d) ->
        key = d.first_name.toLowerCase() + " " + d.last_name.toLowerCase()
        weight = importance[key] ? 1
        5 * weight)
      .style("fill", (d) -> color_for(current_color_type,d))

    node.on "mouseover", (d, i) -> setup_bounding_box(d,i, this)

    node.on "mouseout", (d, i) ->
      d3.select('#tooltip').classed('hidden', true)
      d3.select('#box').classed('hidden', true)
      personal_links = node_links[d.name_hash]
      if personal_links
        highlight_links personal_links, false

    node.exit().remove()

    update_key(current_color_type)

  setup_edges = () =>
    filter_data = data.links.filter (d) ->
      force.nodes().filter((e) -> e.name_hash == d.source)[0] and
        force.nodes().filter((e) -> e.name_hash == d.target)[0]

    link = vis.selectAll("line.link")
      .data(filter_data)

    link.enter().insert("line", ".node_group")
      .attr("class", "link")
      .attr("stroke", link_color)
      .attr("stroke-opacity", 0)
      .attr("stroke-width", stroke_width)

    link.exit().remove()



  setup_edge_counts = () =>
    edge_counts = {}
    node_links = {}
    node.each (d) ->
      node_links[d.name_hash] = vis.selectAll('line.link').filter( (l) -> l.source == d.name_hash || l.target == d.name_hash)
      edge_counts[d.group] ||= 0
      edge_counts[d.group] += node_links[d.name_hash][0].length

  spiral_layout = () =>
    sorted_links = d3.entries(node_links).sort (a,b) ->
      b.value[0].length - a.value[0].length

    sorted_keys = sorted_links.map (d) -> d.key

    rad = 12
    pos = 0
    inc = 8
    rad_inc = 2
    sorted_keys.forEach (key, i) ->
      x_y = radial_location(pos, rad)
      center_nodes[key] = {x: x_y[0], y: x_y[1]}
      pos += inc
      rad_inc = if i > 20 then 2 else 6
      rad += rad_inc

  set_centers = (type) =>
    inner_group = []
    outer_group = []
    center_nodes = {}

    if type == "spiral"
      spiral_layout()
    else if type == "edge"
      sorted_counts = d3.entries(edge_counts).sort (a, b) ->
        b.value - a.value
      # Semi-random values to make it look good.
      inner_count = if sorted_counts.length > 13 then 12 else 6
      # mean = d3.quantile(sorted_counts.map((d) -> d.value), 0.5)
      # inner_group = sorted_counts.filter((d) -> d.value > mean).map (c) -> c.key
      # outer_group = sorted_counts.filter((d) -> d.value <= mean).map (c) -> c.key
      inner_group = sorted_counts.slice(0, inner_count).map (c) -> c.key
      outer_group = sorted_counts.slice(inner_count).map (c) -> c.key
    else if type == "lab_core"
      inner_group = d3.keys(cores)
      outer_group = d3.keys(current_labs)
      if current_show_type == "all"
        outer_group = d3.merge([outer_group, d3.keys(old_labs)])
    else
      groups = {}
      node.each (d) ->
        groups[d.group] ||= 0
        groups[d.group] += 1

      inner_group = d3.keys(groups).filter (key) -> groups[key] > inner_circle_cutoff
      outer_group = d3.keys(groups).filter (key) -> groups[key] <= inner_circle_cutoff

    if type != "spiral"
      inner_pos = -90
      inner_increment = 360 / inner_group.length
      inner_group.forEach (key) ->
        x_y = radial_location(inner_pos, inner_radius)
        center_nodes[key] = {x: x_y[0], y: x_y[1]}
        inner_pos += inner_increment

      outer_pos = -160
      outer_increment = 360 / outer_group.length
      outer_group.forEach (key, i) ->
        x_y = radial_location(outer_pos, outer_radius)
        center_nodes[key] = {x: x_y[0], y: x_y[1]}
        outer_pos +=  outer_increment

  highlight_links = (edges, on_off) ->
    if(on_off)
      edges.attr('stroke', '#F38630')
        .attr("stroke-width", 1.2)
        .attr("stroke-opacity", 0.8)
    else
      edges.attr('stroke', link_color)
        .attr("stroke-width", stroke_width)
        .attr("stroke-opacity", stroke_opacity)

  display_edge_table = (edges, nodes, current_node_index) ->
    titles = '<table id=\'link_table\'><tr><th>Paper</th><th>Connection</th>'
    edges.each (l) ->
      connection_index = if l.source == current_node_index then l.target else l.source
      connection_node = nodes[connection_index]
      titles += '<tr><td>' + l['title'] + '</td>'
      titles += '<td>' + connection_node.first_name + ' ' + connection_node.last_name + '</td></tr>'
    titles += '</table>'
    d3.select('#titles').html(titles)


   # Load JSON
  d3.json "data/links_and_nodes_name_hash.json", (json) ->
    data = json

    node_group = vis.append('g').attr('class', 'node_group')
    setup_nodes(current_show_type)

    setup_edges()

    setup_edge_counts()

    set_centers(current_sort_type)

    add_edges = () ->
      link.attr("stroke-opacity", stroke_opacity)
        .attr("x1", (d) -> force.nodes().filter((e) -> e.name_hash == d.source)[0].x)
        .attr("y1", (d) ->  force.nodes().filter((e) -> e.name_hash == d.source)[0].y)
        .attr("x2", (d) ->  force.nodes().filter((e) -> e.name_hash == d.target)[0].x)
        .attr("y2", (d) ->  force.nodes().filter((e) -> e.name_hash == d.target)[0].y)

    force.start()

    force.on 'tick', (e) ->
      k = e.alpha * .1

      node.each (d,i) ->
       center_node = if current_sort_type != "spiral" then center_nodes[d.group] else center_nodes[d.name_hash]
       if(center_node)
         d.x += (center_node.x - d.x) * k
         d.y += (center_node.y - d.y) * k
         if tick_count % 2 == 0
           d3.select(this).attr('cx',d.x)
           d3.select(this).attr('cy',d.y)

      tick_count += 1

      if (tick_count > 100)
        force.stop()
        add_edges()



