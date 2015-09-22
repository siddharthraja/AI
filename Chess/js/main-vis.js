function createVis(bizId){

var margin = {top: 20, right: 20, bottom: 30, left: 40},
    width = 960 - margin.left - margin.right,
    height = 700 - margin.top - margin.bottom;

var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

var y = d3.scale.linear()
    .rangeRound([height, 0]);

var color = d3.scale.ordinal()
    //.range(["#cb181d", "#fb6a4a", "#fcae91", "#fee5d9", "#ffffb2", "#edf8e9", "#bae4b3", "#74c476", "#238b45"]);
	.range(["#d73027","#f46d43","#fdae61","#fee08b","#ffffbf","#ffffbf","#d9ef8b","#a6d96a","#66bd63","#1a9850"]);

var xAxis = d3.svg.axis()
    .scale(x)
    .orient("bottom");

var yAxis = d3.svg.axis()
    .scale(y)
    .orient("left")
    .tickFormat(d3.format(".2s"));

var svg = d3.select("#VisBody").append("svg")
    .attr("width", width + margin.left + margin.right+ 100)
    .attr("height", height + margin.top + margin.bottom)
  .append("g")
    .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

d3.csv("data/initVis.csv", function(error, data) {

  color.domain(d3.keys(data[0]).filter(function(key) { return key !== "State"; }));

  data.forEach(function(d) {
    var y0 = 0;
    d.ages = color.domain().map(function(name) { return {name: name, y0: y0, y1: y0 += +d[name]}; });
    d.total = d.ages[d.ages.length - 1].y1;
  });


  data.sort(function(a, b) { return b.total - a.total; });

  x.domain(data.map(function(d) { return d.State; }));
  y.domain([0, d3.max(data, function(d) { return d.total; })]);

  svg.append("g")
      .attr("class", "x axis")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

/*   svg.append("g")
      .attr("class", "y axis")
      .call(yAxis)
    .append("text")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", ".71em")
      .style("text-anchor", "end"); */
	  
  var xshift = 0, yshift = 0, xstart = 0, ystart = 0;
	  
  var state = svg.selectAll(".state")
      .data(data)
      .enter().append("g")
      .attr("class", "g")
      .attr("transform", function(d) { if(xstart == 0) xstart = x(d.State); return "translate(" + x(d.State) + ",0)"; });
	  
  //var features = svg.selectAll(".features")

  state.selectAll("rect")
      .data(function(d) { return d.ages; })
	  .enter().append("rect")
      .attr("class", "cell")
      .attr("width", x.rangeBand())
      .attr("y", function(d) { /* if(ystart == 0) ystart = y(d.y1); */ return y(d.y1); })
      .attr("height", function(d) { xshift = x.rangeBand(); yshift = y(d.y0) - y(d.y1); return y(d.y0) - y(d.y1); })
      .style("fill", function(d) { return color(d.name); });

  var legend = svg.selectAll(".legend")
      .data(color.domain().slice().reverse())
      .enter().append("g")
      .attr("class", "legend")
      .attr("transform", function(d, i) { return "translate(0," + i * 20 + ")"; });

  legend.append("rect")
      .attr("x", width + 10)
      .attr("y", 20)
      .attr("width", 18)
      .attr("height", 18)
      .style("fill", color);

  legend.append("text")
      .attr("x", width + 30)
      .attr("y", 30)
      .attr("dy", ".35em")
      //.style("text-anchor", "end")
      .text(function(d) { return d; });
	  
	svg.append("text")
      .attr("class", "title")
      .attr("x", width + 7)
      .attr("y", 7)
      .attr("font-weight", "bold")
      .attr("font-size", "12px")
      .text("Sentiment");
	
/* 	var featureText = "Some Text";
    svg.append("text")
      .attr("class", "featureLabel")
      .attr("x", 7)
      .attr("y", 17)
      .text(featureText)
	  .style("cursor", "pointer")
	  .on("click", function(d) { alert("Hello world"); }); */ 
  
	  plotFeatures(svg, bizId, xshift, xstart, yshift, ystart);
	  
});



// end createVis function
}

function plotFeatures(svg, id, xshift, xstart, yshift, ystart){
	//console.log(xshift + " | " + yshift + " ||| " + xstart + " | " + ystart);

	ystart = 15;
	gridCount = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]];
	if(id!="Blank")
		d3.csv("vis_data/"+id+".csv", function(error, data) {
			
			  var featuresList = {};
			  data.forEach(function(d) {
				if ( !( String(d.keyword) in featuresList ) ) {
					featuresList[String(d.keyword)] = 0;
				}  
			  });
			  data.forEach(function(d) {
				

				//featuresList.push(String(d.keyword)); 
				wrap = 0;
				bkt = Number(d.bucket);
				//if(bkt == 4) bkt = 5;
				gridCount[9-bkt][Number(d.rating)-1] +=  1;
				yf = (9 - parseInt(d.bucket)) * yshift + ystart + (Number(gridCount[9-bkt][Number(d.rating)-1]) * 16);
				xf = (parseInt(d.rating)-1) * (xshift + xstart) + 25;
				if(Number(d.relevance) >= 0.75) {fsize = "16px";wrap=15;}
				else if(Number(d.relevance) >= 0.5) {fsize = "14px";wrap=18;}
					else if(Number(d.relevance) >= 0.25) {fsize = "12px";wrap=35;}
						else fsize = "10px";
				//if (isNaN(yf)) console.log(Number(d.rating)+"|"+bkt+"|"+yf + "|" + gridCount[9-bkt][Number(d.rating)-1]);
				l = d.keyword;
				if(d.keyword.length > wrap){
					l = l.substring(0, wrap)+"...";
				}
				svg.append("text")
				  .attr("class", "featureLabel")
				  .attr("x", xf)
				  .attr("y", yf)
				  .attr("width", "158px")
				  .attr("font-size", fsize) 
				  .text(l)
				  .style("cursor", "pointer")
				  .on("click", function() { listLinking(String(d.keyword)) })
				  .on("mouseover", function() { d3.select(this).style("font-size", "22px") })      
				  .on("mouseout",  function() { d3.select(this).style("font-size", fsize) });
				

				  
			  });

			  listPopulate(featuresList);
		});	
	
	else
			svg.append("text")
			  .attr("class", "featureLabel")
			  .attr("x", 180)
			  .attr("y", 17)
			  .text(id)
			  .style("cursor", "pointer");
	

}

var mainFeatureList = {};
function listPopulate(featuresList){
		
	var count = 0;
	var str = '';
	str += "<h3>Features</h3>";
	str += "<table><tr><td style=\"vertical-align:top;padding-right: 10px;\"><ul>";
	for (var key in featuresList) {	
		count++;
		if(count%20==0){
			str+="</ul></td><td style=\"vertical-align:top;padding-right: 10px;\"><ul>";
		}
		featuresList[key] = count;
		str += "<li><a href=\"#\" onclick=\"recommend('"+key+"');\" id=\"keyword" + featuresList[key] + "\" style=\"font-size:14px;\">"+key+"</a></li>";
	}
	str+="</ul></td></tr></table><br/>";
	document.getElementById('FeatureList').innerHTML = str;
	mainFeatureList = featuresList;
	
}

function listLinking(key){
	
	var count = 0;
	var str = '';
	str += "<h3>Features</h3>";
	str += "<table><tr><td style=\"vertical-align:top;\"><ul>";
	for (var k in mainFeatureList) {	
		count++;
		if(count%20==0){
			str+="</ul></td><td style=\"vertical-align:top;\"><ul>";
		}
		mainFeatureList[k] = count;
		if(k == key)
			str += "<li><a href=\"javascript:recommend('"+k+"');return false;\" id=\"keyword" + mainFeatureList[k] + "\" style=\"font-size:14px;background-color:lightblue;\"><b>"+k+"</b></a></li>";
		else
			str += "<li><a href=\"javascript:recommend('"+k+"');return false;\" id=\"keyword" + mainFeatureList[k] + "\" style=\"font-size:14px;\">"+k+"</a></li>";
	}
	str+="</ul></td></tr></table><br/>";
	document.getElementById('FeatureList').innerHTML = str;
	//$(idstr).css({'background-color':'yellow'});​
	recommend(key);
}