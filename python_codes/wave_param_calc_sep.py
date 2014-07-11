
def calc_vars(freq,direc):
    import numpy as np
    emin = 1.0e-12
    delth = 2*np.pi/len(direc)
    col1 = np.zeros(len(freq))
    col1 = 0.5*((freq[1:]/freq[0:-1])-1.0)*delth


    dfim = np.zeros(len(freq))
    dfim[0] = col1[0]*freq[0]
    dfim[1:-1] = col1[1:]*(freq[1:-1] + freq[0:-2])
    dfim[-1:] = col1[-1:]*freq[-2:-1]
    dfim = dfim
    dffr = dfim*freq[:]
    dffr2 = dfim*freq[:]**2
    nfrq = freq[:].size
    ndir = direc[:].size

    return emin, delth, dfim, dffr, dffr2, nfrq, ndir

def calc_emean(ef,freq,direc):
    import numpy as np
    emin,delth,dfim,dffr,dffr2,nfrq,ndir = calc_vars(freq,direc)
    etmp = np.dot(ef,dfim)
    del25 = 0.25*freq[-1:]*delth
    etmp = etmp + del25*ef[-1:]
    emean = np.maximum(etmp,emin)
    return emean

def calc_wvht(ef2d,freq,direc):
    import numpy as np
    emin,delth,dfim,dffr,dffr2,nfrq,ndir = calc_vars(freq,direc)
    hmo = np.zeros(ef2d.shape[0])
    for itime in range(ef2d.shape[0]):
        ef = ef2d[itime,:,:].reshape(nfrq,ndir)
        temp = ef.sum(axis=1)
        emean = calc_emean(temp,freq,direc)
        hmo[itime] = 4.0*np.sqrt(emean)
    return hmo

def calc_peak_period(ef2d,freq,direc):
    import numpy as np
    peakp = np.zeros(ef2d.shape[0])
    ppp = np.zeros(ef2d.shape[0])
    emin,delth,dfim,dffr,dffr2,nfrq,ndir = calc_vars(freq,direc)
    for itime in range(ef2d.shape[0]):
        ef = ef2d[itime,:,:].reshape(nfrq,ndir)
        temp = ef.sum(axis=1)
        ed = temp * delth
        ipeak = ed.argmax()
        peakp[itime] = 1./freq[ipeak]
        if ipeak == 0:
            peakp[itime] = 1.
            ipeak = nfrq-1

        ppf = peakp[itime]
        ipk = ipeak
        ipkp1 = ipk + 1
        ipkm1 = ipk - 1
        freq = freq[:]

	if ipk != nfrq-1:
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
                        ppp[itime] = 1./(PPF + (-1.0e-10))

    return peakp, ppp

def calc_mean_period(ef2d,freq,direc):
    import numpy as np
    tmm = np.zeros(ef2d.shape[0])
    emin,delth,dfim,dffr,dffr2,nfrq,ndir = calc_vars(freq,direc)
    for itime in range(ef2d.shape[0]):
        ef = ef2d[itime,:,:].reshape(nfrq,ndir)
        temp = ef.sum(axis=1)
        dfimofr = dfim/freq[:]
        fmm = np.dot(temp,dfimofr)
        del25 = 0.20*delth
        fmm = fmm + del25*temp[-1:]
        emean = calc_emean(temp,freq,direc)
        fmm = emean/np.maximum(fmm,emin)
        tmm[itime] = 1.0/fmm
    return tmm


def calc_tm1_tm2(ef2d,freq,direc):
    import numpy as np
    tm1 = np.zeros(ef2d.shape[0])
    tm2 = np.zeros(ef2d.shape[0])
    emin,delth,dfim,dffr,dffr2,nfrq,ndir = calc_vars(freq,direc)
    for itime in range(ef2d.shape[0]):
        ef = ef2d[itime,:,:].reshape(nfrq,ndir)
        temp = ef.sum(axis=1)
        tmp1 = np.dot(temp,dffr)
        tlfr = 1.0/3.0*freq[-1:]**2.0*delth
        tmp1 = tmp1 + tlfr*temp[-1:]
        tmp1 = np.maximum(tmp1,emin)
        emean = calc_emean(temp,freq,direc)
        if emean > emin:
            tm1[itime] = emean/tmp1
        else:
            tm1[itime]= 1.0

        tmp2 = np.dot(temp,dffr2)
        tlfr = 0.5*freq[-1:]**3*delth
        tmp2 = tmp2 + tlfr*temp[-1:]
        tmp2 = np.maximum(tmp2,emin)
        if emean > emin:
            tm2[itime] = np.sqrt(emean/tmp2)
        else:
            tm2[itime] = 1.0
    return tm1, tm2

def calc_wave_direction(ef2d,freq,direc):
    import numpy as np
    thq = np.zeros(ef2d.shape[0])
    sprd = np.zeros(ef2d.shape[0])
    emin,delth,dfim,dffr,dffr2,nfrq,ndir = calc_vars(freq,direc)
    ang = direc[:]*np.pi/180.0
    for itime in range(ef2d.shape[0]):
        ef = ef2d[itime,:,:].reshape(nfrq,ndir)     
        sinth = np.sin(ang)
        costh = np.cos(ang)
        temp = np.matrix(ef.T) * np.matrix(dfim).T
        temp = temp.T
        si = np.dot(temp,sinth)
        ci = np.dot(temp,costh)

        if ci == 0.:
            ci = np.array(0.1e-30)
        thq[itime] = np.arctan2(si,ci)
        if thq[itime] < 0.:
            thq[itime] = thq[itime] + 2.0*np.pi
        thq[itime] = thq[itime]*180./np.pi

        sprdtmp = np.array(np.sum(temp))
        if np.abs(ci) < 0.1e-15:
            ci = np.sign(0.1e-15,ci)
        if np.abs(si) < 0.1e-15:
            si = np.sign(0.1e-15,si)
        if np.abs(sprdtmp) < 0.1e-15:
            sprdtmp = np.sign(0.1e-15,sprdtmp)
        sprd[itime] = 2.0*(1.0 - np.sqrt(si**2 + ci**2)/sprdtmp)
        if sprd[itime] <= 0:
            sprd[itime] = 1.0e-15
        else:
            sprd[itime] = np.sqrt(sprd[itime])
        sprd[itime] = sprd[itime]*180./np.pi
    return thq, sprd

def calc_windsea_swell(ef2d,freq,direc,ustar,winddir):
    import numpy as np
    cc = np.zeros(freq.shape)
    cc = 9.81/(2.*np.pi*freq)
    wavd = direc * np.pi/180.

    efswell = np.zeros(ef2d.shape)
    efwndsea = np.zeros(ef2d.shape)
    for itime in range(ef2d.shape[0]):
        wd = winddir[itime] - 180.
        if wd < 0.:
            wd = wd + 360.
        wd = wd * np.pi/180.
        for ifreq in range(freq.size):
            cm = 28./cc[ifreq]
            for idir in range(wavd.shape[0]):
                sis = 1.2*ustar[itime]*np.cos(wavd[idir] - wd)
                if cm*sis < 1.0:
                    efswell[itime,ifreq,idir] = ef2d[itime,ifreq,idir]
                else:
                    efwndsea[itime,ifreq,idir] = ef2d[itime,ifreq,idir]

    return efswell, efwndsea
