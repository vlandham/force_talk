#!/usr/bin/env python

import urllib
import json
import lxml
import argparse
from lxml import objectify
from lxml.html import fromstring, parse
import os, sys
from utils import write, download

def fetch_votes(session, rootdir):
    #get list of all votes from session from GovTrack
    votes = parse("http://www.govtrack.us/data/us/%s/rolls/" % session)

    for vote in [x for x in votes.xpath("//a/@href") if x[-4:] == ".xml"]:
        chamber = "house" if vote[0] == 'h' else "senate"
        url = "http://www.govtrack.us/data/us/%s/rolls/%s" % (session, vote)
        doc = download(url, session + "/" + vote)
        doc = doc.replace("&", "&amp;")
        try:
            markup = lxml.objectify.fromstring(doc)
        except Exception, e:
            print "Couldn't read", url
            print e
            continue
        data = {}
        data["rollcall"] = {}
        #walk through xml and collect key/value pairs
        for el in markup.getiterator():
            if el.attrib == {}:
                data[el.tag] = el.text
            elif el.tag == 'voter':
                data["rollcall"][el.attrib["id"]] = el.attrib["value"]
        print rootdir + "/data/json/%s/%s/%s.json" % (chamber, session, vote[:-4])
                
        write(json.dumps(data, indent=2), rootdir + "/data/json/%s/%s/%s.json" % (chamber, session, vote[:-4]))
    
    print "done"
    
def main():
    parser = argparse.ArgumentParser(description="Retrieve rollcall votes for a session of Congress")
    parser.add_argument("-s", "--session", metavar="STRING", dest="session", type=str, default='113',
                        help="a session of congress. Default is 113")
    parser.add_argument("-r", "--rootdir", metavar="STRING", dest="rootdir", type=str, default=os.getcwd(),
                        help="root directory for files. Default is os.getcwd()")
    args = parser.parse_args()
    fetch_votes(args.session, args.rootdir)
    
if __name__ == "__main__":
    main()