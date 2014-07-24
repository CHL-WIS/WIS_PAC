import wave_param_calc_sep as wp
import wis_h5_out as wh5
import numpy as np
import getopt, sys, glob

class ww3:

    def __init__(self,yearmon,basin,uname):
        self.yearmon = yearmon
        self.uname = uname
        basinname = {'pac':'Pacific Ocean','atl':'Atlantic Ocean','gom':'Gulf of Mexico'}

        self.read_ww3_spec_netcdf()
#        self.read_ww3_dep_netcdf()
        self.read_ww3_ustar_netcdf()
        self.time2date()
        self.results = []
        outtype = {'time':'f8','datetime':'int','wavhs':'f4','wavtp':'f4','wavtpp':'f4','wavtm':'f4','wavtm1':'f4','wavtm2':'f4','wavdir':'f4','wavspr':'f4','frequency':'f4','direction':'f4','ef2d':'f4','wndspd':'f4','wnddir':'f4','ustar':'f4','cd':'f4','ef2d_swell':'f4','ef2d_wndsea':'f4','wavhs_wndsea':'f4','wavtp_wndsea':'f4','wavtpp_wndsea':'f4','wavtm_wndsea':'f4','wavtm1_wndsea':'f4','wavtm2_wndsea':'f4','wavdir_wndsea':'f4','wavspr_wndsea':'f4','wavhs_swell':'f4','wavtp_swell':'f4','wavtpp_swell':'f4','wavtm_swell':'f4','wavtm1_swell':'f4','wavtm2_swell':'f4','wavdir_swell':'f4','wavspr_swell':'f4'}

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


            data = {'time':self.pytime,'datetime':self.dattime,'wavhs':wavhs,'wavtp':wavtp,'wavtpp':wavtpp,'wavtm':wavtm,'wavtm1':wavtm1,'wavtm2':wavtm2,'wavdir':wavdir,'wavspr':wavspr,'frequency':np.array(self.freq),'direction':np.array(self.direc),'ef2d':np.array(ef),'wndspd':self.wndspd[:,ii],'wnddir':self.wnddir[:,ii],'ustar':self.ustar[:,ii],'cd':self.cd[:,ii],'ef2d_swell':efswell,'ef2d_wndsea':efwndsea,'wavhs_wndsea':wavhs_wndsea,'wavtp_wndsea':wavtp_wndsea,'wavtpp_wndsea':wavtpp_wndsea,'wavtm_wndsea':wavtm_wndsea,'wavtm1_wndsea':wavtm1_wndsea,'wavtm2_wndsea':wavtm2_wndsea,'wavdir_wndsea':wavdir_wndsea,'wavspr_wndsea':wavspr_wndsea,'wavhs_swell':wavhs_swell,'wavtp_swell':wavtp_swell,'wavtpp_swell':wavtpp_swell,'wavtm_swell':wavtm_swell,'wavtm1_swell':wavtm1_swell,'wavtm2_swell':wavtm2_swell,'wavdir_swell':wavdir_swell,'wavspr_swell':wavspr_swell}
            info = {'station':stat,'longitude':self.longitude[ii],'latitude':self.latitude[ii],'outtype':outtype,'depth':self.depth[ii],'uname':self.uname,'basin':basinname[basin]}
            dd = {'info':info,'data':data}
            self.results.append(dd)
	
            wh5.write_stat_h5(self.results[ii])

    def read_ww3_spec_netcdf(self):
        from netCDF4 import Dataset
        import glob
        fnames = glob.glob('ww3.*' + self.yearmon + '_spec.nc')
        f = Dataset(fnames[0])
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
        fnames = glob.glob('ww3_dep.*' + self.yearmon + '_tab.nc')
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
        fnames = glob.glob('ww3_ust.*' + self.yearmon + '_tab.nc')
        self.ustar = np.zeros((self.time.shape[0],self.numstation))
        self.cd = np.zeros((self.time.shape[0],self.numstation))
        for ii, fname in enumerate(fnames):
            f = Dataset(fname)
            self.ustar[:,ii] = f.variables['ust'][:,0]
            self.cd[:,ii] = f.variables['cd'][:,0]

    def time2date(self):
        import datetime as DT
        import numpy as np
      #  self.dttime = []
        self.pytime = np.zeros((self.time.size,1))
        self.dattime = np.zeros((self.time.size,6))
        for ii,itime in enumerate(self.time):
            self.pytime[ii] = itime + DT.datetime.toordinal(DT.date(1990,01,01))
            date = DT.datetime.fromordinal(int(itime) + DT.datetime.toordinal(DT.date(1990,01,01)))
            tt = itime - int(itime)
            hour = int(round(tt*24))
            minu = int(round(tt*24*60) - hour*60)
            secs = int(round(tt*24*60*60) - hour*3600 - minu*60)
            time = DT.time(hour, minu, secs)
            dtime = DT.datetime.combine(date,time)
            self.dattime[ii,:] = dtime.year,dtime.month,dtime.day,dtime.hour,dtime.minute,dtime.second


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
    uname = args[2]
    ww3(yearmon,basin,uname)
