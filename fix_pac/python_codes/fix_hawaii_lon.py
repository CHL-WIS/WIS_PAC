from netCDF4 import Dataset
import getopt, sys

def fix_hawaii_lon(fname,lon):
    f = Dataset(fname,'r+')
    f.geospatial_lon = lon
    f.close()

if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1:],"h",["help"])
    fname = args[0]
    lon = args[1]
    fix_hawaii_lon(fname,lon)
