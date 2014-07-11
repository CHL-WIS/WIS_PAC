import numpy as np
import h5py
import glob
#from untar_files import untar_files

def read_fields_ww3(fdir,fext,varname):
    c_dtype = np.dtype([('lonw','f4'),('lone','f4'),('lats','f4'),('latn','f4'),('ilon','i4'),('jlat','i4'),('Mfac','f4')])
    header = np.empty( (1), dtype=c_dtype)
#    tf = glob.glob(fdir + '*' + tgext + '*.tgz')
#    untar_files(tf[0],fdir)
    hsfile = sorted(glob.glob(fdir + 'ww3.*.' + fext))
    input_file = open(hsfile[0],'r')
    line = input_file.readline().split()
    ilon = int(line[6])
    jlat = int(line[9])
    header['lonw'] = float(line[4])
    header['lone'] = float(line[5])
    header['ilon'] = int(line[6])
    header['lats'] = float(line[7])
    header['latn'] = float(line[8])
    header['jlat'] = int(line[9])
    header['Mfac'] = float(line[11])

    dset = np.empty( (len(hsfile),jlat,ilon),dtype='i4')
#    dset = np.empty( (jlat,ilon,len(hsfile)),dtype='i4')

    time = np.empty( (len(hsfile),2),dtype=('i4'))
    input_file.close()
    icount = 0
    n = 1
    if fext == 'wnd':
        n = 2

    for ifile in hsfile:
       input_file = open(ifile,'r')
       line = input_file.readline().split()
       a = np.array(input_file.read().split(),dtype='int')#.reshape((2*jlat,2*ilon))
       if 'tp' in varname:
           iind = np.where(a!=-999)
           a[iind] = 1.0/(a[iind] * header['Mfac']) * 1000
          
       a2 = a[:a.size/n].reshape(jlat,ilon)
       if varname == 'vwnd':
           a2 = a[a.size/n:].reshape(jlat,ilon)

       dset[icount,:,:] = a2
#       dset[:,:,icount] = a2
       time[icount,0] = int(line[2])
       time[icount,1] = int(line[3])
       icount += 1

    return time, header, dset

if __name__ == "__main__":
    read_fields_ww3('/home/thesser1/wis_build_hdf5/test_set1/2010-12/level1/')
