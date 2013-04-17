# Congressional Social Networks

## Quick setup

It's recommended to make a virtualenv, then run:

```bash
pip install -r requirements.txt
```

## Data
All voting information comes from the incomparably awesome GovTrack.us. To prevent unnecessary hammering of GovTrack's API, all cached XML files and the associated JSON files are included in this repository.

If you insist on downloading them yourself, you can do so by running the ```fetch.py``` script:

Information on members comes from the congress-legislators project on the [United States GitHub group)[https://github.com/unitedstates/congress-legislators].
The YAML files from this project were converted to JSON for continuity and indexed by govtrack ID for easy lookup

### fetch.py
Options:
`--session`: Session of Congress for which you want to download votes. Default is 113.
`--rootdir`: Root directory of project. Default is output of ```os.getcwd()```

### analyze.py
Measure the voting co-incidence for every combination of lawmakers.

Options:
`--session`: Session of Congress for which you want to build a voting network. Default is 113.
`--chamber`: Senate or House. Default is Senate.
`--rootdir`: Root directory of project. Default is output of ```os.getcwd()```

## Visualization
This interactive uses d3's force-directed layout to form the network. 