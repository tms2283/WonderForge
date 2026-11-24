-- WonderForge original floating-island quest world. Works as a worldmod in Minetest Game / Luanti.
-- Generated structures are voxel geometry; no external games or third-party assets.
local core = minetest
local store = core.get_mod_storage()
local modname = core.get_current_modname()
local tex = "wonderforge_"
local CENTER = { x = 0, y = 15, z = 0 }
local REGION = {
    { id="sky", name="Sky Citadel", x=46, z=0, color="sky", hint="Test triangular bracing in a bridge" },
    { id="robot", name="Robot Wilds", x=23, z=40, color="robot", hint="Design a sensor-input-action loop" },
    { id="crystal", name="Crystal Deep", x=-23, z=40, color="crystal", hint="Sort minerals by evidence, not appearance alone" },
    { id="red", name="Red Frontier", x=-46, z=0, color="red", hint="Balance air, water, power and supplies" },
    { id="echo", name="Echo Isles", x=-23, z=-40, color="echo", hint="Build soundscapes with rhythm and layers" },
    { id="code", name="Code Garden", x=23, z=-40, color="code", hint="Write a short algorithm and debug it" },
}
local QUESTS = {
    {id="bridge", title="Bridge the Sky", challenge="Construct two bridge designs and compare what bends.", why="Learn about load paths, structure and controlled tests."},
    {id="robot", title="Build a Rescue Robot", challenge="Draw an input-process-output design for a rescue rover.", why="Learn sensors, logic and real engineering constraints."},
    {id="crystal", title="The Crystal Cartographer", challenge="Compare and classify three samples using observable properties.", why="Practice evidence-based reasoning."},
    {id="red", title="Red Frontier Habitat", challenge="Sketch a habitat and calculate its resource needs.", why="Learn systems thinking in space science."},
    {id="echo", title="Echo Isles Composer", challenge="Record five original sounds to tell a story.", why="Learn creative sequencing and composition."},
    {id="code", title="The Code Garden", challenge="Write a sequence that navigates around an obstacle.", why="Learn algorithms, order and debugging."},
}

local palettes = {
    sky = {255, 201, 112}, robot = {88, 214, 163}, crystal = {185, 132, 246},
    red = {244, 116, 102}, echo = {99, 170, 250}, code = {188, 220, 112},
}
local function chat(player, message)
    if player then core.chat_send_player(player:get_player_name(), "[WonderForge] " .. message) end
end
local function teleport(player, destination, label)
    if not player or not player:is_player() then return end
    player:set_pos(destination)
    chat(player, "Welcome to " .. label .. ". Type /forge for the mission board.")
end
local function show_board(player)
    local name = player:get_player_name()
    local form = "formspec_version[4]size[13,10]" ..
        "bgcolor[#102437;true]label[0.5,0.4;WONDERFORGE  /  THE INVENTOR'S ATLAS]" ..
        "label[0.5,1.0;Build something real after every quest. Your notes belong in your Linux workshop.]"
    for i, q in ipairs(QUESTS) do
        local y = 1.7 + (i - 1) * 1.2
        local done = store:get_int("done/" .. name .. "/" .. q.id) == 1
        local status = done and "✓ " or "○ "
        form = form .. "button[0.6,"..y..";5.3,0.8;quest_"..q.id..";"..core.formspec_escape(status..q.title).."]" ..
            "label[6.2,"..(y+.19)..";"..core.formspec_escape(q.why).."]"
    end
    form = form .. "button_exit[10.5,9.1;2,0.6;exit;Close]"
    core.show_formspec(name, "wonderforge:atlas", form)
end

core.register_node("wonderforge:foundation", {
    description="Aetherstone foundation", tiles={tex.."foundation.png"},
    groups={cracky=2}, is_ground_content=false
})
core.register_node("wonderforge:bridge", {
    description="Skyglass bridge", tiles={tex.."bridge.png"},
    groups={cracky=2}, light_source=3, is_ground_content=false
})
core.register_node("wonderforge:hub", {
    description="Home island grass", tiles={tex.."hub.png"},
    groups={crumbly=2}, is_ground_content=false
})
core.register_node("wonderforge:lamp", {
    description="Beacon of discovery", tiles={tex.."lamp.png"},
    groups={cracky=3}, light_source=14, is_ground_content=false
})
for _, r in ipairs(REGION) do
    local color_name = r.color
    core.register_node("wonderforge:"..color_name, {
        description=r.name.." terrain", tiles={tex..color_name..".png"},
        groups={cracky=2}, is_ground_content=false
    })
    local node_name="wonderforge:portal_"..r.id
    local region_id=r.id
    local region_name=r.name
    local destination={x=r.x, y=15, z=r.z}
    core.register_node(node_name, {
        description="Portal to "..region_name, tiles={tex..color_name..".png^"..tex.."portal.png"},
        groups={cracky=3}, light_source=13, is_ground_content=false,
        on_rightclick=function(pos,node,clicker)
            teleport(clicker,destination,region_name)
        end,
    })
    core.register_node("wonderforge:return_"..r.id, {
        description="Portal home from "..region_name, tiles={tex.."hub.png^"..tex.."portal.png"},
        groups={cracky=3}, light_source=13, is_ground_content=false,
        on_rightclick=function(pos,node,clicker)
            teleport(clicker,CENTER,"the Invention Station")
        end,
    })
end
core.register_node("wonderforge:atlas", {
    description="Interactive inventor quest atlas", tiles={tex.."atlas.png"},
    groups={cracky=3}, light_source=11, is_ground_content=false,
    on_rightclick=function(_,_,clicker) if clicker then show_board(clicker) end end,
})

-- Pixel geometry is emitted only into freshly generated Luanti mapchunks.
-- This avoids a costly one-shot set_node loop or a huge VoxelManip on a 4GB Pi.
local function on_bridge(x,z,region)
    local px,pz=region.x,region.z
    local len2=px*px+pz*pz
    local u=(x*px+z*pz)/len2
    if u < .32 or u > .82 then return false end
    local dx=x-u*px; local dz=z-u*pz
    return dx*dx+dz*dz<=3.0
end
local function block_name(x,y,z)
    -- Precise, interactive nodes. Region pads are non-overlapping.
    if y == 13 then
        if x==0 and z==0 then return "wonderforge:lamp" end
        if x==-2 and z==-3 then return "wonderforge:atlas" end
        if x==2 and z==2 then return "wonderforge:lamp" end
        for _,r in ipairs(REGION) do
            local bx=math.floor(r.x*.53+.5);local bz=math.floor(r.z*.53+.5)
            -- A midpoint beacon on the bridge, reachable from the central island.
            if x==bx and z==bz then return "wonderforge:portal_"..r.id end
            if x==r.x-2 and z==r.z then return "wonderforge:return_"..r.id end
            if x==r.x+3 and z==r.z+3 then return "wonderforge:lamp" end
        end
    end
    -- A little lighthouse cap above each island.
    for _,r in ipairs(REGION) do
        if x==r.x+3 and z==r.z+3 and y>=14 and y<=18 then
            return y==18 and "wonderforge:lamp" or "wonderforge:foundation"
        end
    end
    if y < 5 or y > 12 then return nil end
    local d2=x*x+z*z
    if d2 <= 15*15 then
        local thickness=math.max(1,math.floor((15-math.sqrt(d2))*.44))
        if y>=12-thickness then return y==12 and "wonderforge:hub" or "wonderforge:foundation" end
    end
    for _,r in ipairs(REGION) do
        local dx=x-r.x;local dz=z-r.z;local dist2=dx*dx+dz*dz
        if dist2<=13*13 then
            local thickness=math.max(1,math.floor((13-math.sqrt(dist2))*.48))
            if y>=12-thickness then return y==12 and "wonderforge:"..r.color or "wonderforge:foundation" end
        end
    end
    for _,r in ipairs(REGION) do
        if on_bridge(x,z,r) then
            if y==12 then return "wonderforge:bridge" end
            if y==11 then return "wonderforge:foundation" end
        end
    end
    return nil
end

core.register_on_generated(function(minp,maxp)
    if maxp.y<5 or minp.y>19 or maxp.x < -64 or minp.x>64 or maxp.z < -64 or minp.z>64 then return end
    local vm,emin,emax=core.get_mapgen_object("voxelmanip")
    if not vm then return end
    local data=vm:get_data()
    local area=VoxelArea:new({MinEdge=emin,MaxEdge=emax})
    local ids={}
    local function cid(n)
        if not ids[n] then ids[n]=core.get_content_id(n) end
        return ids[n]
    end
    local modified=false
    for z=math.max(minp.z,-64),math.min(maxp.z,64) do
        for y=math.max(minp.y,5),math.min(maxp.y,19) do
            for x=math.max(minp.x,-64),math.min(maxp.x,64) do
                local node=block_name(x,y,z)
                if node then
                    data[area:index(x,y,z)]=cid(node)
                    modified=true
                end
            end
        end
    end
    if modified then
        vm:set_data(data)
        vm:write_to_map()
    end
end)

core.register_on_newplayer(function(player)
    core.after(1,function()
        if player and player:is_player() then teleport(player,CENTER,"WonderForge's Invention Station") end
    end)
end)
core.register_on_joinplayer(function(player)
    -- Singlenode mapgen is a sky void: recover players who fall below the world.
    core.after(3,function()
        if not player or not player:is_player() then return end
        if player:get_pos().y < -10 then player:set_pos(CENTER) end
        chat(player,"Welcome! Right-click the glowing Atlas or enter /forge to choose an adventure.")
    end)
end)
core.register_chatcommand("forge",{
    description="Open the WonderForge STEM quest atlas",
    func=function(name)
        local player=core.get_player_by_name(name)
        if player then show_board(player) end
        return true,"WonderForge Quest Atlas opened."
    end,
})
core.register_chatcommand("forgehome",{
    description="Return to the Invention Station",
    func=function(name)
        local player=core.get_player_by_name(name)
        if player then teleport(player,CENTER,"the Invention Station") end
        return true,"Returning to the hub."
    end,
})
core.register_on_player_receive_fields(function(player,formname,fields)
    if formname~="wonderforge:atlas" or not player or not player:is_player() then return end
    local pname=player:get_player_name()
    for _,quest in ipairs(QUESTS) do
        if fields["quest_"..quest.id] then
            local completed=store:get_int("done/"..pname.."/"..quest.id)
            local message="MISSION: "..quest.title.." | "..quest.challenge.." | WHY: "..quest.why
            chat(player,message)
            local form="formspec_version[4]size[12,6]"..
                "bgcolor[#102437;true]label[.5,.5;"..core.formspec_escape(quest.title).."]"..
                "textarea[.5,1.1;11,2.8;brief;CHALLENGE;"..core.formspec_escape(quest.challenge.."\n\n"..quest.why).."]"..
                "button[.5,4.7;5,.8;complete_"..quest.id..";"..(completed==1 and "MARK IN PROGRESS" or "I COMPLETED THE REAL-WORLD TASK").."]"..
                "button_exit[9.1,4.7;2.2,.8;exit;CLOSE]"
            core.show_formspec(pname,"wonderforge:mission",form)
            return
        end
    end
    if formname=="wonderforge:atlas" then return end
end)
core.register_on_player_receive_fields(function(player,formname,fields)
    if formname~="wonderforge:mission" or not player or not player:is_player() then return end
    for _,q in ipairs(QUESTS) do
        if fields["complete_"..q.id] then
            local key="done/"..player:get_player_name().."/"..q.id
            local new=store:get_int(key)==1 and 0 or 1
            store:set_int(key,new)
            chat(player, new==1 and "Quest complete! Record your evidence in Project Vault." or "Quest reset to in progress.")
            show_board(player)
            return
        end
    end
end)
