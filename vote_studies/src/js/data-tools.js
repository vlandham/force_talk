//add properties of one object to another if not already present, like a prototype
//override determines whether to overwrite existing key if duplicated in second object

function append_object(o, appendee, override) {
    for (var k in appendee) {
        if (!o.hasOwnProperty(k) || override === true) {
            o[k] = appendee[k];
        }
    }
}

//invert a series of objects
function flip(obj, index) {
    var inv = {};
    for (var o in obj) {
        if (obj.hasOwnProperty(o)) {
            for (var i in obj[o]) {
                if (obj[o].hasOwnProperty(i)) {
                    if (!inv.hasOwnProperty(i)) {
                        inv[i] = {};
                        if (index) {
                            inv[i][index] = i;
                        }
                    }
                    inv[i][o] = obj[o][i];
                }
            }
        }
    }
    return inv;
}

/* Converts csv to object */ 
/* v0.11c */
/* Author: Chris Wilson */

//assumes console fix for IE
//https://raw.github.com/h5bp/html5-boilerplate/master/js/plugins.js

//guess the intrinsic type of a string
'use strict' 
function guess_type(s) {
    if (s.replace(/[0-9\-]+/, "") === "") {
        //int
        return [parseInt(s, 10), "integer"];
    }
    else if (s.replace(/[0-9\.\-]+/, "") === "") {
        //float
        return [parseFloat(s), "float"];
    }
    else if (s.replace(/[0-9\/]+/, "") === "") {
        //date
        //TO DO error handling
        try {
            //d = $.datepicker.parseDate(guess_date_format(s), s);
            //return [d, "date"];
            return [s, "date"];
        }
        catch (e) {}
    }
    return [s, "string"];
}

//infer format from slashes. Very primitive at the moment
function guess_date_format(d) {
    var p = new RegExp(/[0-9]+/ig),
        m = d.match(p),
        format = "";
    if (m.length == 2) { //guessing m/y or m/d
        format = "m";
        if (m[0][0] === "0") {
            format += "m";
        }
        if (parseInt(m[1], 10) > 31) {
            if (m[1].length > 2) {
                return format + "/yy";
            }
            else {
                return format + "/y";
            }
        }
        else {
            return format + "/d";
        }
    }
    else {
        format = "m";
        if (m[0][0] === "0") {
            format += "m";
        }
        format += "/d";
        if (m[1][0] === "0") {
            format += "d";
        }
        if (m[2].length > 2) {
            return format + "/yy";
        }
        else {
            return format + "/y";
        }
    }
}

/* CSV-to-JS Object */
/* Currently does not support quotes */
/* If index is defined, uses as key */
/* TO DO: detect delimitation */

function csv_to_object(csv, delimit, index) {
    var lines = csv.split(/[\r\n]/),
        delimitor = typeof(delimit) !== 'undefined' ? delimit : ",",
        labels = lines[0].split(delimitor),
        types = {},
        samples = lines[1].split(delimitor),
        c,
        i,
        o,
        oo,
        items,
        ind;

    try {
        lines = csv.split(/[\r\n]+/g);
    } catch(e) {
        console.log("Cannot split input into lines");   
    }

    try {
        labels = lines[0].split(delimitor);
    } catch(e) {
        console.log("Couldn't find delimiter in object:", lines[0]);
    }

    try {
        samples = lines[1].split(delimitor);
    } catch(e) {
        console.log("Couldn't find delimiter in object:", lines[1]);        
    }
    
    //record types
    for (c = 0; c < labels.length; c += 1) {
        try {
            types[labels[c]] = guess_type(samples[c])[1];
        } catch(e) {
            console.log("Error in line " + c, labels[c], samples[c]);  
        }
    }

    //if not index was requested, return an array
	if (typeof(index) === 'undefined') {
		o = [];
		for (c = 1; c < lines.length; c += 1) {
			items = lines[c].split(delimitor);
			oo = {};
			for (i = 0; i < items.length; i += 1) {
				oo[labels[i]] = guess_type(items[i])[0];
			}
            //for arrays, this is a little redundant
			oo.object_index = c;
			o.push(oo);
		}
	} else {
		o = {};
		if (typeof(index) === 'number') {
			index = labels[index];
		}

		for (c = 1; c < lines.length; c += 1) {
			items = lines[c].split(delimitor);
			oo = {};
			for (i = 0; i < items.length; i += 1) {
				if (labels[i] === index) {
					ind = guess_type(items[i])[0];
				}
				oo[labels[i]] = guess_type(items[i])[0];
			}
            //add "object_index" with order of objects when an associative array is returned
            oo.object_index = c;			
			o[ind] = oo;
		}
	}

    //if you don't want this metadata, just return o
    return {
        columns: labels,
        types: types,
        object: o
    };
}

function add_commas(number, pfix) {
    var prefix = typeof(pfix) !== 'undefined' ? pfix : '',
		mod, output, i;
	if (number < 0) {
		number *= -1;
		prefix = "-" + prefix;
	}
	number = String(number);
	if (number.length > 3) {
		mod = number.length % 3;
		output = (mod > 0 ? (number.substring(0,mod)) : '');
		for (i=0 ; i < Math.floor(number.length / 3); i += 1) {
			if ((mod === 0) && (i === 0)) {
				output += number.substring(mod+ 3 * i, mod + 3 * i + 3);
			} else {
				output+= ',' + number.substring(mod + 3 * i, mod + 3 * i + 3);
			}
		}
		return (prefix+output);
	}
	return prefix+number;
}