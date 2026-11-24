#!/usr/bin/env python3
"""Deterministic, original, editable, tiered glTF geometry (build-time only).

Requires `pip install trimesh numpy` for asset generation. Godot runtime does
not depend on Python/trimesh. Masters are deliberate authored-model PREVIZ,
not photorealistic final art. Meshes, parts, colors and dimensions are original.

Coordinate conversion: internal trimesh Z-up -> glTF Y-up -> Godot Y-up.
`P(x, height, depth)` is the public human-scale coordinate convention.
"""
from pathlib import Path
import json, math, random, hashlib
import numpy as np
import trimesh
from trimesh.visual.material import PBRMaterial

HERE = Path(__file__).resolve().parents[1]
OUT = HERE/'assets'/'models'
OUT.mkdir(parents=True, exist_ok=True)

PAL = {
    'limestone': ([212,196,165,255], 0.04, 0.92),
    'limestone_dark': ([148,143,125,255], 0.06, 0.90),
    'limestone_light': ([240,224,190,255], 0.02, 0.86),
    'copper': ([183,113,66,255], 0.83, 0.32),
    'copper_patina': ([73,137,133,255], 0.55, 0.48),
    'brass': ([211,158,81,255], 0.80, 0.29),
    'steel': ([89,109,115,255], 0.76, 0.36),
    'dark_steel': ([44,64,73,255], 0.72, 0.44),
    'timber': ([112,79,58,255], 0.01, 0.88),
    'oak': ([169,125,76,255], 0.02, 0.81),
    'glass': ([87,155,169,255], 0.20, 0.13),
    'enamel': ([39,86,100,255], 0.31, 0.42),
    'amber': ([242,175,76,255], 0.25, 0.28),
    'leaf': ([83,124,83,255], 0.0, 0.93),
    'roof': ([65,116,121,255], 0.52, 0.58),
}


def P(x,h,d): return np.array([float(x),-float(d),float(h)],dtype=float)

class Model:
    def __init__(self, name, low=False):
        self.scene=trimesh.Scene(base_frame=name)
        self.rng=random.Random(27011)
        self.low=low
        self.count=0
        self.materials={}
        for k,(rgba,m,r) in PAL.items():
            self.materials[k]=PBRMaterial(name=f'WF_{k}',baseColorFactor=rgba,metallicFactor=m,roughnessFactor=r,doubleSided=False)

    def add(self, mesh, name, mat):
        mesh.visual=trimesh.visual.TextureVisuals(material=self.materials[mat])
        self.scene.add_geometry(mesh,geom_name=f'{name}_{self.count:04d}',node_name=f'{name}_{self.count:04d}')
        self.count+=1

    def box(self,name,at,size,mat):
        w,h,d=size
        m=trimesh.creation.box(extents=[w,d,h]);m.apply_translation(P(*at));self.add(m,name,mat)

    def cylinder(self,name,at,r,h,mat,sides=20):
        m=trimesh.creation.cylinder(radius=r,height=h,sections=(max(8,sides//2) if self.low else sides));m.apply_translation(P(*at));self.add(m,name,mat)

    def sphere(self,name,at,r,mat,detail=2):
        m=trimesh.creation.icosphere(subdivisions=(1 if self.low else detail),radius=r);m.apply_translation(P(*at));self.add(m,name,mat)

    def beam(self,name,a,b,rad,mat,sides=10):
        a,b=P(*a),P(*b)
        v=b-a
        m=trimesh.creation.cylinder(radius=rad,height=np.linalg.norm(v),sections=(6 if self.low else sides))
        m.apply_transform(trimesh.geometry.align_vectors([0,0,1],v/np.linalg.norm(v)))
        m.apply_translation((a+b)*0.5)
        self.add(m,name,mat)

    def torus(self,name,at,R,r,mat,vertical=False):
        sections=16 if self.low else 32
        m=trimesh.creation.torus(major_radius=R,minor_radius=r,major_sections=sections,minor_sections=(6 if self.low else 10))
        if vertical:
            m.apply_transform(trimesh.transformations.rotation_matrix(math.pi/2,[1,0,0]))
        m.apply_translation(P(*at));self.add(m,name,mat)

    def gear(self,name,at,r,thick,teeth,mat,face_front=True):
        # Real geometric radially-cut outer profile, built as a manifold extruded
        # toothed wheel. A decorative wheel, not a dynamic gear/meshing solver.
        points=[]
        n=teeth*4
        for i in range(n):
            angle=2*math.pi*i/n
            radius=r*(1.12 if i%4 in (1,2) else 0.90)
            points.append((math.cos(angle)*radius,math.sin(angle)*radius))
        # For a horizontal gear, xy plane in z-up; vertical gear rotates into xz.
        front_z=-thick*0.5;back_z=thick*0.5
        vertices=[[0,0,front_z],[0,0,back_z]]
        for x,y in points:vertices.append([x,y,front_z])
        for x,y in points:vertices.append([x,y,back_z])
        faces=[]
        for i in range(n):
            k=(i+1)%n
            faces.extend([[0,2+i,2+k],[1,2+n+k,2+n+i]])
            faces.extend([[2+i,2+n+i,2+k],[2+k,2+n+i,2+n+k]])
        mesh=trimesh.Trimesh(vertices=vertices,faces=faces,process=True)
        if face_front: mesh.apply_transform(trimesh.transformations.rotation_matrix(math.pi/2,[1,0,0]))
        mesh.apply_translation(P(*at))
        self.add(mesh,name,mat)
        self.torus('GearInnerRing',at,r*0.23,r*0.065,'dark_steel',face_front)

    def export(self,stem):
        filename=OUT/f'{stem}.glb'; filename.write_bytes(self.scene.export(file_type='glb'))
        triangles=sum(len(g.faces) for g in self.scene.geometry.values())
        data={'asset':stem,'source':'original deterministic procedural art','preview_status':'work-in-progress authored geo','quality':'explorer' if self.low else 'creator_ultra', 'nodes':self.count,'triangles':triangles,'bytes':filename.stat().st_size,'sha256':hashlib.sha256(filename.read_bytes()).hexdigest()}
        return data


def build_workshop(low=False):
    m=Model('FoundersWorkshop',low)
    # A grounded, open-sided working building with readable positive-space
    # architectural silhouette: stone plinth, copper roof, arched entry.
    m.box('RaisedStonePlinth',(0,0.18,0),(14,0.36,12),'limestone_dark')
    m.box('PolishedCourtyard',(0,0.44,0),(12.8,0.18,10.7),'limestone')
    for ix in range(-5,6):
        for iz in range(-4,5):
            if low and (ix+iz)%2:continue
            m.box('HonestStonePaver',(ix*1.04,0.55,iz*1.10),(0.98,0.07,1.03),'limestone_light' if (ix+iz)%3==0 else 'limestone')
    # Wall piers to express masonry, but the building remains enterable.
    for x in [-6.0,6.0]:
        for z in [-4.65,0,4.65]:
            m.box('LimestoneButtress',(x,3.0,z),(0.75,5.8,0.75),'limestone')
            m.box('ButtressCapital',(x,6.1,z),(1.12,0.34,1.10),'limestone_light')
    for z in [-5.1,5.1]:
        for x in [-6,6]:
            m.box('CornerFascia',(x,3.0,z),(0.64,5.2,0.75),'limestone_dark')
    m.box('RearMasonry',(0,3.0,-5.1),(11.7,5.7,0.48),'limestone')
    # Three-panel side windows with mullions and mid-level stone sill.
    for side in [-1,1]:
        for z in [-3.1,1.3]:
            m.box('BlueGlazedWindow',(side*6.09,3.7,z),(0.12,2.70,2.36),'glass')
            for zz in [-1.12,0,1.12]:
                m.box('StoneWindowMullion',(side*6.17,3.7,z+zz),(0.22,2.9,0.12),'limestone_light')
            m.box('WindowSill',(side*6.14,2.26,z),(0.40,0.20,2.65),'limestone_light')
    # Open front: freestanding twin piers, arch expressed in separate voussoirs.
    for x in [-5.35,5.35]:
        m.box('GrandEntryPier',(x,3.4,5.5),(0.85,6.2,0.75),'limestone')
        m.box('EntryPlinth',(x,0.75,5.5),(1.2,0.6,1.05),'limestone_dark')
    for i in range(17 if not low else 9):
        t=i/(16 if not low else 8)
        angle=math.pi*(1.0-t)
        x=4.75*math.cos(angle)
        y=4.3+2.0*math.sin(angle)
        m.box('HandCutArcStone',(x,y,5.5),(0.75,0.52,0.77),'limestone_light' if i%3==0 else 'limestone')
    # Copper roof profile is split, ribbed and realistically supported.
    for side in [-1,1]:
        for i in range(9 if not low else 5):
            z=-4.8+i*(1.2 if not low else 2.25)
            m.beam('CopperRoofRafter',(0,8.2,z),(side*6.35,6.72,z),0.13,'oak')
        m.beam('CopperRoofRidge',(0,8.2,-5.0),(0,8.2,5.0),0.14,'brass')
        for ix in range(9 if not low else 5):
            x=(ix+0.5)*0.70*side
            h=8.2-abs(x)*0.232
            m.box('StandingSeamRoof',(x,h,0),(0.72,0.13,10.4),'copper_patina' if ix%5==0 else 'roof')
    for x in [-5.3,5.3]:
        m.beam('EaveGutter',(x,6.77,-5),(x,6.77,5),0.12,'copper')
    # 3 production stations (lathe, gear transmission, brass crane).
    m.box('TimberWorktable',(-3,1.35,-1.5),(4.1,0.24,1.9),'oak')
    for x in [-4.7,-1.3]:
        for z in [-2.2,-0.8]:
            m.box('TableSupport',(x,0.84,z),(0.16,1.4,0.20),'timber')
    for x in [1.4,3.5]:
        m.cylinder('LatheSpindle', (x,1.28,-2.4),0.21,1.9,'dark_steel',12)
    m.beam('LatheMainShaft',(1.3,2.1,-2.0),(4.2,2.1,-2.0),0.12,'steel')
    m.gear('OpenGear_28T',(2.8,2.5,-2.8),1.05,0.20,18 if low else 28,'brass')
    m.gear('OpenGear_18T',(4.2,3.18,-2.8),0.63,0.18,12 if low else 18,'copper')
    for height in [2.15,3.35]:
        m.beam('GearGuardRail',(1.1,height,-3.8),(5.15,height,-3.8),0.06,'dark_steel')
    for xx in [-2.8,2.8]:
        m.beam('OverheadCranePost',(xx,0.7,3.2),(xx,5.7,3.2),0.14,'dark_steel')
    m.beam('OverheadCraneCrossbeam',(-4.7,5.7,3.2),(4.7,5.7,3.2),0.24,'steel')
    m.beam('CraneHoistCable',(0,5.6,3.2),(0,2.9,3.2),0.048,'steel',8)
    m.cylinder('CraneHoistWeight',(0,2.55,3.2),0.46,0.65,'copper',12)
    # Forging area: chimneys, boiler, vent cap, rivets.
    m.cylinder('WorkshopBoiler',(4.0,2.2,0.8),0.92,2.4,'dark_steel',20)
    m.cylinder('BoilerCap',(4.0,3.48,0.8),1.05,0.27,'brass',20)
    m.beam('SmokeStack',(4.0,3.58,0.8),(4.0,8.7,0.8),0.34,'copper',14)
    m.cylinder('SmokeStackLip',(4,8.73,0.8),0.48,0.25,'steel',16)
    if not low:
        for i in range(14):
            x=-5.2+i*0.8
            m.box('CopperWallPanelRivet',(x,3.95,-5.40),(0.09,0.10,0.10),'brass')
        for i in range(10):
            angle=i*math.tau/10
            m.sphere('BoilerBolts',(4+math.cos(angle)*0.89,3.3,0.8+math.sin(angle)*0.89),0.075,'brass',1)
    # Eyecatching huge suspended maker sigil / orrery, silent and plausible.
    m.torus('MakerGuildSigil',(0,5.65,5.8),1.0,0.12,'brass',True)
    for i in range(8):
        theta=i*math.tau/8
        m.beam('SigilSpoke',(0,5.65,5.8),(math.cos(theta)*0.9,5.65+math.sin(theta)*0.9,5.8),0.035,'copper')
    return m.export('founders_workshop_explorer' if low else 'founders_workshop_creator')


def build_observatory(low=False):
    m=Model('AstralObservatory',low)
    m.cylinder('OuterPlinth',(0,0.45,0),6.7,0.9,'limestone_dark',24)
    m.cylinder('InnerPlinth',(0,0.95,0),5.8,0.4,'limestone_light',24)
    for i in range(12 if not low else 8):
        th=i*math.tau/(12 if not low else 8)
        x,z=5.5*math.cos(th),5.5*math.sin(th)
        m.cylinder('ObservatoryColumn',(x,3.25,z),0.38,4.9,'limestone_light',14)
        m.cylinder('ObservatoryColumnCapital',(x,5.8,z),0.53,0.4,'brass',14)
        m.cylinder('ObservatoryColumnBase',(x,0.90,z),0.5,0.36,'limestone',14)
    m.torus('BrassRotundaRing',(0,5.98,0),5.55,0.33,'brass')
    m.torus('AstrolabeGreatRing',(0,10.65,0),4.55,0.18,'brass',True)
    m.torus('AstrolabeInnerRing',(0,10.65,0),3.25,0.14,'copper',True)
    m.torus('AstrolabeRotatingAxis',(0,10.65,0),2.15,0.11,'copper_patina',False)
    for i in range(8 if not low else 4):
        t=i*math.tau/(8 if not low else 4)
        m.beam('SightingArm',(0,10.65,0),(math.cos(t)*3.8,10.65+math.sin(t)*3.8,0),0.08,'dark_steel')
    m.sphere('HeartOfObservatory',(0,10.65,0),1.12,'glass',2)
    m.sphere('GoldAstrolabeCenter',(0,10.65,0),0.34,'amber',2)
    m.beam('PrimaryInstrumentColumn',(0,0.9,0),(0,7.7,0),0.41,'steel')
    m.cylinder('ObservationDeck',(0,6.45,0),3.45,0.31,'limestone',24)
    for i in range(10 if not low else 5):
        theta=i*math.tau/(10 if not low else 5)
        x,z=3.15*math.cos(theta),3.15*math.sin(theta)
        m.box('RimParapet',(x,6.95,z),(0.6,1.1,0.5),'limestone_light')
    for i in range(6 if not low else 3):
        th=i*math.tau/(6 if not low else 3)
        xx,zz=2.6*math.cos(th),2.6*math.sin(th)
        m.sphere('PlanetModel',(xx,7.65,zz),0.25 if i%2 else 0.38,'brass',1)
    return m.export('astral_observatory_explorer' if low else 'astral_observatory_creator')


def main():
    data=[]
    for low in [False,True]:
        data.append(build_workshop(low))
        data.append(build_observatory(low))
    meta={'generator':'art_pipeline/generate_original_models.py','runtime_dependencies':[], 'asset_license':'original WonderForge MIT design meshes','assets':data}
    (OUT/'asset_manifest.json').write_text(json.dumps(meta,indent=2)+'\n')
    print(json.dumps(data,indent=2))

if __name__=='__main__': main()
