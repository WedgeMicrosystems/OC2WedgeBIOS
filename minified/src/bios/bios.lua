NULLPTR="00000000-0000-0000-0000-000000000000"constants={version="1.0.0",debugmode=true}binutils={bytetobitarray=function(a)local temp={}for i=0,63 do temp[i+1]=a&(1<<i)>>i end end,inttobool=function(b)if b==0 then return false else return true end end}function try(c,d,e,...)if type(c)~="function"then error("try: invalid type for tryMethod: "..type(c).."Trace: "..debug.traceback())end;if type(d)~="function"then error("try: invalid type for failMethod: "..type(d).."Trace: "..debug.traceback())end;local f=table.pack(pcall(c,...))if f[1]then if e then return table.remove(f,1)else return f[2]end else attempt2=table.pack(pcall(d,f[2],...))if attempt2[1]then if e then return table.remove(f,1)else return attempt2 end else error("try: failMethod errored: "..attmept2[2]..debug.traceback())end end end;eepromutils={_eepromaddress="",_eepromdatasize=256,data={_codechksm="",_initalized=false,_rawdata="",_rawbytes={}},load=function(self)if self.data._initalized then error("eeprom load() called twice Trace: "..debug.traceback())end;if self._eepromaddress==""or self._eepromaddress==nil then error("eeprom load() called before EEPROM init! Trace: "..debug.traceback())else local g=component.proxy(self._eepromaddress)self._eepromdatasize=g.getDataSize()self.data._rawdata=g.getData()self.data._codechksm=g.getChecksum()local temp={}for i=1,self._eepromdatasize do if self._rawdata:byte(i)==nil then temp[i]=0 else temp[i]=self._rawdata:byte(i)end end end;self._rawbytes=temp;self.data._initalized=true end,readbyte=function(self,h)if not self.data_initalized then error("readbyte() called without EEPROM init! Trace: "..debug.traceback())else if h>self._eepromdatasize or h<0 then error(string.format("readbyte(): Access Violation: 0x%x - Stack: ",h)..debug.traceback())else return self.data._rawbytes[i-1]end end end,writebyte=function(self,a,h)if not self.data_initalized then error("writebyte() called without EEPROM init! Trace: "..debug.traceback())else if h>self._eepromdatasize or h<0 then error(string.format("writebyte(): Access Violation: 0x%x - Trace: ",h)..debug.traceback())else if a<0 or a>0xFF then error(string.format("writebyte(): Write attempt with value larger than uint8: %d - Trace: ",a)..debug.traceback())end;self.data._rawbytes[i-1]=a end end end,readuint16=function(self,h)local j=self:readbyte(h)local k=self:readbyte(h+1)return j+k<<8 end,readuint32=function(self,h)local temp=0;for i=0,3 do temp=temp+self:readbytes(h+i)<<i*8 end;return temp end,readuint64-function(self,h)local temp=0;for i=0,7 do temp=temp+self:readbytes(h+i)<<i*8 end;return temp end,writeuint16=function(self,l,h)local j=l&0xFF;local k=l&0xFF00>>8;self:writebyte(j,h)self:writebyte(k,h+1)end,writeuint32=function(self,m,h)for i=0,3 do self:writebyte(m&(0xFF<<8*i>>8*i),h+i)end end,writeuint64=function(self,n,h)for i=0,7 do self:writebyte(n&(0xFF<<8*i>>8*i),h+i)end end}config={bootDevices={NULLPTR,NULLPTR,NULLPTR,NULLPTR,NULLPTR,NULLPTR},booleanVars={ueifEnabled=false,legacyBootEnabled=false,secureBootEnabled=false,networkBootEnable=false},integerVars={lastBootTime=0,confighash=0}}function Boot_Invoke(h,o,...)result=table.pack(pcall(component.invoke,h,o,...))if result[1]then if#table.remove(result,1)~=1 then return result,nil else return result[2],nil end else return nil,result[2]end end;eepromutils._eepromaddress=component.proxy(component.list("eeprom")()).address;eepromutils:load()for i=0,5 do local p=""for q=1,16 do local a=eepromutils:readbyte(q+i*16)if q==4 or q==6 or q==8 or q==10 then p=p..string.format("%x",a).."-"else p=p..string.format("%x",a)end;config.bootDevices[i+1]=p end end;config.lastBootTime=eepromutils:readuint32(0x60)config.confighash=eepromutils:readuint32(0x64)local p={}p=binutils.bytetobitarray(eepromutils:readbyte(0x68))config.ueifEnabled=binutils.inttobool(p[1])config.legacyBootEnabled=binutils.inttobool(p[2])config.secureBootEnabled=binutils.inttobool(p[3])config.networkBootEnabled=binutils.inttobool(p[4])Headless=true;if component.list("gpu")()~=nil and component.list("screen")~=nil then local r={new=function(self,s)self.colorDepth=Boot_Invoke(s,"maxDepth")self.DeviceAddress=s;self.GraphicsCalls.DeviceAddress=s;return self end,colorDepth=0,DeviceAddress=NULLPTR,GraphicsCalls={DeviceAddress=NULLPTR,drawText=function(self,t,u,v)Boot_Invoke(self.DeviceAddress,"set",t,u,v)end,fillScreen=function(self,w,x,y,z,A)Boot_Invoke(self.DeviceAddress,"fill",w,x,y,z,A)end,setForegroundColor=function(self,B,C)Boot_Invoke(self.DeviceAddress,"setForeground",B,C)end,setBackgroundColor=function(self,B,C)Book_Invoke(self.Device,Address,"setBackground",B,C)end,clearScreen=function(self)self:fillScreen(0,0,50,16," ")end,getMaxResolution=function(self)xy=Boot_Invoke(self.DeviceAddress,"maxResolution")return xy[1],xy[2]end,setResolution=function(self,t,u)xMax,yMaxs=self:getMaxResolution()if t>xMax or u>yMax then error("GPUDevice: setResolution exceeds maxResolution: "..tostring(t)..tostring(u).."when max is: "..tostring(xMax)..tostring(yMax).." Trace: "..debug.traceback())else Boot_Invoke(self.DeviceAddress,"setResolution",t,u)end end}}local s=component.proxy(component.list("gpu")()).address;local D=component.proxy(component.list("screen")()).address;Boot_Invoke(s,"bind",D)local mainGPUDevice=r:new(s)mainGPUDevice.GraphicsCalls:clearScreen()Headless=false end;if Headless then goto E else local F=true;mainGPUDevice.GraphicsCalls:setResolution(50,16)mainGPUDevice.GraphicsCalls:set(1,1,"[Text mode init]")if mainGPUDevice.colorDepth==1 then F=true else if mainGPUDevice.colorDepth==4 then local G=34;local H=15;for q=0,1 do for i=0,7 do local I=G+i*2;local J=H+q;mainGPUDevice.GraphicsCalls:setBackgroundColor(i+1+q*8,true)mainGPUDevice.GraphicsCalls:setForegroundColor(i+1+q*8,true)mainGPUDevice.GraphicsCalls:set(I,J,"##")end end;mainGPUDevice.GraphicsCalls:setBackgroundColor(0)mainGPUDevice.GraphicsCalls:setForegroundColor(0xffffff)else if mainGPUDevice.colorDepth==8 then F=false end end end end
