import wave_param_calc_sep as wp
import wis_h5_out as wh5
import wis_nc_out as wnc
import numpy as np
import getopt, sys, glob

class ww3:

    def __init__(self,yearmon,basin):
        self.yearmon = yearmon
        self.year = yearmon[:4]
        self.mon = yearmon[4:]
#	self.grid = grid
        basinname = {'pac':'Pacific Ocean','atl':'Atlantic Ocean','gom':'Gulf of Mexico'}

        self.read_ww3_spec_netcdf()
#        self.read_ww3_dep_netcdf()
        self.read_ww3_ustar_netcdf()
        self.time2date()
        self.results = []
        # 'datetime':'i4'
        outtype = {'time':'i4','wavehs':'f4','wavetp':'f4','wavetpp':'f4','wavetm':'f4','wavetm1':'f4','wavetm2':'f4', \
                       'wavedir':'f4','wavespr':'f4','frequency':'f4','direction':'f4','ef2d':'f4','windspeed':'f4','winddir':'f4','ustar':'f4', \
                       'cd':'f4','ef2d_swell':'f4','ef2d_wndsea':'f4','wavehs_wndsea':'f4','wavetp_wndsea':'f4','wavetpp_wndsea':'f4', \
                       'wavetm_wndsea':'f4','wavetm1_wndsea':'f4','wavetm2_wndsea':'f4','wavedir_wndsea':'f4','wavespr_wndsea':'f4','wavehs_swell':'f4', \
                       'wavetp_swell':'f4','wavetpp_swell':'f4','wavetm_swell':'f4','wavetm1_swell':'f4','wavetm2_swell':'f4','wavedir_swell':'f4', \
                       'wavespr_swell':'f4'}
        # 'datetime':{0:'time',1:'date'}
        outshape = {'time':'time','wavehs':'time','wavetp':'time','wavetpp':'time', \
                        'wavetm':'time','wavetm1':'time','wavetm2':'time','wavedir':'time','wavespr':'time', \
                        'frequency':'freq','direction':'direc','ef2d':{0:'time',1:'freq',2:'direc'},'windspeed':'time', \
                        'winddir':'time','ustar':'time','cd':'time','ef2d_swell':{0:'time',1:'freq',2:'direc'}, \
                        'ef2d_wndsea':{0:'time',1:'freq',2:'direc'},'wavehs_wndsea':'time','wavetp_wndsea':'time', \
                        'wavetpp_wndsea':'time','wavetm_wndsea':'time','wavetm1_wndsea':'time','wavetm2_wndsea':'time', \
                        'wavedir_wndsea':'time','wavespr_wndsea':'time','wavehs_swell':'time','wavetp_swell':'time', \
                        'wavetpp_swell':'time','wavetm_swell':'time','wavetm1_swell':'time','wavetm2_swell':'time', \
                        'wavedir_swell':'time','wavespr_swell':'time'}
        for ii,stat in self.station.items():
            ef = self.ef2d[:,ii,:,:].reshape(len(self.time),len(self.freq),len(self.direc))
            wavhs = wp.calc_wvht(ef,self.freq,self.direc)
            wavtp,wavtpp = wp.calc_peak_period(ef,self.freq,self.direc)
            wavtm = wp.calc_mean_period(ef,self.freq,self.direc)
            wavtm1,wavtm2 = wp.calc_tm1_tm2(ef,self.freq,self.direc)
            wavdir,wavspr = wp.calc_wave_direction(ef,self.freq,self.direc)

            efswell,efwndsea = wp.calc_windsea_swell(ef,self.freq,self.direc,self.ustar[:,ii],self.wnddir[:,ii])       
     
            wavhs_wndsea = wp.calc_wvht(efwndsea,self.freq,self.direc)
            wavtp_wndsea,wavtpp_wndsea = wp.calc_peak_period(efwndsea,self.freq,self.direc)
            wavtm_wndsea = wp.calc_mean_period(efwndsea,self.freq,self.direc)
            wavtm1_wndsea,wavtm2_wndsea = wp.calc_tm1_tm2(efwndsea,self.freq,self.direc)
            wavdir_wndsea,wavspr_wndsea = wp.calc_wave_direction(efwndsea,self.freq,self.direc)

            wavhs_swell = wp.calc_wvht(efswell,self.freq,self.direc)
            wavtp_swell,wavtpp_swell = wp.calc_peak_period(efswell,self.freq,self.direc)
            wavtm_swell = wp.calc_mean_period(efswell,self.freq,self.direc)
            wavtm1_swell,wavtm2_swell = wp.calc_tm1_tm2(efswell,self.freq,self.direc)
            wavdir_swell,wavspr_swell = wp.calc_wave_direction(efswell,self.freq,self.direc)

            # 'datetime':self.dattime
            data = {'time':self.pytime,'wavehs':wavhs,'wavetp':wavtp,'wavetpp':wavtpp,'wavetm':wavtm,'wavetm1':wavtm1,'wavetm2':wavtm2,'wavedir':wavdir, \
                        'wavespr':wavspr,'frequency':np.array(self.freq),'direction':np.array(self.direc),'ef2d':np.array(ef),'windspeed':self.wndspd[:,ii], \
                        'winddir':self.wnddir[:,ii],'ustar':self.ustar[:,ii],'cd':self.cd[:,ii],'ef2d_swell':efswell,'ef2d_wndsea':efwndsea, \
                        'wavehs_wndsea':wavhs_wndsea,'wavetp_wndsea':wavtp_wndsea,'wavetpp_wndsea':wavtpp_wndsea,'wavetm_wndsea':wavtm_wndsea, \
                        'wavetm1_wndsea':wavtm1_wndsea,'wavetm2_wndsea':wavtm2_wndsea,'wavedir_wndsea':wavdir_wndsea,'wavespr_wndsea':wavspr_wndsea, \
                        'wavehs_swell':wavhs_swell,'wavetp_swell':wavtp_swell,'wavetpp_swell':wavtpp_swell,'wavetm_swell':wavtm_swell, \
                        'wavetm1_swell':wavtm1_swell,'wavetm2_swell':wavtm2_swell,'wavedir_swell':wavdir_swell,'wavespr_swell':wavspr_swell}
            info = {'station':stat,'longitude':self.longitude[ii],'latitude':self.latitude[ii],'outtype':outtype,'depth':self.depth[ii], \
                        'basin':basinname[basin],'outshape':outshape, \
                        'timestart':self.timestart,'timeend':self.timeend,'year':self.year,'month':self.mon}
            dd = {'info':info,'data':data}
            self.results.append(dd)
	
    #        wh5.write_stat_h5(self.results[ii])
            wnc.write_stat_nc(self.results[ii])

    def read_ww3_spec_netcdf(self):
        from netCDF4 import Dataset
        import glob
        fnames = sorted(glob.glob('ww3.*' + self.yearmon + '_spec.nc'))
#        try:
	f = Dataset(fnames[0])
#	except:
#		print "error handling in grid " + self.grid
        self.time = f.variables['time'][:]
        self.freq = f.variables['frequency'][:]
        self.direc = f.variables['direction'][:]
        station = []
        self.longitude = np.zeros((len(fnames)))
        self.latitude = np.zeros((len(fnames)))
        self.depth = np.zeros((len(fnames)))
        self.numstation = len(fnames)
        self.wndspd = np.zeros((self.time.shape[0],self.numstation))
        self.wnddir = np.zeros((self.time.shape[0],self.numstation))
        self.ef2d = np.zeros((self.time.shape[0],len(fnames),self.freq.shape[0],self.direc.shape[0]))
        for ii,fname in enumerate(fnames):
            f = Dataset(fname)
            numstat = f.variables['station_name'].shape[0]
            aa = f.variables['station_name'][0,:]
            stat = ''.join(list(aa[~aa.mask].data))
            station.append(stat)
            self.longitude[ii] = f.variables['longitude'][0,:]
            self.latitude[ii] = f.variables['latitude'][0,:]
            self.ef2d[:,ii,:,:] = f.variables['efth'][:,0,:,:]
            self.wndspd[:,ii] = f.variables['wnd'][:,0]
            self.wnddir[:,ii] = f.variables['wnddir'][:,0]
            self.depth[ii] = f.variables['dpt'][0,0]

        self.station = dict((ii, name) for ii,name in enumerate(station))


    def read_ww3_dep_netcdf(self):
        from netCDF4 import Dataset
        import glob
        fnames = sorted(glob.glob('ww3_dep.*' + self.yearmon + '_tab.nc'))
        self.wndspd = np.zeros((self.time.shape[0],self.numstation))
        self.wnddir = np.zeros((self.time.shape[0],self.numstation))
        self.depth = np.zeros((self.numstation))
        for ii, fname in enumerate(fnames):
            f = Dataset(fname)
            self.wndspd[:,ii] = f.variables['wnd'][:,0]
            self.wnddir[:,ii] = f.variables['wnddir'][:,0]
            self.depth[ii] = f.variables['dpt'][0,0]

    def read_ww3_ustar_netcdf(self):
        from netCDF4 import Dataset
        import glob
        fnames = sorted(glob.glob('ww3_ust.*' + self.yearmon + '_tab.nc'))
        self.ustar = np.zeros((self.time.shape[0],self.numstation))
        self.cd = np.zeros((self.time.shape[0],self.numstation))
        for ii, fname in enumerate(fnames):
            f = Dataset(fname)
            self.ustar[:,ii] = f.variables['ust'][:,0]
            self.cd[:,ii] = f.variables['cd'][:,0]

    def time2date(self):
        import datetime as DT
        import numpy as np
        from netCDF4 import num2date, date2num
      #  self.dttime = []
        self.pytime = np.zeros((self.time.size,1))
        self.dattime = np.zeros((self.time.size,6))
        dayold = 1
        for ii,itime in enumerate(self.time):
         #   print itime, (itime + DT.datetime.toordinal(DT.date(1990,01,01))),(itime + DT.datetime.toordinal(DT.date(1990,01,01))) - DT.datetime.toordinal(DT.datetime(1970,01,01))
            dtime = num2date(itime,units='days since 1990-01-01 00:00:00.0',calendar='gregorian')
            self.pytime[ii] = int(round(date2num(dtime,units='seconds since 1970-01-01 00:00:00.0',calendar='gregorian')))
#            self.pytime[ii] = int(round((itime + DT.datetime.toordinal(DT.date(1990,01,01)) -  \
#                         DT.datetime.toordinal(DT.datetime(1970,01,01)))*(24.*3600.)))
#            if itime < 0:
#                date = DT.datetime.fromordinal(int(itime) + DT.datetime.toordinal(DT.date(1990,01,01)) - 1)
#            else:
#                date = DT.datetime.fromordinal(int(itime) + DT.datetime.toordinal(DT.date(1990,01,01)))
#            t = itime + DT.datetime.toordinal(DT.date(1990,01,01))
#            tt = t - int(t)
#            hour = int(round(tt*24))
#            minu = int(round(tt*24*60) - hour*60)
#            secs = int(round(tt*24*60*60) - hour*3600 - minu*60)
#            time = DT.time(hour, minu, secs)
          #  dtime = DT.datetime.combine(date,time)
#            if hour == 0:
#                date = DT.datetime.fromordinal(int(round(itime)) + DT.datetime.toordinal(DT.date(1990,01,01)))
           #     dtime = DT.datetime(dtime.year,dtime.month,dtime.day+1,dtime.hour,dtime.minute,dtime.second)
           # dayold = dtime.day
#            dtime = DT.datetime.combine(date,time)
            self.dattime[ii,:] = dtime.year,dtime.month,dtime.day,dtime.hour,dtime.minute,dtime.second
            if ii == 0:
                self.timestart = dtime
        self.timeend = dtime

    def _repr_pretty(self):
        """
        display nicely
        """
        mystr="\n"
        max_len=0
        for k in self.__dict__.keys():
            max_len=max(max_len,len(k))
        for k,v in self.__dict__.iteritems():
            whitespace=" "*(max_len-len(k))
            mystr+="\t"+whitespace+k+": "+repr(v)+"\n"
        return mystr
    def __repr__(self):
        return self._repr_pretty()
    @property
    def pretty(self):
        return self._repr_pretty()

if __name__ == "__main__":
    opts, args = getopt.getopt(sys.argv[1:],"h",["help"])
    yearmon = args[0]
    basin = args[1]
#    grid = args[2]
    ww3(yearmon,basin)
