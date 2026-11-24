/* WonderForge's original, transparent calculations. No external dependencies.
 * Educational idealizations ONLY: not a circuit wiring or structural safety tool. */
(function (root, factory) {
  if (typeof module === 'object' && module.exports) module.exports = factory();
  else root.WonderForgeLabs = factory();
})(typeof globalThis !== 'undefined' ? globalThis : this, function(){
  'use strict';
  const number=(v,lo,hi)=>Number.isFinite(+v)?Math.min(hi,Math.max(lo,+v)):lo;
  function led(voltage=5,resistance=330,forwardVoltage=2){
    const v=number(voltage,0,24),r=number(resistance,1,100000),vf=number(forwardVoltage,1,4);
    const amps=Math.max(0,v-vf)/r;
    const ma=amps*1000;
    const power=amps*amps*r;
    return {voltage:v,resistance:r,forwardVoltage:vf,ma,powerW:power,
      severity:ma>20?'unsafe':ma>=2?'lit':'dim',
      safety:ma>20?'Model predicts over 20 mA. Do not build this configuration.':
         ma>=2?'Calculated current is within a typical indicator LED operating range; check actual component ratings.':
         'Low calculated current. The LED may be dim or off.'};
  }
  function beam(forceN=100,spanM=1,widthMm=30,heightMm=40,material='wood'){
    const modulus={wood:10e9,aluminum:69e9,steel:200e9,plastic:2.5e9};
    const materialName=Object.hasOwn(modulus,material)?material:'wood';
    const e=modulus[materialName];
    const f=number(forceN,0,10000),L=number(spanM,.1,12),b=number(widthMm,2,500)/1000,h=number(heightMm,2,500)/1000;
    const I=b*Math.pow(h,3)/12;
    const displacement=f*Math.pow(L,3)/(48*e*I);
    const stress=f*L*h/(8*I);
    return {forceN:f,spanM:L,widthMm:b*1000,heightMm:h*1000,material:materialName,modulusPa:e,
       inertiaM4:I,deflectionMm:displacement*1000,stressMPa:stress/1e6,
       warning:'Simplified elastic simply-supported beam with a single centered static load. No strength, buckling, joint, fatigue or safety-factor checks. Never use for construction or safety decisions.'};
  }
  return {led,beam};
});
