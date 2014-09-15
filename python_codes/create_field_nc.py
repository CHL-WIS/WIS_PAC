import numpy as np
import h5py, glob, os, getopt, sys
from netCDF4 import Dataset
import read_field_ww3 as rfww3
import wis_nc_out as wnc
#from write_atl_att import write_top_level_att
#from write_atl_att import write_field_attr

class ww3:
    def __init__(self,yearmon,basin,domain):
        self.yearmon = yearmon
        self.domain = domain
        self.complevel = 4
        self.varname = {'wavehs':'hs','wavetp':'fp','wavedir':'dir','wavespr':'spr','wavehs_wndsea':'phs_sea','wavetp_wndsea':'ptp_sea','wavedir_wndsea':'pdi_sea','wavehs_swell1':'phs_sw1','wavetp_swell1':'ptp_sw1','wavedir_swell1':'pdi_sw1','wavehs_swell2':'phs_sw2','wavetp_swell2':'ptp_sw2','wavedir_swell2':'pdi_sw2','wind_u':'wnd','wind_v':'wnd'}
        mmset = ['wavehs','wavetp','wavehs_wndsea','wavetp_wndsea','wavehs_swell1','wavetp_swell1','wavehs_swell2','wavetp_swell2']
        basinname = {'pac':'Pacific Ocean','atl':'Atlantic Ocean','gom':'Gulf of Mexico'}
        ncfn = 'wis_' + basin + '_' + domain + '_' + yearmon + '.nc'
        mmfn = 'wis_' + basin + '_' + domain + '_' + yearmon + '_max_mean.nc'
        ncfile = Dataset(ncfn,'w')
        mmfile = Dataset(mmfn,'w')
       # write_top_level_att(h5fname)
        for key in self.varname.keys():
            tt, header, dataf = rfww3.read_fields_ww3('./',self.varname[key],key)
            if 'time' not in ncfile.variables:
                self.tt = tt
                self.time2date()
                ncfile.createDimension('time',len(self.tt))
                mmfile.createDimension('time',len(self.tt))
                dataset = ncfile.createVariable('time','i8',('time',),zlib=True,complevel=self.complevel)
                dataset[:] = self.pytime
                dataset.long_name = 'Time'
                dataset.units = 'Seconds since 1970-01-01 00:00:00'
                dataset.dimension = self.pytime.shape
                ncfile.createDimension('date',6)
                dataset = ncfile.createVariable('datetime','i4',('time','date',),zlib=True,complevel=self.complevel)
                dataset[:] = self.dattime
                dataset.long_name = 'Time in yyyy,mm,dd,hh,mm,ss'
                dataset.units = 'year,month,day,hour,minute,second'
                dataset.dimension = self.dattime.shape

                dataset = mmfile.createVariable('time','i8',('time',),zlib=True,complevel=self.complevel)
                dataset[:] = self.pytime
                dataset.long_name = 'Time'
                dataset.units = 'Seconds since 1970-01-01 00:00:00'
                dataset.dimension = self.pytime.shape
                mmfile.createDimension('date',6)
                dataset = mmfile.createVariable('datetime','i4',('time','date',),zlib=True,complevel=self.complevel)
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
                mmfile.createDimension('lon',self.nlon)
                mmfile.createDimension('lat',self.nlat)

                dataset = ncfile.createVariable('grid','i4',('lat','lon',),zlib=True,complevel=self.complevel)
                dataset[:] = self.grd
                dataset.mfactor = 0.001
                dataset.long_name = 'Water Depth Grid'
                dataset.units = 'meter'
                dataset.dimension = self.grd.shape

                dataset = ncfile.createVariable('mask','i4',('lat','lon',),zlib=True,complevel=self.complevel)
                dataset[:] = self.mask
                dataset.mfactor = 1
                dataset.long_name = 'Land/Water Mask'
                dataset.units = 'N/A'
                dataset.dimension = self.mask.shape

                dataset = ncfile.createVariable('xobstr','i4',('lat','lon',),zlib=True,complevel=self.complevel)
                dataset[:] = self.xobstr
                dataset.mfactor = 0.01
                dataset.long_name = 'Obstruction Grid X Direction'
                dataset.units = 'N/A'
                dataset.dimension = self.xobstr.shape

                dataset = ncfile.createVariable('yobstr','i4',('lat','lon',),zlib=True,complevel=self.complevel)
                dataset[:] = self.yobstr
                dataset.mfactor = 0.01
                dataset.long_name = 'Obstruction Grid Y Direction'
                dataset.units = 'N/A'
                dataset.dimension = self.yobstr.shape

#                self.lon = np.arange(float(self.longitude[0]),float(self.longitude[1])+self.dlon,self.dlon)
#                self.lat = np.arange(float(self.latitude[0]),float(self.latitude[1])+self.dlat,self.dlat)
                self.lon = np.linspace(float(self.longitude[0]),float(self.longitude[1]),num=self.nlon)
                self.lat = np.linspace(float(self.latitude[0]),float(self.latitude[1]),num=self.nlat)
                dataset = ncfile.createVariable('longitude','f4',('lon',),zlib=True,complevel=self.complevel)
                dataset[:] = self.lon
                dataset.units = 'decimal degree'
                dataset.dimension = self.lon.shape
                lonres = self.lon[1] - self.lon[0]
                dataset = ncfile.createVariable('latitude','f4',('lat',),zlib=True,complevel=self.complevel)
                dataset[:] = self.lat
                dataset.units = 'decimal degree'
                dataset.dimension = self.lat.shape
                latres = self.lat[1] - self.lat[0]

                dataset = mmfile.createVariable('longitude','f4',('lon',),zlib=True,complevel=self.complevel)
                dataset[:] = self.lon
                dataset.units = 'decimal degree'
                dataset.dimension = self.lon.shape
                lonres = self.lon[1] - self.lon[0]
                dataset = mmfile.createVariable('latitude','f4',('lat',),zlib=True,complevel=self.complevel)
                dataset[:] = self.lat
                dataset.units = 'decimal degree'
                dataset.dimension = self.lat.shape
                latres = self.lat[1] - self.lat[0]

  
            if key == 'wind_u':
                print dataf.shape
                self.wndu = np.array(dataf)*float(header['Mfac'])
            elif key == 'wind_v':
                print dataf.shape
                self.wndv = np.array(dataf)*float(header['Mfac'])

            dataset = ncfile.createVariable(key,'i4',('time','lat','lon',),zlib=True,complevel=self.complevel)
            dataset[:] = dataf
            dataset.dimension = dataf.shape
            dataset.mfactor = header['Mfac']
            longn, units = wnc.create_field_var_att(key)
            dataset.long_name = longn
            dataset.units = units

            if key in mmset:
                dmax,dmean = self.max_mean(np.array(dataf)*float(header['Mfac']))
                dataset = mmfile.createVariable(key + '_max','f4',('lat','lon',),zlib=True,complevel=self.complevel)
                dataset[...] = dmax
                dataset = mmfile.createVariable(key + '_mean','f4',('lat','lon',),zlib=True,complevel=self.complevel)
                dataset[...] = dmean
        
        wndspd = self.calc_wndspd()
#       "*****Calculating Windspeed"
        dmax,dmean = self.max_mean(wndspd)
        dataset = mmfile.createVariable('windspd_max','f4',('lat','lon',),zlib=True,complevel=self.complevel)
        dataset[...] = dmax
        dataset = mmfile.createVariable('windspd_mean','f4',('lat','lon',),zlib=True,complevel=self.complevel)
        dataset[...] = dmean
      #  wh5.create_field_var_att(h5file,self.varname.keys())
       
#        self.lon = np.arange(float(self.longitude[0]),float(self.longitude[1])+self.dlon,self.dlon)
#        self.lat = np.arange(float(self.latitude[0]),float(self.latitude[1])+self.dlat,self.dlat)
#	self.lon = np.linspace(float(self.longitude[0]),float(self.longitude[1]),num=self.nlon)
#	self.lat = np.linspace(float(self.latitude[0]),float(self.latitude[1]),num=self.nlat)
#        dataset = ncfile.createVariable('longitude','f4',('lon',))
#        dataset[:] = self.lon
#        dataset.units = 'decimal degree'
#        dataset.dimension = self.lon.shape
#        lonres = self.lon[1] - self.lon[0]
#        dataset = ncfile.createVariable('latitude','f4',('lat',))
#        dataset[:] = self.lat
#        dataset.units = 'decimal degree'
#        dataset.dimension = self.lat.shape
#        latres = self.lat[1] - self.lat[0]
        
        info = {'longitude':self.longitude,'latitude':self.latitude,'nlon':self.nlon,'nlat':self.nlat, \
                    'domain':self.domain,'basin':basinname[basin],'lonres':lonres,'latres':latres, \
                    'timestart':self.timestart,'timeend':self.timeend}
        wnc.create_field_global_att(ncfile,info)
        wnc.create_field_global_att(mmfile,info)
        ncfile.close()
        mmfile.close()
        
        
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
            self.pytime[ii] = int((DT.datetime.toordinal(dtime) - DT.datetime.toordinal(DT.datetime(1970,01,01)) \
                                   + dtime.hour/24. + dtime.minute/(24.*60.) + dtime.second/(3600.*24.))*(24.*3600.))
            self.dattime[ii,:] = dtime.year,dtime.month,dtime.day,dtime.hour,dtime.minute,dtime.second
            self.timestart = dtime
        self.timeend = dtime


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

    def calc_wndspd(self):
        import numpy as np
        wndspd = np.zeros((self.wndu.shape))
 #       wnddir = np.zeros((self.wndu.shape))
        for jlat in range(self.lat.size):
            for ilon in range(self.lon.size):
#                for ttime in range(self.wndu.shape[0]):
                if self.mask[jlat,ilon] == 0 or max(self.wndu[:,jlat,ilon]) < -90.0:
                    wndspd[:,jlat,ilon] = -999.
                else:
                    wndspd[:,jlat,ilon] = np.sqrt(self.wndu[:,jlat,ilon]**2. + self.wndv[:,jlat,ilon]**2.)
 #                       wnddir[ttime,jlat,ilon] = np.arctan(self.wndu[ttime,jlat,ilon],self.wndv[ttime,jlat,ilon])
        return wndspd

    def max_mean(self,dataf):
        import numpy as np
        data = np.array(dataf)
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
                    if self.mask[jlat,ilon] == 0:
                        dmax[jlat,ilon] = -1
                        dmean[jlat,ilon] = -1
                    else:
                      #  print temp.shape
                        dmax[jlat,ilon] = max(temp)
                        dmean[jlat,ilon] = np.mean(temp,0)
        return dmax, dmean

    

if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1:],"h",["help"])
    yearmon = args[0]
    basin = args[1]
    domain = args[2]
    ww3(yearmon,basin,domain)

        
