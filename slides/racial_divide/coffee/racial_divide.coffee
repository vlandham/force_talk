root = exports ? this

root.showCity = (cityId) ->
  cities = {
    "kc": {id:"kc", name:"kc", x:-350, y:600, scale:16000},
    "mw": {id:"mw", name:"milwaukee", display:"Milwaukee, WI", x:-3300, y:3150, scale:30000},
    "ch": {id:"ch", name:"chicago", x:-2600, y:2050, scale:23000},
    "dy": {id:"dy", name:"dayton", x:-3600, y:1250, scale:22000},
    "co": {id:"co", name:"columbus", x:-4500, y:1600, scale:25000},
    "pt": {id:"pt", name:"pittsburgh", x:-4800, y:1700, scale:22000},
    "sy": {id:"sy", name:"syracuse", x:-5100, y:2700, scale:20000},
    "sl": {id:"sl", name:"st_louis", x:-1650, y:600, scale:20000},
    "dn": {id:"dn", name:"denver", x:2300, y:1000, scale:20000},
    "oc": {id:"oc", name:"ok_city", x:280, y:-600, scale:20000}
    "wc": {id:"wc", name:"wichita", x:200, y:200, scale:20000}
  }

  data = cities[cityId]

  if window.city_view
    window.city_view.remove_vis()
    window.city_view = null

  window.city_view = new CityView data.name, data.x, data.y, data.scale
  window.city_view.display_city()

tract_ratio = (tract) ->
  if parseFloat(tract.P003001) > 20
    parseFloat(tract.P003003) / parseFloat(tract.P003001)
  else
    0

difference_between = (tract_a, tract_b) ->
  ratio_a = tract_ratio(tract_a)
  ratio_b = tract_ratio(tract_b)
  Math.abs(ratio_b - ratio_a)

edge = (a, b) ->
  dx = (a.x - b.x)
  dy = (a.y - b.y)
  diff = difference_between(a.tract_data, b.tract_data) * 100
  distance = Math.sqrt(dx * dx + dy * dy) + diff
  #distance = Math.sqrt(dx * dx + dy * dy)
  e = {source: a, target:b, distance: distance }
  e

class CityView
  constructor: (@name, @x, @y, @scale) ->
    @width = 1000
    @height = 620
    @csv_data = {}
    @color = null
    @all_node = []
    @xy = null
    @path = null
    @centered = null

    @vis = d3.select("#vis")
      .append("svg:svg")
      .attr("id", "vis-svg")
      .attr("width", @width)
      .attr("height", @height)

    @vis.append("svg:rect")
      .attr("width", @width)
      .attr("height", @height)
    @vis = @vis.append("svg:g")
  setup_data: (csv) =>
    for tract in csv
      @csv_data[tract.GEOID] = tract

    max_pop = d3.max(csv, (d) -> tract_ratio(d))
    min_pop = d3.min(csv, (d) -> tract_ratio(d))
    @color = d3.scale.linear().range(["#F5F5F5", "#303030"]).domain([min_pop, max_pop])

  remove_vis: () =>
    @force.stop()
    d3.select("#vis-svg")
      #.transition()
      #.duration(500)
      #.attr("opacity", 0.0)
      .remove()

  color_for: (data) =>
    @color(tract_ratio(data))

  start: () =>
    # d3.transition().delay(1500).each("end",() => @force.start())
    @force.start()

  zoom: (id) =>
    k = 1
    x = @width / 2
    y = @height / 2
    if id
      k = 5
      zoom_node = @all_node.filter (d) ->
        d.tract_data['GEOID'] == id

      # zoom_node.attr('fill', 'red')
      my_path = @path
      zoom_node.each (d) ->
        x = d.x
        y = d.y
        @centered = d

    @vis.transition()
      .duration(1000)
      .attr("transform", "translate(#{@width/2}, #{@height/2})scale(#{k})translate(#{-x},#{-y})")





    # zoomer = @csv_data[id]
    # if zoomer
    #   console.log(zoomer)
    # else
    #   console.log("cant find #{id}")


  display_city: () ->
    @xy = d3.geo.albersUsa()
      .translate([@x,@y]).scale(@scale)
    @path = d3.geo.path().projection(@xy)
    @force = d3.layout.force().size([@width, @height])

    d3.csv "data/cities/#{@name}_race.csv", (csv) =>
      @setup_data(csv)
      d3.json "data/cities/#{@name}_tracts.json", (tracts) =>
        nodes = []
        links = []

        tracts.features.forEach (d, i) =>
          centroid = @path.centroid(d)
          centroid.x = centroid[0]
          centroid.y = centroid[1]
          centroid.feature = d
          centroid.tract_data = @csv_data[d.properties["GEOID10"]]
          nodes.push centroid

        d3.geom.delaunay(nodes).forEach (d) =>
          links.push(edge(d[0], d[1]))
          links.push(edge(d[1], d[2]))
          links.push(edge(d[2], d[0]))

        @force
          .gravity(0.0)
          .nodes(nodes)
          .links(links)
          .linkDistance( (d) -> d.distance)
          .charge(-0.6)
          .friction(0.4)
          .theta(0.9)

        # link = @vis.selectAll("line")
        #   .data(links)
        # .enter().append("svg:line")
        #   .attr("x1", (d) -> d.source.x)
        #   .attr("y1", (d) -> d.source.y)
        #   .attr("x2", (d) -> d.target.x)
        #   .attr("y2", (d) -> d.target.y)
        #   .attr("stroke", "#333")
        #   .attr("stroke-width", "0")
        #   .attr("stroke-opacity", 0.0)
        my_path = @path
        @all_node = @vis.selectAll("g")
          .data(nodes)
        .enter().append("svg:g")
          .attr("transform", (d) -> "translate(#{-d.x},#{-d.y})")
        .append("svg:path")
          .attr("transform", (d) -> "translate(#{-d.x},#{-d.y})")
          .attr("d", (d) -> my_path(d.feature))
          .attr("fill-opacity", 0.0)
          .attr("fill", (d) => @color_for(d.tract_data))
          .attr("stroke", "#222")
          .attr("stroke-width", 0)
          .attr("stroke-opacity", 0.0)

        @all_node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")

        @all_node.transition()
          .duration(1000)
          .attr("fill-opacity", 1.0)
        
        tick_count = 0

        @force.on "tick", (e) =>
          # link.attr("x1", (d) -> d.source.x)
          #   .attr("y1", (d) -> d.source.y)
          #   .attr("x2", (d) -> d.target.x)
          #   .attr("y2", (d) -> d.target.y)
          @all_node.attr("transform", (d) -> "translate(#{d.x},#{d.y})")
          tick_count += 1
          if tick_count > 150
            @force.stop()

hashChange = () ->
  cityId = decodeURIComponent(location.hash.substring(1)).trim()
  if(cityId.length == 0)
    cityId = 'kc'
  $('#cities a').removeClass("active")
  $('#' + cityId).toggleClass("active")
  root.showCity(cityId)

$ ->
  d3.select(window).on('hashchange', hashChange)

  d3.selectAll('#cities a').on 'click', (e) ->
    cityId = $(this).attr("id")
    location.replace('#' + encodeURIComponent(cityId))
    d3.event.preventDefault()

  d3.select(window).on('hashchange', hashChange)

  hashChange()

  root.step = (cur_step) ->
    if cur_step == 'start'
      window.city_view.start()
    if cur_step == 'zoom_first'
      # console.log('zoom')
      # window.city_view.zoom("29095007500")
      # window.city_view.zoom("29095006300")
      # window.city_view.zoom("29095006500")
      # window.city_view.zoom("29095006600")
      # window.city_view.zoom("29095006700")
      # window.city_view.zoom("29095007400")
      # window.city_view.zoom("29095007500")
      # window.city_view.zoom("29095008000")
      # window.city_view.zoom("29095008200")
      # window.city_view.zoom("29095008600")
      # window.city_view.zoom("29095016900")
      window.city_view.zoom("20209043301")
    if cur_step == 'zoom_op'
      window.city_view.zoom("20091051902")
    if cur_step == 'zoom_current'
      window.city_view.zoom("29095008100")
      # window.city_view.zoom("29095006500")
    if cur_step == 'zoom_out'
      window.city_view.zoom(null)

  
