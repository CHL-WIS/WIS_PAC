from netCDF4 import Dataset
import getopt, sys 

def fix_nc_stat(fname,stat):
    f = Dataset(fname,'r+')
    f.station = stat
    f.close()

if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1:],"h",["help"])
    fname = args[0]
    stat = args[1]
    fix_nc_stat(fname,stat)
