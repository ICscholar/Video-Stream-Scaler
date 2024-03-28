import json
import math
import os
from pathlib import Path, WindowsPath

with open("ddr3_parameters.json","r") as file:
    data = json.load(file)

vhFile = open("ddr3_controller.vh","w") 
memFile = open("ddr3_controller.bin","w")


parameters = data['memory'][0]
mr0 = parameters['mr0'][0]
mr1 = parameters['mr1'][0]
mr2 = parameters['mr2'][0]
mr3 = parameters['mr3'][0]
timing = parameters['timing'][0]
arbiter = parameters['arbiter'][0]

mr0_val =0
mr1_val =0
mr2_val =0
mr3_val =0

sim = parameters['simulation']
data_width = parameters['data_width']
freq = parameters['freq']
row = parameters['row']
col = parameters['col']
bank = parameters['bank']
rank = parameters['rank']

tCL = timing['tCL']
tWR = timing['tWR']
tAL = timing['tAL']
tCWL =timing['tCWL']
tREFI =timing['tREFI']

tRL = tCL +tAL
tWL = tCWL +tAL
us = freq
cycle_ns = 1000/freq



if mr0['burst_length'] == 8   :mr0_val |= 0x0
elif mr0['burst_length'] == 4 :mr0_val |= 0x2
else                          :mr0_val |= 0x0

if mr0['read_burst_type'] == 'sequential'       :mr0_val |= 0x0
elif mr0['read_burst_type'] == 'interleaved'    :mr0_val |= 0x8
else                                            :mr0_val |= 0x0

if mr0['cas_latency'] == 5   : mr0_val |= 0x10
elif mr0['cas_latency'] == 6 : mr0_val |= 0x20
elif mr0['cas_latency'] == 7 : mr0_val |= 0x30
elif mr0['cas_latency'] == 8 : mr0_val |= 0x40
elif mr0['cas_latency'] == 9 : mr0_val |= 0x50
elif mr0['cas_latency'] == 10: mr0_val |= 0x60
elif mr0['cas_latency'] == 11: mr0_val |= 0x70
elif mr0['cas_latency'] == 12: mr0_val |= 0x04
elif mr0['cas_latency'] == 13: mr0_val |= 0x14
elif mr0['cas_latency'] == 14: mr0_val |= 0x24
else                         : mr0_val |= 0x10


if mr0['dll_reset'] == 'yes'    : mr0_val |= 0x100
elif mr0['dll_reset'] == 'no'   : mr0_val |= 0x000
else                            : mr0_val |= 0x100

if mr0['write_recovery'] == 5    : mr0_val |= 0x200
elif mr0['write_recovery'] == 6  : mr0_val |= 0x400
elif mr0['write_recovery'] == 7  : mr0_val |= 0x600
elif mr0['write_recovery'] == 8  : mr0_val |= 0x800
elif mr0['write_recovery'] == 10 : mr0_val |= 0xA00
elif mr0['write_recovery'] == 12 : mr0_val |= 0xC00
elif mr0['write_recovery'] == 14 : mr0_val |= 0xE00
elif mr0['write_recovery'] == 16 : mr0_val |= 0x000
else                                : mr0_val |= 0x000


if mr0['precharge_pd'] == 'on'       : mr0_val |= 0x1000
elif mr0['precharge_pd'] == 'off'    : mr0_val |= 0x0000
else                                 : mr0_val |= 0x1000 


if mr1['dll_enable'] :   mr1_val |= 0x0000
else                 :   mr1_val |= 0x0001

if mr1['output_drive_strength'] == 'rzq/6'  : mr1_val |= 0x0000
elif mr1['output_drive_strength'] == 'rzq/7': mr1_val |= 0x0002
else                                        : mr1_val |= 0x0000


if mr1['al'] == 'disable': mr1_val |= 0x0000
elif mr1['al'] == 'cl-1' : mr1_val |= 0x0008
elif mr1['al'] == 'cl-2' : mr1_val |= 0x0010
else                     : mr1_val |= 0x0000

if mr1['write_leveling'] == 'disable'   : mr1_val |= 0x0000
elif mr1['write_leveling'] == 'ensable' : mr1_val |= 0x0080
else                                    : mr1_val |= 0x0000


if mr1['rtt'] == 'dsiable'  : mr1_val |= 0x0000
elif mr1['rtt'] == 'rzq/4'  : mr1_val |= 0x0004
elif mr1['rtt'] == 'rzq/2'  : mr1_val |= 0x0040
elif mr1['rtt'] == 'rzq/6'  : mr1_val |= 0x0044
elif mr1['rtt'] == 'rzq/12' : mr1_val |= 0x0200
elif mr1['rtt'] == 'rzq/8'  : mr1_val |= 0x0204
else                        : mr1_val |= 0x0044

if mr1['tdqs'] == 'disable'     : mr1_val |= 0x0000
elif mr1['tdqs'] == 'enable'    : mr1_val |= 0x0800
else                            : mr1_val |= 0x0000

if mr1['qoff'] == 'enable'      :mr1_val |= 0x0000
elif mr1['qoff'] == 'disable'   :mr1_val |= 0x1000

if mr2['cwl'] == 5      : mr2_val |= 0x0000
elif mr2['cwl'] == 6    : mr2_val |= 0x0008
elif mr2['cwl'] == 7    : mr2_val |= 0x0010
elif mr2['cwl'] == 8    : mr2_val |= 0x0018
elif mr2['cwl'] == 9    : mr2_val |= 0x0020
elif mr2['cwl'] == 10   : mr2_val |= 0x0028
else                    : mr2_val |= 0x0000

if mr2['asr'] == 'disable'  : mr2_val |= 0x0000
elif mr2['asr'] == 'enable' : mr2_val |= 0x0040
else                        : mr2_val |= 0x0000

if mr2['srt'] == 'normal'       : mr2_val |= 0x0000
elif mr2['srt'] == 'extended'   : mr2_val |= 0x0080
else                            : mr2_val |= 0x0000

if mr2['dynamic_odt'] == 'disable'  : mr2_val |= 0x0000
elif mr2['dynamic_odt'] == 'rzq/4'  : mr2_val |= 0x0200
elif mr2['dynamic_odt'] == 'rzq/2'  : mr2_val |= 0x0400
else                                : mr2_val |= 0x0000

if mr3['mpr'] == 'normal'           :mr3_val |= 0x0000
elif mr3['mpr'] == 'enable'         :mr3_val |= 0x0004
else                                :mr3_val |= 0x0000


print(hex(mr0_val))
print(hex(mr1_val))
print(hex(mr2_val))
print(hex(mr3_val))

class pin_loc:
    cke     = 33
    cs      = 32
    ras     = 31
    cas     = 30
    we      = 29
    odt     = 28
    ba      = 25
    addr    = 9
    branch  = 8
    setcol  = 7
    setrow  = 6
    addr_chk= 5
    exit    = 4
    rd_ack  = 3
    wr_ack  = 2
    pre_ack = 1
    sr_chk  = 0


class op_bit:
    branch  = (1<< pin_loc.branch)      #B
    setcol  = (1<< pin_loc.setcol)      #A
    setrow  = (1<< pin_loc.setrow)      #A
    addr_chk= (1<< pin_loc.addr_chk)    #A
    exit    = (1<< pin_loc.exit)        #B
    rd_ack  = (1<< pin_loc.rd_ack)      #A
    wr_ack  = (1<< pin_loc.wr_ack)      #A
    pre_ack = (1<< pin_loc.pre_ack)     #A
    sr_chk  = (1<< pin_loc.sr_chk)      #A


def cmdgen(cke=0,cs=1,ras=1,cas=1,we=1,odt=0,ba=0,addr=0):
    val =0
    val |= cke  << pin_loc.cke
    val |= cs   << pin_loc.cs
    val |= ras  << pin_loc.ras
    val |= cas  << pin_loc.cas
    val |= we   << pin_loc.we
    val |= odt  << pin_loc.odt
    val |= ba   << pin_loc.ba
    val |= addr << pin_loc.addr
    return val

class cmd:
    nop     =cmdgen(cke=1,cs=1,ras=1,cas=1,we=1,odt=0,ba=0,addr=0)
    act     =cmdgen(cke=1,cs=0,ras=0,cas=1,we=1,odt=0,ba=0,addr=0)
    rd      =cmdgen(cke=1,cs=0,ras=1,cas=0,we=1,odt=0,ba=0,addr=0)
    wr      =cmdgen(cke=1,cs=0,ras=1,cas=0,we=0,odt=1,ba=0,addr=0)
    pre     =cmdgen(cke=1,cs=0,ras=0,cas=1,we=0,odt=0,ba=0,addr=0)
    prea    =cmdgen(cke=1,cs=0,ras=0,cas=1,we=0,odt=0,ba=0,addr=0x400)
    ref     =cmdgen(cke=1,cs=0,ras=0,cas=0,we=1,odt=0,ba=0,addr=0)
    mr0     =cmdgen(cke=1,cs=0,ras=0,cas=0,we=0,odt=0,ba=0,addr=mr0_val)
    mr1     =cmdgen(cke=1,cs=0,ras=0,cas=0,we=0,odt=0,ba=1,addr=mr1_val)
    mr2     =cmdgen(cke=1,cs=0,ras=0,cas=0,we=0,odt=0,ba=2,addr=mr2_val)
    mr3     =cmdgen(cke=1,cs=0,ras=0,cas=0,we=0,odt=0,ba=3,addr=mr3_val)
    zqcl    =cmdgen(cke=1,cs=0,ras=1,cas=1,we=0,odt=0,ba=0,addr=0x400)
    sre     =cmdgen(cke=0,cs=0,ras=0,cas=0,we=1,odt=0,ba=0,addr=0)
    sr      =cmdgen(cke=0,cs=1,ras=1,cas=1,we=1,odt=0,ba=0,addr=0)


print(hex(cmd.nop))

idle_list       =[]
act_list        =[]
wr_list         =[]
rd_list         =[]
rd2prea_list    =[]
wr2prea_list    =[]
wr2rd_list      =[]
rd2wr_list      =[]
prea2ref_list   =[]
ref_list        =[]
nop_list        =[]
wpaw_list       =[]
wpar_list       =[]
rpaw_list       =[]
rpar_list       =[]
sre_list        =[]
srx_list        =[]
init_list       =[]
waiting_list    =[]

class latency:
    tRCD = math.ceil(timing['tRCD']/cycle_ns)-4
    tCCD = timing['tCCD']-4
    tRTP = timing['tRTP']-timing['tCCD']
    tWTP = math.ceil(tWL+(mr0['burst_length']/2)+timing['tWR']-timing['tCCD'])
    tW2R = math.ceil(tWL+(mr0['burst_length']/2)+timing['tWTR'])
    tR2W = math.ceil(tRL-tWL+timing['tCCD']+2)
    tRP = math.ceil(timing['tRP']/cycle_ns)
    tRFC = math.ceil(timing['tRFC']/cycle_ns)
    tXS = math.ceil(timing['tXS']/cycle_ns)


if latency.tRCD <=0 :latency.tRCD =0
if latency.tCCD <=0 :latency.tCCD =0
if latency.tRTP <= 0 : latency.tRTP =0

print("w2r =",latency.tW2R-math.ceil(timing['tRCD']/cycle_ns))

def idel_creat():
    idle_list.append(format(cmd.nop,'09x'))
    idle_list.append(format(cmd.nop,'09x'))
    idle_list.append(format(cmd.nop,'09x'))    
    idle_list.append(format(cmd.nop,'09x'))
    idle_list.append(format(cmd.nop,'09x'))
    idle_list.append(format(cmd.nop,'09x'))

    for i in range(len(idle_list)):
        if((i%2)==0):
            print(idle_list[i],file=memFile, end ='')
        else:
            print(idle_list[i],file=memFile)    
    
    #print('idel_creat',file=memFile)

    return len(idle_list)/2


def act_creat():
   # for i in range((latency.tW2R-math.ceil(timing['tRCD']/cycle_ns))) :
    #    act_list.insert(1,format(cmd.nop,'09x'))        
    act_list.append(format(cmd.nop,'09x'))
    act_list.append(format(cmd.act|op_bit.setrow,'09x'))
    act_list.append(format(cmd.nop,'09x'))
    act_list.append(format(cmd.nop,'09x'))
    act_list.append(format(cmd.nop,'09x'))
    act_list.append(format(cmd.nop|op_bit.branch,'09x'))
    act_list.append(format(cmd.nop,'09x'))
    act_list.append(format(cmd.nop,'09x'))
    

    for i in range(latency.tRCD) :
        act_list.insert(1,format(cmd.nop,'09x'))

    if((len(act_list)%2)):
        act_list.append(format(cmd.nop,'09x'))

    for i in range(len(act_list)):
        if((i%2)==0):
            print(act_list[i],file=memFile,end='')
        else:
            print(act_list[i],file=memFile)

    #print('act_creat',file=memFile)
    return len(act_list)/2

def wr_creat():
    wr_list.append(format(cmd.nop|op_bit.setcol|op_bit.wr_ack,'09x'))
    wr_list.append(format(cmd.wr|op_bit.branch,'09x'))    
    wr_list.append(format(cmd.nop,'09x'))
    wr_list.append(format(cmd.nop,'09x'))
    
        

    for i in range(latency.tCCD):
        wr_list.insert(1,format(cmd.nop,'09x'))
    
    if((len(wr_list)%2)):
        wr_list.append(format(cmd.nop,'09x'))

    for i in range(len(wr_list)):
        if((i%2)==0):
            print(wr_list[i],file=memFile,end='')
        else:
            print(wr_list[i],file=memFile)
    
    #print('wr_creat',file=memFile)
    return len(wr_list)/2
    
def rd_creat():
    rd_list.append(format(cmd.nop|op_bit.setcol|op_bit.rd_ack,'09x'))
    rd_list.append(format(cmd.rd|op_bit.branch,'09x'))
    rd_list.append(format(cmd.nop,'09x'))
    rd_list.append(format(cmd.nop,'09x'))
    

    for i in range(latency.tCCD):
        rd_list.insert(1,format(cmd.nop,'09x'))
    
    if((len(rd_list)%2)):
        rd_list.append(format(cmd.nop,'09x'))

    for i in range(len(rd_list)):
        if((i%2)==0):
            print(rd_list[i],file=memFile,end='')
        else:
            print(rd_list[i],file=memFile)
    
    #print('rd_creat',file=memFile)
    return len(rd_list)/2


def rd2prea_creat():
    for i in range(latency.tRTP):
        rd2prea_list.append(format(cmd.nop,'09x'))

    if((len(rd2prea_list)%2)==0):
        rd2prea_list.append(format(cmd.nop,'09x')) #A

    rd2prea_list.append(format(cmd.prea,'09x')) #B

    for i in range(latency.tRP):
        rd2prea_list.append(format(cmd.nop,'09x'))

    if((len(rd2prea_list)%2)==0):
        rd2prea_list.append(format(cmd.nop,'09x'))#A
    
    rd2prea_list.append(format(cmd.nop|op_bit.exit,'09x'))#B
    rd2prea_list.append(format(cmd.nop,'09x'))
    rd2prea_list.append(format(cmd.nop,'09x'))
    

    for i in range(len(rd2prea_list)):
        if((i%2)==0):
            print(rd2prea_list[i],file=memFile,end='')
        else:
            print(rd2prea_list[i],file=memFile)
    
    #print('rd2prea_creat',file=memFile)
    return len(rd2prea_list)/2

def wr2prea_creat():
    for i in range(latency.tWTP):
        wr2prea_list.append(format(cmd.nop,'09x'))

    if((len(wr2prea_list)%2)==0):
        wr2prea_list.append(format(cmd.nop,'09x')) #A

    wr2prea_list.append(format(cmd.prea,'09x')) #B

    for i in range(latency.tRP-3):
        wr2prea_list.append(format(cmd.nop,'09x'))

    if((len(wr2prea_list)%2)==0):
        wr2prea_list.append(format(cmd.nop,'09x'))#A

    wr2prea_list.append(format(cmd.nop|op_bit.exit,'09x'))#B
    wr2prea_list.append(format(cmd.nop,'09x'))
    wr2prea_list.append(format(cmd.nop,'09x'))    

    for i in range(len(wr2prea_list)):
        if((i%2)==0):
            print(wr2prea_list[i],file=memFile,end='')
        else:
            print(wr2prea_list[i],file=memFile)
    
    #print('wr2prea_creat',file=memFile)
    return len(wr2prea_list)/2
print(latency.tW2R)

def wr2rd_creat():
    for i in range(latency.tW2R-6):
        wr2rd_list.append(format(cmd.nop,'09x'))    

    if((len(wr2rd_list)%2)):
        wr2rd_list.append(format(cmd.nop,'09x'))

    wr2rd_list.append(format(cmd.nop,'09x'))
    wr2rd_list.append(format(cmd.nop|op_bit.addr_chk,'09x'))

    for i in range(len(rd_list)):
        wr2rd_list.append(rd_list[i])

    for i in range(len(wr2rd_list)):
        if((i%2)==0):
            print(wr2rd_list[i],file=memFile,end='')
        else:
            print(wr2rd_list[i],file=memFile)
    
    #print('wr2rd_creat',file=memFile)
    return len(wr2rd_list)/2

def rd2wr_creat():
    for i in range(latency.tR2W-6):
        rd2wr_list.append(format(cmd.nop,'09x'))    

    if((len(rd2wr_list)%2)):
        rd2wr_list.append(format(cmd.nop,'09x'))

    rd2wr_list.append(format(cmd.nop,'09x'))
    rd2wr_list.append(format(cmd.nop|op_bit.addr_chk,'09x'))

    for i in range(len(wr_list)):
        rd2wr_list.append(wr_list[i])
    
    if((len(rd2wr_list)%2)):
        rd2wr_list.append(format(cmd.nop,'09x'))

    for i in range(len(rd2wr_list)):
        if((i%2)==0):
            print(rd2wr_list[i],file=memFile,end='')    
        else:
            print(rd2wr_list[i],file=memFile)    
    
    print('latency.tR2W')
    print(latency.tR2W)

    print('latency.tW2R')
    print(latency.tW2R)

    #print('rd2wr_creat',file=memFile)
    return len(rd2wr_list)/2

ref_ram =0

def prea2ref_creat():
    for i in range(latency.tWTP):
        prea2ref_list.append(format(cmd.nop,'09x'))
    
    if((len(prea2ref_list)%2)==0):
        prea2ref_list.append(format(cmd.nop,'09x'))

    prea2ref_list.append(format(cmd.prea,'09x'))
    
    for i in range(latency.tRP-1):
        prea2ref_list.append(format(cmd.nop,'09x'))
    
    if((len(prea2ref_list)%2)):
        prea2ref_list.append(format(cmd.nop,'09x'))

    global ref_ram
    ref_ram = len(prea2ref_list)/2
    print("ref_ram = ",ref_ram)
    prea2ref_list.append(format(cmd.nop,'09x'))
    prea2ref_list.append(format(cmd.ref,'09x'))

    for i in range(latency.tRFC-1):
        prea2ref_list.append(format(cmd.nop,'09x'))
    print("latency.tRFC = ",latency.tRFC)
    prea2ref_list.append(format(cmd.nop|op_bit.branch,'09x'))
    prea2ref_list.append(format(cmd.nop,'09x'))
    prea2ref_list.append(format(cmd.nop,'09x'))

    if((len(prea2ref_list)%2)):
        prea2ref_list.append(format(cmd.nop,'09x'))
    
    for i in range(len(prea2ref_list)):
        if((i%2)==0):
            print(prea2ref_list[i],file=memFile,end='')
        else:
            print(prea2ref_list[i],file=memFile)
    
    #print('prea2ref_creat',file=memFile)
    return len(prea2ref_list)/2

def nop_creat():
    nop_list.append(format(cmd.nop,'09x'))
    nop_list.append(format(cmd.nop,'09x'))
    nop_list.append(format(cmd.nop,'09x'))
    nop_list.append(format(cmd.nop,'09x'))

    for i in range(len(nop_list)):
        if((i%2)==0):
            print(nop_list[i],file=memFile,end='')
        else:
            print(nop_list[i],file=memFile)
    
    #print('nop_creat',file=memFile)
    return len(nop_list)/2


def wpaw_creat():
    for i in range(latency.tWTP):
        wpaw_list.append(format(cmd.nop,'09x'))

    if((len(wpaw_list)%2)==0):
        wpaw_list.append(format(cmd.nop,'09x'))

    wpaw_list.append(format(cmd.pre|op_bit.pre_ack,'09x'))

    for i in range(latency.tRP):
        wpaw_list.append(format(cmd.nop,'09x'))

    if((len(wpaw_list)%2)==0):
        wpaw_list.append(format(cmd.nop,'09x'))

    #wpaw_list.append(format(cmd.nop,'09x'))
    wpaw_list.append(format(cmd.act|op_bit.setrow,'09x'))
    wpaw_list.append(format(cmd.nop,'09x'))
    wpaw_list.append(format(cmd.nop,'09x'))

    for i in range(latency.tRCD) :
        wpaw_list.append(format(cmd.nop,'09x'))

    wpaw_list.append(format(cmd.nop,'09x'))            
    wpaw_list.append(format(cmd.nop|op_bit.addr_chk,'09x'))

    for i in range(len(wr_list)):
        wpaw_list.append(wr_list[i])
    
    if((len(wpaw_list)%2)):
        wpaw_list.append(format(cmd.nop,'09x'))

    for i in range(len(wpaw_list)):
        if((i%2)==0):
            print(wpaw_list[i],file=memFile,end='')
        else:
            print(wpaw_list[i],file=memFile)
    #print('wpaw_creat',file=memFile)
    return len(wpaw_list)/2


def wpar_creat():
    for i in range(latency.tWTP):
        wpar_list.append(format(cmd.nop,'09x'))
    
    if((len(wpar_list)%2)==0):
        wpar_list.append(format(cmd.nop,'09x'))

    wpar_list.append(format(cmd.pre|op_bit.pre_ack,'09x'))

    for i in range(latency.tRP):
        wpar_list.append(format(cmd.nop,'09x'))
    
    if((len(wpar_list)%2)==0):
        wpar_list.append(format(cmd.nop,'09x'))
    
    #wpar_list.append(format(cmd.nop,'09x'))
    wpar_list.append(format(cmd.act|op_bit.setrow,'09x'))
    wpar_list.append(format(cmd.nop,'09x'))
    wpar_list.append(format(cmd.nop,'09x'))
    
    for i in range(latency.tRCD) :
        wpar_list.append(format(cmd.nop,'09x'))

    wpar_list.append(format(cmd.nop,'09x'))            
    wpar_list.append(format(cmd.nop|op_bit.addr_chk,'09x'))
    
    for i in range(len(rd_list)):
        wpar_list.append(rd_list[i])

    if((len(wpar_list)%2)):
        wpar_list.append(format(cmd.nop,'09x'))
    
    for i in range(len(wpar_list)):
        if((i%2)==0):
            print(wpar_list[i],file=memFile,end='')
        else:
            print(wpar_list[i],file=memFile)

    #print('wpar_creat',file=memFile)
    return len(wpar_list)/2  


def rpaw_creat():
    for i in range(latency.tRTP):
        rpaw_list.append(format(cmd.nop,'09x'))

    if((len(rpaw_list)%2)==0):
        rpaw_list.append(format(cmd.nop,'09x'))

    rpaw_list.append(format(cmd.pre|op_bit.pre_ack,'09x'))

    for i in range(latency.tRP):
        rpaw_list.append(format(cmd.nop,'09x'))

    if((len(rpaw_list)%2)==0):
        rpaw_list.append(format(cmd.nop,'09x'))
    
    #rpaw_list.append(format(cmd.nop,'09x'))
    rpaw_list.append(format(cmd.act|op_bit.setrow,'09x'))
    wpar_list.append(format(cmd.nop,'09x'))
    wpar_list.append(format(cmd.nop,'09x'))
    
    for i in range(latency.tRCD) :
        rpaw_list.append(format(cmd.nop,'09x'))

    if((len(rpaw_list)%2)):
        rpaw_list.append(format(cmd.nop,'09x'))
    
    rpaw_list.append(format(cmd.nop,'09x'))            
    rpaw_list.append(format(cmd.nop|op_bit.addr_chk,'09x'))    

    for i in range(len(wr_list)):
        rpaw_list.append(wr_list[i])

    if((len(rpaw_list)%2)):
        rpaw_list.append(format(cmd.nop,'09x'))
    
    for i in range(len(rpaw_list)):
        if((i%2)==0):
            print(rpaw_list[i],file=memFile,end='')
        else:
            print(rpaw_list[i],file=memFile)
    
    #print('rpaw_creat',file=memFile)
    return len(rpaw_list)/2


def rpar_creat():
    for i in range(latency.tRTP):
        rpar_list.append(format(cmd.nop,'09x'))

    if((len(rpar_list)%2)==0):
        rpar_list.append(format(cmd.nop,'09x'))

    rpar_list.append(format(cmd.pre|op_bit.pre_ack,'09x'))

    for i in range(latency.tRP):
        rpar_list.append(format(cmd.nop,'09x'))

    if((len(rpar_list)%2)==0):
        rpar_list.append(format(cmd.nop,'09x'))
    
    #rpar_list.append(format(cmd.nop,'09x'))
    rpar_list.append(format(cmd.act|op_bit.setrow,'09x'))
    wpar_list.append(format(cmd.nop,'09x'))
    wpar_list.append(format(cmd.nop,'09x'))
    
    for i in range(latency.tRCD) :
        rpar_list.append(format(cmd.nop,'09x'))

    if((len(rpar_list)%2)):
        rpar_list.append(format(cmd.nop,'09x'))

    rpar_list.append(format(cmd.nop,'09x'))            
    rpar_list.append(format(cmd.nop|op_bit.addr_chk,'09x'))

    for i in range(len(rd_list)):
        rpar_list.append(rd_list[i])

    if((len(rpar_list)%2)):
        rpar_list.append(format(cmd.nop,'09x'))

    for i in range(len(rpar_list)):
        if((i%2)==0):
            print(rpar_list[i],file=memFile,end='')
        else:
            print(rpar_list[i],file=memFile)
    
    #print('rpar_creat',file=memFile)
    return len(rpar_list)/2

def sre_creat():
    sre_list.append(format(cmd.sre,'09x'))
    sre_list.append(format(cmd.sr,'09x'))
    sre_list.append(format(cmd.sr,'09x'))
    sre_list.append(format(cmd.sr,'09x'))
    sre_list.append(format(cmd.sr|op_bit.sr_chk,'09x'))
    sre_list.append(format(cmd.sr,'09x'))
    sre_list.append(format(cmd.sr,'09x'))

    if((len(sre_list)%2)):
        sre_list.append(format(cmd.nop,'09x'))

    for i in range(len(sre_list)):
        if((i%2)==0):
            print(sre_list[i],file=memFile,end='')
        else:
            print(sre_list[i],file=memFile)
    
    #print('sre_creat',file=memFile)
    return len(sre_list)/2


def srx_creat():
    for i in range(latency.tXS-3):
        srx_list.append(format(cmd.nop,'09x'))
        
    srx_list.append(format(cmd.nop|op_bit.exit,'09x'))
    srx_list.append(format(cmd.nop,'09x'))
    srx_list.append(format(cmd.nop,'09x'))

    if((len(srx_list)%2)):
        srx_list.append(format(cmd.nop,'09x'))

    for i in range(len(srx_list)):
        if((i%2)==0):
            print(srx_list[i],file=memFile,end='')
        else:
            print(srx_list[i],file=memFile)
    
    #print('srx_creat',file=memFile)
    return len(srx_list)/2


def init_creat():
    init_list.append(format(cmd.mr2,'09x'))

    for i in range(timing['tMRD']-1):
        init_list.append(format(cmd.nop,'09x'))

    init_list.append(format(cmd.mr3,'09x'))

    for i in range(timing['tMRD']-1):
        init_list.append(format(cmd.nop,'09x'))
    
    init_list.append(format(cmd.mr1,'09x'))

    for i in range(timing['tMRD']-1):
        init_list.append(format(cmd.nop,'09x'))

    init_list.append(format(cmd.mr0,'09x'))

    for i in range(timing['tMOD']-2):
        init_list.append(format(cmd.nop,'09x'))

    init_list.append(format(cmd.nop|op_bit.exit,'09x'))
    init_list.append(format(cmd.zqcl,'09x'))
    init_list.append(format(cmd.nop,'09x'))
    init_list.append(format(cmd.nop,'09x'))
    init_list.append(format(cmd.nop,'09x'))

    if((len(init_list)%2)):
        srx_list.append(format(cmd.nop,'09x'))

    for i in range(len(init_list)):
        if((i%2)==0):
            print(init_list[i],file=memFile,end='')
        else:
            print(init_list[i],file=memFile)
    
    #print('init_creat',file=memFile)
    return len(init_list)/2


def waiting_creat():
    
    waiting_list.append(format(cmd.nop,'09x'))    
    waiting_list.append(format(cmd.nop|op_bit.branch,'09x'))
    waiting_list.append(format(cmd.nop,'09x'))
    waiting_list.append(format(cmd.nop,'09x'))
    
    for i in range(len(waiting_list)):
        if((i%2)==0):
            print(waiting_list[i],file=memFile,end='')
        else:
            print(waiting_list[i],file=memFile)
    
    #print('waiting_creat',file=memFile)
    return len(waiting_list)

total_len = 0
tmp_len =0

if sim == 'yes':
    print('`define RTL_SIM ',file=vhFile,sep='')

print('`define RAM_IDLE 9\'d',int(total_len),file=vhFile,sep='')
total_len += idel_creat()
print('`define RAM_ACT 9\'d',int(total_len),file=vhFile,sep='')
total_len +=act_creat()
print('`define RAM_WR 9\'d',int(total_len),file=vhFile,sep='')
total_len +=wr_creat()
print('`define RAM_RD 9\'d',int(total_len),file=vhFile,sep='')
total_len +=rd_creat()
print('`define RAM_RD2PREA 9\'d',int(total_len),file=vhFile,sep='')
total_len +=rd2prea_creat()
print('`define RAM_WR2PREA 9\'d',int(total_len),file=vhFile,sep='')
total_len +=wr2prea_creat()
print('`define RAM_WR2RD 9\'d',int(total_len),file=vhFile,sep='')
total_len +=wr2rd_creat()
print('`define RAM_RD2WR 9\'d',int(total_len),file=vhFile,sep='')
total_len +=rd2wr_creat()
tmp_len =prea2ref_creat()
print('`define RAM_PREA2REF 9\'d',int(total_len),file=vhFile,sep='')
print('`define RAM_REF 9\'d',int(total_len+ref_ram),file=vhFile,sep='')
total_len +=tmp_len
print('`define RAM_NOP 9\'d',int(total_len),file=vhFile,sep='')
total_len +=nop_creat()
print('`define RAM_WPAW 9\'d',int(total_len),file=vhFile,sep='')
total_len +=wpaw_creat()
print('`define RAM_WPAR 9\'d',int(total_len),file=vhFile,sep='')
total_len +=wpar_creat()
print('`define RAM_RPAW 9\'d',int(total_len),file=vhFile,sep='')
total_len +=rpaw_creat()
print('`define RAM_RPAR 9\'d',int(total_len),file=vhFile,sep='')
total_len +=rpar_creat()
print('`define RAM_SRE 9\'d',int(total_len),file=vhFile,sep='')
print('`define RAM_SR 9\'d',int(total_len)+2,file=vhFile,sep='')
total_len +=sre_creat()
print('`define RAM_SRX 9\'d',int(total_len),file=vhFile,sep='')
total_len +=srx_creat()
print('`define RAM_INIT 9\'d',int(total_len),file=vhFile,sep='')
total_len +=init_creat()
print('`define RAM_WAITING 9\'d',int(total_len),file=vhFile,sep='')
total_len +=waiting_creat()

print('Total Lenght =',int(total_len))

print('`define BRAM_LEN ',int(total_len),file=vhFile,sep='')
print('`define BRAM_I_WIDTH ',math.ceil(math.log2(total_len)),file=vhFile,sep='')
print('`define BRAM_D_WIDTH ',72,file=vhFile,sep='')

if sim == 'yes':
    print('`define MICRO_SEC ',int(us/50),file=vhFile,sep='')
else:
    print('`define MICRO_SEC ',us,file=vhFile,sep='')

print('`define REF_INTERVAL ','%g'%((tREFI/cycle_ns)*8),file=vhFile,sep='')

print('`define DRAM_WIDTH ',data_width,file=vhFile,sep='')
print('`define GROUP_WIDTH ',8,file=vhFile,sep='')
print('`define DRAM_GROUP ',int(data_width/8),file=vhFile,sep='')
print('`define DM_BIT_WIDTH ',int((data_width/8)*mr0['burst_length']),file=vhFile,sep='')

print('`define ROW ',row,file=vhFile,sep='')
print('`define COL ',col,file=vhFile,sep='')
print('`define BANK ',bank,file=vhFile,sep='')
print('`define BA_BIT_WIDTH ',int(math.pow(2,bank)),file=vhFile,sep='')

print('`define WFIFO_WIDTH ',data_width*mr0['burst_length'],file=vhFile,sep='')
print('`define BL ',mr0['burst_length'],file=vhFile,sep='')
print('`define usReset ',timing['usReset'],file=vhFile,sep='')
print('`define usCKE ',timing['usCKE'],file=vhFile,sep='')
print('`define tZQinit ',timing['tZQinit'],file=vhFile,sep='')

print('`define ODTH8 ',timing['ODTH8'],file=vhFile,sep='')
print('`define tRL ',tRL,file=vhFile,sep='')
print('`define tWL ',tWL,file=vhFile,sep='')
print('`define ARBITER_INIT ',arbiter['arbiter_init'],file=vhFile,sep='')
print('`define ARBITER_COUNT ',arbiter['arbiter_count'],file=vhFile,sep='')

if sim == 'yes':
    # print('`define RAM_FILE  "%s/ddr3_controller.bin"'% os.path.abspath(os.getcwd()),file=vhFile,sep='')
    binpath = Path(Path.cwd(), 'ddr3_controller.bin').as_posix()
    print(f'`define RAM_FILE  "{binpath}"', file=vhFile, sep='')
else:
    print('`define RAM_FILE "ddr3_controller.bin"',file=vhFile,sep='')

print('`define BRAM_WIDTH ',math.ceil(math.log2(total_len)))
print('`define BA_BIT_WIDTH ',int(math.pow(2,bank)))

print('`define VH_FILE',file=vhFile,sep='')


vhFile.close