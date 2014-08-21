import numpy as np

class wave_params:
    def __init__(self,station,longitude,latitude,time,ef2d,freq,direc):
        self.stat = station
        self.ef2d = ef2d
        self.freq = freq
        self.direc = direc
        self.time = time

        self.calc_vars()
        self.calc_wvht()
        self.calc_peak_period()
        self.calc_mean_period()
        self.calc_tm1_tm2()
        self.calc_wave_direction()

        self.data = {'station':self.stat,'longitude':longitude,'latitude':latitude,'time':self.time,'wvht':self.hmo,'tp':self.peakp,'tpp':self.ppp,'tm':self.tmm,'tm1':self.tm1,'tm2':self.tm2,'wavd':self.thq,'wavsp':self.sprd}

    def calc_vars(self):
        self.emin = 1.0e-12
        self.delth = 2*np.pi/len(self.direc)
        self.col1 = np.zeros(len(self.freq))
        self.col1 = 0.5*((self.freq[1:]/self.freq[0:-1])-1.0)*self.delth


        dfim = np.zeros(len(self.freq))
        dfim[0] = self.col1[0]*self.freq[0]
        dfim[1:-1] = self.col1[1:]*(self.freq[1:-1] + self.freq[0:-2])
        dfim[-1:] = self.col1[-1:]*self.freq[-2:-1]
        self.dfim = dfim
        self.dffr = self.dfim*self.freq[:]
        self.dffr2 = self.dfim*self.freq[:]**2
        self.nfrq = self.freq[:].size

        self.emean = np.zeros(self.ef2d.shape[0])
        self.hmo = np.zeros(self.ef2d.shape[0])
        self.peakp = np.zeros(self.ef2d.shape[0])
        self.ppp = np.zeros(self.ef2d.shape[0])
        self.tmm = np.zeros(self.ef2d.shape[0])
        self.tm1 = np.zeros(self.ef2d.shape[0])
        self.tm2 = np.zeros(self.ef2d.shape[0])
        self.thq = np.zeros(self.ef2d.shape[0])
        self.sprd = np.zeros(self.ef2d.shape[0])



    def calc_wvht(self):
         for itime in range(self.ef2d.shape[0]):
            ef2d = self.ef2d[itime,:,:].reshape(29,72)
            temp = ef2d.sum(axis=1)
            etmp = np.dot(temp,self.dfim)
            del25 = 0.25*self.freq[-1:]*self.delth
            etmp = etmp + del25*temp[-1:]
            emin = 1.0e-12
            self.emean[itime] = np.maximum(etmp,self.emin)
            self.hmo[itime] = 4.0*np.sqrt(self.emean[itime])
   

    def calc_peak_period(self):
        for itime in range(self.ef2d.shape[0]):
            ef2d = self.ef2d[itime,:,:].reshape(29,72)
            temp = ef2d.sum(axis=1)
            ed = temp * self.delth
            ipeak = ed.argmax()
            self.peakp[itime] = 1./self.freq[ipeak]
            if ipeak == 1:
                self.peakp[itime] = 1.
                ipeak = self.nfrq

            ppf = self.peakp[itime]
            ipk = ipeak
            ipkp1 = ipk + 1
            ipkm1 = ipk - 1
            freq = self.freq[:]

            if ipk != self.nfrq:
                ppf = freq[ipk]
                eneck = ed[ipkp1] + ed[ipk] + ed[ipkm1]

                if eneck > 1.0e-10:
                    v1 = (freq[ipk] - freq[ipkp1])*(freq[ipkm1] - freq[ipk])
                    v2 = (ed[ipkm1] - ed[ipkp1])*(freq[ipkm1] - freq[ipk])/(freq[ipkm1] - freq[ipkp1])

                    if v2 != 0:
                        a = (ed[ipkm1] - ed[ipk] - v2)/v1
                        b = (ed[ipkm1] - ed[ipkp1])/(freq[ipkm1] - freq[ipkp1]) - a*(freq[ipkm1] + freq[ipkp1])

                        if a != 0:
                            PPF = -0.5*b/a
            self.ppp[itime] = 1./(PPF + (-1.0e-10))



    def calc_mean_period(self):
        for itime in range(self.ef2d.shape[0]):
            ef2d = self.ef2d[itime,:,:].reshape(29,72)
            temp = ef2d.sum(axis=1)
            dfimofr = self.dfim/self.freq[:]
            fmm = np.dot(temp,dfimofr)
            del25 = 0.20*self.delth
            fmm = fmm + del25*temp[-1:]
            fmm = self.emean[itime]/np.maximum(fmm,self.emin)
            self.tmm[itime] = 1.0/fmm


    def calc_tm1_tm2(self):
        for itime in range(self.ef2d.shape[0]):
            ef2d = self.ef2d[itime,:,:].reshape(29,72)
            temp = ef2d.sum(axis=1)
            tmp1 = np.dot(temp,self.dffr)
            tlfr = 1.0/3.0*self.freq[-1:]**2.0*self.delth
            tmp1 = tmp1 + tlfr*temp[-1:]
            tmp1 = np.maximum(tmp1,self.emin)
            if self.emean[itime] > self.emin:
                self.tm1[itime] = self.emean[itime]/tmp1
            else:
                self.tm1[itime]= 1.0

            tmp2 = np.dot(temp,self.dffr2)
            tlfr = 0.5*self.freq[-1:]**3*self.delth
            tmp2 = tmp2 + tlfr*temp[-1:]
            tmp2 = np.maximum(tmp2,self.emin)
            if self.emean[itime] > self.emin:
                self.tm2[itime] = np.sqrt(self.emean[itime]/tmp2)
            else:
                self.tm2[itime] = 1.0


    def calc_wave_direction(self):
        import numpy as np
        ang = self.direc[:]*np.pi/180.0
        for itime in range(self.ef2d.shape[0]):
            ef2d = self.ef2d[itime,:,:].reshape(29,72)     
            sinth = np.sin(ang)
            costh = np.cos(ang)
            temp = np.matrix(ef2d.T) * np.matrix(self.dfim).T
            temp = temp.T
            si = np.dot(temp,sinth)
            ci = np.dot(temp,costh)

            if ci == 0.:
                ci = 0.1e-30
            self.thq[itime] = np.arctan2(si,ci)
            if self.thq[itime] < 0.:
                self.thq[itime] = self.thq[itime] + 2.0*np.pi
            self.thq[itime] = self.thq[itime]*180./np.pi

            sprdtmp = np.sum(temp)
            if np.abs(ci) < 0.1e-15:
                ci = np.sign(0.1e-15,ci)
            if np.abs(si) < 0.1e-15:
                si = np.sign(0.1e-15,si)
            if np.abs(sprdtmp) < 0.1e-15:
                sprdtmp = np.sign(0.1e-15,sprdtmp)
            self.sprd[itime] = 2.0*(1.0 - np.sqrt(si**2 + ci**2)/sprdtmp)
            if self.sprd[itime] <= 0:
                self.sprd[itime] = 1.0e-15
            else:
                self.sprd[itime] = np.sqrt(self.sprd[itime])
            self.sprd[itime] = self.sprd[itime]*180./np.pi


