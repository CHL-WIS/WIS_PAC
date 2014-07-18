import numpy as np
import h5py, glob, os, getopt, sys
import read_field_ww3 as rfww3
import wis_h5_out as wh5
#from write_atl_att import write_top_level_att
#from write_atl_att import write_field_attr

class ww3:
    def __init__(self,yearmon,basin,domain,uname):
        self.yearmon = yearmon
        self.uname = uname
        self.domain = domain
        self.varname = {'wavhs':'hs','wavtp':'fp','wavdir':'dir','wavspr':'spr','wavhs_wndsea':'phs_sea','wavtp_wndsea':'ptp_sea','wavdir_wndsea':'pdi_sea','wavhs_swell1':'phs_sw1','wavtp_swell1':'ptp_sw1','wavdir_swell1':'pdi_sw1','wavhs_swell2':'phs_sw2','wavtp_swell2':'ptp_sw2','wavdir_swell2':'pdi_sw2','wnd_u':'wnd','wnd_v':'wnd'}
        basinname = {'pac':'Pacific Ocean','atl':'Atlantic Ocean','gom':'Gulf of Mexico'}
        h5fn = 'wis_' + basin + '_' + domain + '_' + yearmon + '.h5'
        h5file = h5py.File(h5fn,'w')
       # write_top_level_att(h5fname)
        for key in self.varname.keys():
            tt, header, dataf = rfww3.read_fields_ww3('./',self.varname[key],key)
            if 'time' not in h5file.keys():
                self.tt = tt
                self.time2date()
                dataset = h5file.create_dataset('time',(self.pytime.shape),dtype=('f8'))
                dataset[...] = self.pytime
                dataset.attrs['Long Name'] = 'Time in Days since 0001-01-01 00:00:00'
                dataset.attrs['Units'] = 'day'
                dataset.attrs['Dimension'] = self.pytime.shape
                dataset = h5file.create_dataset('datetime',(self.dattime.shape),dtype=('i4'))
                dataset[...] = self.dattime
                dataset.attrs['Long Name'] = 'Time in yyyy,mm,dd,hh,mm,ss'
                dataset.attrs['Units'] = 'year,month,day,hour,minute,second'
                dataset.attrs['Dimension'] = self.dattime.shape

                self.longitude = header['lonw'], header['lone']
                self.latitude = header['lats'], header['latn']
                self.nlon = int(header['ilon'])
                self.nlat = int(header['jlat'])

                self.read_grid()


                dataset = h5file.create_dataset('grid',(self.grd.shape),dtype=('i4'))
                dataset[...] = self.grd
                dataset.attrs['Multiplication Factor'] = 0.001
                dataset.attrs['Long Name'] = 'Water Depth Grid'
                dataset.attrs['Units'] = 'meter'
                dataset.attrs['Dimension'] = self.grd.shape

                dataset = h5file.create_dataset('mask',(self.mask.shape),dtype=('i4'))
                dataset[...] = self.mask
                dataset.attrs['Multiplication Factor'] = 1
                dataset.attrs['Long Name'] = 'Land/Water Mask'
                dataset.attrs['Units'] = 'N/A'
                dataset.attrs['Dimension'] = self.mask.shape

                dataset = h5file.create_dataset('xobstr',(self.xobstr.shape),dtype=('i4'))
                dataset[...] = self.xobstr
                dataset.attrs['Multiplication Factor'] = 0.01
                dataset.attrs['Long Name'] = 'Obstruction Grid X Direction'
                dataset.attrs['Units'] = 'N/A'
                dataset.attrs['Dimension'] = self.xobstr.shape

                dataset = h5file.create_dataset('yobstr',(self.yobstr.shape),dtype=('i4'))
                dataset[...] = self.yobstr
                dataset.attrs['Multiplication Factor'] = 0.01
                dataset.attrs['Long Name'] = 'Obstruction Grid Y Direction'
                dataset.attrs['Units'] = 'N/A'
                dataset.attrs['Dimension'] = self.yobstr.shape

            
            dataset = h5file.create_dataset(key,(dataf.shape),dtype=('i4'))
            dataset[...] = dataf
            dataset.attrs['Dimension'] = dataf.shape
            dataset.attrs['Multiplication Factor'] = header['Mfac']

        wh5.create_field_var_att(h5file,self.varname.keys())
       
        self.lon = np.arange(float(self.longitude[0]),float(self.longitude[1])+self.dlon,self.dlon)
        self.lat = np.arange(float(self.latitude[0]),float(self.latitude[1])+self.dlat,self.dlat)
	self.lon2 = np.linspace(float(self.longitude[0]),float(self.longitude[1]),num=self.nlon)
	self.lat2 = np.linspace(float(self.latitude[0]),float(self.latitude[1]),num=self.nlat)
        dataset = h5file.create_dataset('longitude',(self.lon2.shape),dtype=('f4'))
        dataset[...] = self.lon2
        dataset.attrs['Units'] = 'decimal degree'
        dataset.attrs['Dimension'] = self.lon2.shape
        dataset = h5file.create_dataset('latitude',(self.lat2.shape),dtype=('f4'))
        dataset[...] = self.lat2
        dataset.attrs['Units'] = 'decimal degree'
        dataset.attrs['Dimension'] = self.lat2.shape
        
        info = {'longitude':self.longitude,'latitude':self.latitude,'uname':self.uname,'nlon':self.nlon,'nlat':self.nlat,'domain':self.domain,'basin':basinname[basin]}
        wh5.create_field_global_att(h5file,info)
        h5file.close()
        
        
    def time2date(self):
        import datetime as DT
        self.pytime = np.zeros((self.tt.shape[0],1))
        self.dattime = np.zeros((self.tt.shape[0],6))
        for ii in range(self.tt.shape[0]):
            stdate = str(self.tt[ii][0])
            sttime = str(self.tt[ii][1])
            if len(sttime) == 5:
                dtime = DT.datetime(int(stdate[:4]),int(stdate[4:6]),int(stdate[6:8]),int(sttime[:1]),int(sttime[1:3]),int(sttime[3:5]))
            elif len(sttime) == 1:
                dtime = DT.datetime(int(stdate[:4]),int(stdate[4:6]),int(stdate[6:8]),0,0,0)
            else:
                dtime = DT.datetime(int(stdate[:4]),int(stdate[4:6]),int(stdate[6:8]),int(sttime[:2]),int(sttime[2:4]),int(sttime[4:6]))
            self.pytime[ii] = DT.datetime.toordinal(dtime) + dtime.hour/24. + dtime.minute/(24.*60.) + dtime.second/(3600.*24.)
            self.dattime[ii,:] = dtime.year,dtime.month,dtime.day,dtime.hour,dtime.minute,dtime.second



    def read_grid(self):
        import numpy as np
        import glob 
        ff = open(glob.glob('*.meta')[0])
        for ii in range(11):
            line = ff.readline().split()
        nlon,nlat = ff.readline().split()
        dx,dy,res = ff.readline().split()
        self.dlon = float(dx)/float(res)
        self.dlat = float(dy)/float(res)
        ff.close()
    
        ff = open(glob.glob('*.grd')[0])
        self.grd = np.array(ff.read().split(),dtype='int').reshape(self.nlat,self.nlon)
        ff.close()
        
        ff = open(glob.glob('*.mask')[0])
        self.mask = np.array(ff.read().split(),dtype='int').reshape(self.nlat,self.nlon)
        ff.close()
        
        ff = open(glob.glob('*.obstr')[0])
        a = np.array(ff.read().split(),dtype='int')
        self.xobstr = a[:a.size/2].reshape(self.nlat,self.nlon)
        self.yobstr = a[a.size/2:].reshape(self.nlat,self.nlon)

if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1:],"h",["help"])
    yearmon = args[0]
    basin = args[1]
    domain = args[2]
    uname = args[3]
    ww3(yearmon,basin,domain,uname)

        
