import numpy as np
import h5py, glob, os, getopt, sys
from netCDF4 import Dataset
import read_field_ww3 as rfww3
import wis_nc_out as wnc
#from write_atl_att import write_top_level_att
#from write_atl_att import write_field_attr

class ww3:
    def __init__(self,yearmon,basin,domain,uname):
        self.yearmon = yearmon
        self.uname = uname
        self.domain = domain
        self.varname = {'wavhs':'hs','wavtp':'fp','wavdir':'dir','wavspr':'spr','wavhs_wndsea':'phs_sea','wavtp_wndsea':'ptp_sea','wavdir_wndsea':'pdi_sea','wavhs_swell1':'phs_sw1','wavtp_swell1':'ptp_sw1','wavdir_swell1':'pdi_sw1','wavhs_swell2':'phs_sw2','wavtp_swell2':'ptp_sw2','wavdir_swell2':'pdi_sw2','wnd_u':'wnd','wnd_v':'wnd'}
        basinname = {'pac':'Pacific Ocean','atl':'Atlantic Ocean','gom':'Gulf of Mexico'}
        ncfn = 'wis_' + basin + '_' + domain + '_' + yearmon + '.nc'
        ncfile = Dataset(ncfn,'w')
       # write_top_level_att(h5fname)
        for key in self.varname.keys():
            tt, header, dataf = rfww3.read_fields_ww3('./',self.varname[key],key)
            if 'time' not in ncfile.variables:
                self.tt = tt
                self.time2date()
                ncfile.createDimension('time',len(self.tt))
                dataset = ncfile.createVariable('time','f8',('time',))
                dataset[:] = self.pytime
                dataset.long_name = 'Time in Days since 0001-01-01 00:00:00'
                dataset.units = 'day'
                dataset.dimension = self.pytime.shape
                ncfile.createDimension('date',6)
                dataset = ncfile.createVariable('datetime','i4',('time','date',))
                dataset[:] = self.dattime
                dataset.long_name = 'Time in yyyy,mm,dd,hh,mm,ss'
                dataset.units = 'year,month,day,hour,minute,second'
                dataset.dimension = self.dattime.shape

                self.longitude = header['lonw'], header['lone']
                self.latitude = header['lats'], header['latn']
                self.nlon = int(header['ilon'])
                self.nlat = int(header['jlat'])

                self.read_grid()

                ncfile.createDimension('lon',self.nlon)
                ncfile.createDimension('lat',self.nlat)

                dataset = ncfile.createVariable('grid','i4',('lat','lon',))
                dataset[:] = self.grd
                dataset.mfactor = 0.001
                dataset.long_name = 'Water Depth Grid'
                dataset.units = 'meter'
                dataset.dimension = self.grd.shape

                dataset = ncfile.createVariable('mask','i4',('lat','lon',))
                dataset[:] = self.mask
                dataset.mfactor = 1
                dataset.long_name = 'Land/Water Mask'
                dataset.units = 'N/A'
                dataset.dimension = self.mask.shape

                dataset = ncfile.createVariable('xobstr','i4',('lat','lon',))
                dataset[:] = self.xobstr
                dataset.mfactor = 0.01
                dataset.long_name = 'Obstruction Grid X Direction'
                dataset.units = 'N/A'
                dataset.dimension = self.xobstr.shape

                dataset = ncfile.createVariable('yobstr','i4',('lat','lon',))
                dataset[:] = self.yobstr
                dataset.mfactor = 0.01
                dataset.long_name = 'Obstruction Grid Y Direction'
                dataset.units = 'N/A'
                dataset.dimension = self.yobstr.shape


            print key
            dataset = ncfile.createVariable(key,'i4',('time','lat','lon',))
            dataset[:] = dataf
            dataset.dimension = dataf.shape
            dataset.mfactor = header['Mfac']

#            dmax,dmean = max_mean(dataf)
#            dataset = h5file.create_dataset(key + '_max',(dmax.shape),dtype=('f4'))
#            dataset[...] = dmax
#            dataset = h5file.create_dataset(key + '_mean',(dmean.shape),dtype='f4'))

      #  wh5.create_field_var_att(h5file,self.varname.keys())
       
        self.lon = np.arange(float(self.longitude[0]),float(self.longitude[1])+self.dlon,self.dlon)
        self.lat = np.arange(float(self.latitude[0]),float(self.latitude[1])+self.dlat,self.dlat)
	self.lon2 = np.linspace(float(self.longitude[0]),float(self.longitude[1]),num=self.nlon)
	self.lat2 = np.linspace(float(self.latitude[0]),float(self.latitude[1]),num=self.nlat)
        dataset = ncfile.createVariable('longitude','f4',('lon',))
        dataset[:] = self.lon2
        dataset.units = 'decimal degree'
        dataset.dimension = self.lon2.shape
        dataset = ncfile.createVariable('latitude','f4',('lat',))
        dataset[:] = self.lat2
        dataset.units = 'decimal degree'
        dataset.dimension = self.lat2.shape
        
        info = {'longitude':self.longitude,'latitude':self.latitude,'uname':self.uname,'nlon':self.nlon,'nlat':self.nlat,'domain':self.domain,'basin':basinname[basin]}
      #  wh5.create_field_global_att(h5file,info)
        ncfile.close()
        
        
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

    def max_mean(self,dataf,mfac):
        import numpy as np
        data = np.array(dataf)*mfac
        dmax = np.zeros((self.mask.shape))
        dmean = np.zeros((self.mask.shape))

        for jlat in range(self.lat.shape[0]):
            for ilon in range(self.lon.shape[0]):
                idx = data[:,jlat,ilon] >= 0
                temp = data[idx,jlat,ilon]
                if not temp.any():
                    if self.mask[jlat,ilon] == 0:
                        dmax[jlat,ilon] = -1
                        dmean[jlat,ilon] = -1
                    else:
                        dmax[jlat,ilon] = 0
                        dmean[jlat,ilon] = 0
                else:
                    dmax[jlat,ilon] = np.max(temp)
                    dmean[jlat,ilon] = np.mean(temp)
        return dmax, dmean

if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1:],"h",["help"])
    yearmon = args[0]
    basin = args[1]
    domain = args[2]
    uname = args[3]
    ww3(yearmon,basin,domain,uname)

        
