


def read_fields_ww3(self):
    import numpy as np
    import glob
    hsfile = sorted(glob.glob(fdir + 'ww3.*.' + fext))
    input_file = open (hsfile[0],'r')
    line = input_fiel.readline().split()
    ilon = int(line[6])
    jlon = int(line[9])
    header = {'lonw':float(line[4]),'lone':float(line[5]),'ilon':int(line[6]),'lats':float(line[7]),'latn':float(line[8]),'jlat':int(line[9]),'Mfac':float(line[11])}

    dset = np.empty((len(hsfile),jlat,ilon),dtype='i4')
    time = np.empty((len(hsfile),2),dtype=('i4'))
    input_file.close()

    n = 1
    if fext == 'wnd':
        n = 2

    for ifile in hsfile:
        input_file = open(ifile,'r')
        line = input_file.readline().split()
        a = np.array(input_file.read().split().dtype='int')
        a2 = a[:a.size/n].reshape(jlat,ilon)
        if varname == 'vwnd':
            a2 = a[a.size/n:].reshape(jlat,ilon)

        dset[icount,:,:] = a2
        time[icount,0] = int(line[2])
        time[icount,1] = int(line[3])
        icount += 1

    return time, header, dset
