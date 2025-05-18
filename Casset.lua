
--local librarys
local vector = require 'vector'
local http = require 'gamesense/http'
local ease = require 'gamesense/easing'
local trace =  require 'gamesense/trace'
local images = require 'gamesense/images'
local base64 = require 'gamesense/base64'
local ent = require 'gamesense/entity'
local c_entity = require("gamesense/entity")
local clipboard = require 'gamesense/clipboard'
local steamworks = require 'gamesense/steamworks'
local anti_aim = require 'gamesense/antiaim_funcs'
local csgo_weapons = require 'gamesense/csgo_weapons'
local Surface = require("gamesense/surface")
local is_on_ground = false
local Panorama = panorama.open()
local get_absoluteframetime, globals_curtime, globals_realtime = globals.absoluteframetime, globals.curtime, globals.realtime
local database_read, database_write = database.read, database.write
local math_sin, math_pi, math_floor, math_random, math_min, math_max, math_abs = math.sin, math.pi, math.floor, client.random_int, math.min, math.max, math.abs
local ui_get, ui_set, ui_new_checkbox, ui_new_slider, ui_new_combobox, ui_new_listbox, ui_new_label, ui_set_visible, ui_reference, ui_new_hotkey = ui.get, ui.set, ui.new_checkbox, ui.new_slider, ui.new_combobox, ui.new_listbox, ui.new_label, ui.set_visible, ui.reference, ui.new_hotkey
local ui_menu_position, ui_new_multiselect, ui_menu_size, ui_is_menu_open, ui_mouse_position, ui_set_callback = ui.menu_position, ui.new_multiselect, ui.menu_size, ui.is_menu_open, ui.mouse_position, ui.set_callback
local client_color_log, client_screen_size, client_key_state, client_set_event_callback, client_userid_to_entindex, client_exec, client_delay_call = client.color_log, client.screen_size, client.key_state, client.set_event_callback, client.userid_to_entindex, client.exec, client.delay_call
local renderer_line, renderer_rectangle, renderer_gradient, renderer_text = renderer.line, renderer.rectangle, renderer.gradient, renderer.text
local entity_get_prop, entity_get_local_player, entity_get_player_name = entity.get_prop, entity.get_local_player, entity.get_player_name
jit.on()

local ffi = require("ffi")
if not pcall(ffi.sizeof, "ConvarInfo") then
	ffi.cdef([[
		typedef struct {
			char pad[0x14];
			int flags;
			char pad1[0x2c];
		} ConvarFlag;

		typedef struct {
			void** virtual_function_table;
			unsigned char pad[20];
			void* changeCallback;
			void* parent;
			const char* defaultValue;
			char* string;
			int m_StringLength;
			float m_fValue;
			int m_nValue;
			int m_bHasMin;
			float m_fMinVal;
			int m_bHasMax;
			float m_fMaxVal;
			void* onChangeCallbacks_memory;
			int onChangeCallbacks_allocationCount;
			int onChangeCallbacks_growSize;
			int onChangeCallbacks_size;
			void* onChangeCallbacks_elements;
		} ConvarInfo;
	]])
end
local entity_get_classname, entity_get_esp_data, entity_get_game_rules, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_player_resource, entity_get_player_weapon, entity_get_players, entity_get_prop, entity_hitbox_position, entity_is_alive, entity_is_dormant, entity_is_enemy, entity_set_prop = entity.get_classname, entity.get_esp_data, entity.get_game_rules, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_player_resource, entity.get_player_weapon, entity.get_players, entity.get_prop, entity.hitbox_position, entity.is_alive, entity.is_dormant, entity.is_enemy, entity.set_prop;
local globals_chokedcommands, globals_curtime, globals_frametime, globals_realtime, globals_tickcount, globals_tickinterval = globals.chokedcommands, globals.curtime, globals.frametime, globals.realtime, globals.tickcount, globals.tickinterval;

local function get_lib(lib)
    local succ, lib = pcall(require, lib)
    if not succ then error(string.format("Failed to load library %s", lib)) end
    return lib
end

local vars = {
    p_state = 1;
    p_state_ind = 1;
    m1_time = 0;
    choked = 0;

}

table.has = function(source, target)
    for id, name in pairs(source) do
        if name == target then
            return true
        end
    end

    return false
end

table.haskey = function(source, target)
    for id, name in pairs(source) do
        if id == target then
            return true
        end
    end

    return false
end

table.contains = function(source, target)
    local source_element = ui.get(source)
    for id, name in pairs(source_element) do
        if name == target then
            return true
        end
    end

    return false
end

local ConfigsList = database.read("[localtions]Configs") or {}
local ConfigsRaw = database.read("[localtions]Configs Raw") or {}



local slidewalk_directory = ui.reference("AA", "other", "leg movement")

local bit_band, bit_lshift, client_color_log, client_create_interface, client_delay_call, client_find_signature, client_key_state, client_reload_active_scripts, client_screen_size, client_set_event_callback, client_system_time, client_timestamp, client_unset_event_callback, database_read, database_write, entity_get_classname, entity_get_local_player, entity_get_origin, entity_get_player_name, entity_get_prop, entity_get_steam64, entity_is_alive, globals_framecount, globals_realtime, math_ceil, math_floor, math_max, math_min, panorama_loadstring, renderer_gradient, renderer_line, renderer_rectangle, table_concat, table_insert, table_remove, table_sort, ui_get, ui_is_menu_open, ui_mouse_position, ui_new_checkbox, ui_new_color_picker, ui_new_combobox, ui_new_slider, ui_set, ui_set_visible, setmetatable, pairs, error, globals_absoluteframetime, globals_curtime, globals_frametime, globals_maxplayers, globals_tickcount, globals_tickinterval, math_abs, type, pcall, renderer_circle_outline, renderer_load_rgba, renderer_measure_text, renderer_text, renderer_texture, tostring, ui_name, ui_new_button, ui_new_hotkey, ui_new_label, ui_new_listbox, ui_new_textbox, ui_reference, ui_set_callback, ui_update, unpack, tonumber = bit.band, bit.lshift, client.color_log, client.create_interface, client.delay_call, client.find_signature, client.key_state, client.reload_active_scripts, client.screen_size, client.set_event_callback, client.system_time, client.timestamp, client.unset_event_callback, database.read, database.write, entity.get_classname, entity.get_local_player, entity.get_origin, entity.get_player_name, entity.get_prop, entity.get_steam64, entity.is_alive, globals.framecount, globals.realtime, math.ceil, math.floor, math.max, math.min, panorama.loadstring, renderer.gradient, renderer.line, renderer.rectangle, table.concat, table.insert, table.remove, table.sort, ui.get, ui.is_menu_open, ui.mouse_position, ui.new_checkbox, ui.new_color_picker, ui.new_combobox, ui.new_slider, ui.set, ui.set_visible, setmetatable, pairs, error, globals.absoluteframetime, globals.curtime, globals.frametime, globals.maxplayers, globals.tickcount, globals.tickinterval, math.abs, type, pcall, renderer.circle_outline, renderer.load_rgba, renderer.measure_text, renderer.text, renderer.texture, tostring, ui.name, ui.new_button, ui.new_hotkey, ui.new_label, ui.new_listbox, ui.new_textbox, ui.reference, ui.set_callback, ui.update, unpack, tonumber

local SetClientLanguege = vtable_bind("vgui2.dll", "VGUI_Scheme010", 17, "void(__thiscall*)(void*, const char*)")
SetClientLanguege("schinese")

local dragging_fn = function(name, base_x, base_y) return (function()
	local a={}local b,c,d,e,f,g,h,i,j,k,l,m,n,o;
	local p={__index={
		drag=function(self,...)
			local q,r=self:get()
			local s,t=a.drag(q,r,...)
			--if q~=s or r~=t then
			if r~=t then
				self:set(q,t)
			end;

			return s,t
		end,

		set=function(self,q,r)
			local j,k=client_screen_size()ui_set(self.x_reference,q/j*self.res)ui_set(self.y_reference,r/k*self.res)
		end,

		get=function(self)local j,k=client_screen_size()return ui_get(self.x_reference)/self.res*j,ui_get(self.y_reference)/self.res*k end}}function a.new(u,v,w,x)x=x or 10000;local j,k=client_screen_size()local y=ui_new_slider('LUA','A',u..' window position',0,x,v/j*x)local z=ui_new_slider('LUA','A','\n'..u..' window position y',0,x,w/k*x)ui_set_visible(y,false)ui_set_visible(z,false)return setmetatable({name=u,x_reference=y,y_reference=z,res=x},p)end;function a.drag(q,r,A,B,C,D,E)if globals_framecount()~=b then c=ui_is_menu_open()f,g=d,e;d,e=ui_mouse_position()i=h;h=client_key_state(0x01)==true;m=l;l={}o=n;n=false;j,k=client_screen_size()end;if c and i~=nil then if(not i or o)and h and f>q and g>r and f<q+A and g<r+B then n=true;q,r=q+d-f,r+e-g;if not D then q=math_max(0,math_min(j-A,q))r=math_max(0,math_min(k-B,r))end end end;table_insert(l,{q,r,A,B})return q,r,A,B end;return a end)().new(name, base_x, base_y) end
--menu function
local main = function()
    local tab, container = "AA", "Anti-aimbot angles"

    local antiaim_elements = {}

    local aa_tab, misc_tab, vis_tab, cfg_tab
    local obex_data = obex_fetch and obex_fetch() or {username = "Przunxible", build = "update"}

    local status = {
        build = obex_data.build:lower();
        version = "Last version";
        last_update = "12-Feb-24";
        username = obex_data.username:lower();
    }

    local colors = {
        main = "\aB9B7F1FF";
        main_rgba = { 185, 181, 241, 255 };
        main_rgbb = { 255, 255, 255, 220 };
        main_rgb = { 185, 181, 241 };
        white = "\aFFFFFFCE";
        grey = "\aFFFFFF8D";
    }

    local clamp = function(b, c, d) return math.min(d, math.max(c, b)) end

    local dpi_scale = ui.reference("MISC", "Settings", "DPI scale")
    local gscale = tonumber(ui.get(dpi_scale):sub(1, -2)) / 100

    local gmenu_size = { default = { w = 75, h = 64 }, w = 75, h = 64, x = 6, y = 20 }

    ui.set_callback(ui.reference("MISC", "Settings", "DPI scale"), function(args)
        dpi = tonumber(ui.get(args):sub(1, 3)) * 0.01
        gmenu_size.w = gmenu_size.default.w * dpi
        gmenu_size.h = gmenu_size.default.h * dpi
    end, true)

    -- Header related
    local images_links = {
 -- logo
        "https://imgos.cn/2024/08/08/66b3e3d53a310.png"; -- antiaim
        "https://imgos.cn/2024/08/08/66b3e3d52a5d8.png"; -- visuals
        "https://imgos.cn/2024/08/08/66b3e3d52b341.png"; -- misc
        "https://imgos.cn/2024/08/08/66b3e3d513afe.png"; -- cfg
    }

    local header = {
        draw_box = function(x, y, w, h, alpha)
            -- Box
            renderer.rectangle(x, y, w, h, 88, 88, 88, 155)
            renderer.rectangle(x + 1, y + 1, w - 2, h + 2, 200, 200, 200, 50)
            renderer.rectangle(x + 2, y + 2, w - 4, h + 4, 40, 40, 40, 20)
            renderer.rectangle(x + 5, y + 5, w - 10, h + 10, 60, 60, 60, 20)
            --renderer.rectangle(x + 6, y + 6, w - 12, h + 12, 12, 12, 12, alpha)

            -- Gradient
            renderer.gradient(x + 7, y + 7, w / 2, 2, 185, 181, 241, 255, 255, 255, 255, 0, true)
            renderer.gradient(x + w / 2, y + 7, w / 2 - 6, 2, 255, 255, 255, 0, 185, 181, 241, 255, true)
            renderer.line(x + 7, y + 8, x + w - 6, y + 8, 255, 255, 255, 10)
        end;

        get_images = function (self, link, index)
            local db_read = database.read(link) 
            if db_read then
                self.images[index] = images.load_png(db_read)
            else
                http.get(link, function(success, response)
                    if not success or response.status ~= 200 then
                        client.delay_call(5, image_recursive)
                    else
                        self.images[index] = images.load_png(response.body)
                        database.write(link, response.body)
                    end
                end)
            end
        end;

        init = function(self)
            self.images = {}
            for i, link in pairs(images_links) do
                self:get_images(link, i)
            end
        end;

        update = function(self)
            local menu_pos = {ui.menu_position()}
            local menu_size = {ui.menu_size()}
            gscale = tonumber(ui.get(dpi_scale):sub(1, -2)) / 100

            self.height = 37.5 * gscale
            self.width = menu_size[1]

            self.x, self.y, self.w, self.h = menu_pos[1], menu_pos[2] - self.height, self.width, self.height
        end;
    }
    header:init()

    -- Mouse related funcs

    local mouse = {
        is_within = function(px, py, x, y, w, h)
            return px > x and px < x + w and py > y and py < y + h
        end;

        hover_applicable = function(self, x, y, w, h)
            return self.is_within(self.mouse_x, self.mouse_y, x, y, w, h)
        end;

        click_applicable = function(self, x, y, w, h, name)
            if not self.is_within(self.mouse_x, self.mouse_y, header.x, header.y, header.w, header.h) then
                return
            end

            if self.got_click and client.key_state(0x01) then
                if self.is_within(self.click_x, self.click_y, x, y, w, h) then
                    return true
                end
            end
            return false
        end;

        init = function(self)
            self.got_click, self.off_click = false, false
            self.click_x, self.click_y, self.mouse_x, self.mouse_y = 0, 0, 0, 0
            self.header_index = database.read("header_index")

            aa_tab   = self.header_index == 1
            misc_tab = self.header_index == 3
            vis_tab  = self.header_index == 2
            cfg_tab  = self.header_index == 4
        end;

        listen = function(self)
            self.mouse_x, self.mouse_y = ui.mouse_position()
            if client.key_state(0x01) and ui.is_menu_open() then
                self.off_click = true
                if not self.got_click then
                    self.click_x, self.click_y = ui.mouse_position()
                    self.got_click = true
                end
            else
                if self.off_click then
                    self.off_click = false
                    self.got_click = false
                end
            end
        end;
    }
    mouse:init()

    -- Standalone menu alpha calcu-malator
    local menu_key = {ui.get(ui.reference("MISC", "Settings", "Menu key"))}
    function get_menu_alpha()local a=ui.is_menu_open()local b=0;if a~=last_state then draw_swap=globals.curtime()last_state=a end;local c=0.07;if not ignore_next and client.key_state(menu_key[3])then is_closing=true else if not client.key_state(menu_key[3])then ignore_next=false end end;local d=state;local e;if ui.is_menu_open()then if is_closing then state="closed"e=false else state="open"e=true end else is_closing=false;e=false;ignore_next=true;state="closed"end;if d~=state then swap_time=globals.curtime()end;b=clamp((swap_time+c-globals.curtime())/c,0,1)b=(e and a and 1-b or b)*255;return b end

    local m1_down = false
    local skeet_selected_tab = 0

    local check_skeet_tab = function()
        local pos = { ui.menu_position() }
        local m_pos = { ui.mouse_position() }

        for i = 1, 9 do
            local Offset = { gmenu_size.x, gmenu_size.y + gmenu_size.h * (i - 1) }
            if m_pos[1] >= pos[1] + Offset[1] and m_pos[1] <= pos[1] + gmenu_size.w + Offset[1] and m_pos[2] >= pos[2] + Offset[2] and m_pos[2] <= pos[2] + gmenu_size.h + Offset[2] then
                return i
            end
        end

        return skeet_selected_tab
    end

    local function is_aa_tab()
        if not m1_down and client.key_state(0x01) then
            m1_down = true
            skeet_selected_tab = check_skeet_tab()
        end

        if not client.key_state(0x01) then
            m1_down = false
        end

        return skeet_selected_tab == 2 and true or false
    end

    client.set_event_callback("paint_ui", function()  
        local alpha = get_menu_alpha()
        if alpha > 0 and ui.is_menu_open() then--and is_aa_tab() then 
            -- Capture mouse events
            mouse:listen()

            -- Update header info
            header:update()

            -- Button bounds
            header.draw_box(header.x, header.y, header.w, header.h, alpha, true)

            local sections = 4
            local sub_w = (header.w / sections) - 2.5
            for i = 1, sections do
                -- Section bounds
                local sx, sy, sw, sh = header.x + 7 + ((i - 1) * sub_w), header.y + 9, sub_w, header.h - 9

                -- Check for recent clicks
                if mouse:click_applicable(sx, sy, sw, sh, i) then
                    mouse.header_index = i
                    database.write("header_index", i)

                    aa_tab   = i == 1
                    misc_tab = i == 3
                    vis_tab  = i == 2
                    cfg_tab  = i == 4
                end

                -- Section bars
                if i ~= sections then
                    local line_gap = sh * 0.1
                    renderer.rectangle(sx + sw, sy + line_gap, 1, sh - (line_gap * 2), 26, 26, 26, alpha) 
                end

                -- Section Images
                if header.images[i] then
                    local is_hovering = mouse:hover_applicable(sx, sy, sw, sh)
                    local rescale = 0.8
                    local iw, ih = i == 0 and sh or sh * rescale, i == 0 and sh or sh * rescale
                    local ix, iy = sx + (sw * 0.5) - (iw * 0.5), sy + (sh * 0.5) - (ih * 0.5)
                    header.images[i]:draw(ix, iy, iw, ih, colors.main_rgba[1], colors.main_rgba[2], colors.main_rgba[3], alpha * (mouse.header_index == i and 1 or (is_hovering and 0.5 or 0.2)), false, "f")
                end
            end
        end
    end)
    client.set_event_callback("setup_command", function(cmd)
        local sections = 4
        local sub_w = (header.w / sections) - 2.5
        for i = 1, sections do
            -- Section bounds
            local sx, sy, sw, sh = header.x + 7 + ((i - 1) * sub_w), header.y + 9, sub_w, header.h - 9
            if mouse:hover_applicable(sx, sy, sw, sh) then
                cmd.in_attack = 0
            end
        end
        
    end)
    local anim_label = ui.new_label(tab, container, colors.main .. "ε.lua")
    local text11234 = ui.new_label(tab, container, colors.main .. "\n")

    local reference = {
        enabled = ui.reference(tab, container, "Enabled"),
        enablefl = ui.reference(tab, "Fake lag", "Enabled"),
        double_tap = {ui.reference('RAGE', 'Aimbot', 'Double tap')},
        duck_peek_assist = ui.reference('RAGE', 'Other', 'Duck peek assist'),
        pitch = {ui.reference(tab, container, 'Pitch')},
        yaw_base = ui.reference(tab, container, 'Yaw base'),
        yaw = {ui.reference(tab, container, 'Yaw')},
        yaw_jitter = {ui.reference(tab, container, 'Yaw jitter')},
        body_yaw = {ui.reference(tab, container, 'Body yaw')},
        freestanding_body_yaw = ui.reference(tab, container, 'Freestanding body yaw'),
        edge_yaw = ui.reference(tab, container, 'Edge yaw'),
        freestanding = {ui.reference(tab, container, 'Freestanding')},
        roll = ui.reference(tab, container, 'Roll'),
        on_shot_anti_aim = {ui.reference('AA', 'Other', 'On shot anti-aim')},
        lm = ui.reference(tab, "Other", "Leg movement"),
        slow_motion = {ui.reference('AA', 'Other', 'Slow motion')},
        fl_limit = ui.reference(tab, "Fake lag", "Limit"),
        fl_amount = ui.reference(tab, "Fake lag", "Amount"),
        fl_var = ui.reference(tab, "Fake lag", "Variance"),
        fakelag = {ui.reference(tab, "Fake lag", "Limit")},
        force_body = ui.reference("Rage", "Aimbot", "Force body aim"),
        min_damage_override = {ui.reference("Rage", "Aimbot", "Minimum damage override")},
    }
    
    local globals_frametime = globals.frametime
    local globals_tickinterval = globals.tickinterval
    local entity_is_enemy = entity.is_enemy
    local entity_is_dormant = entity.is_dormant
    local entity_is_alive = entity.is_alive
    local entity_get_origin = entity.get_origin
    local entity_get_player_resource = entity.get_player_resource
    local table_insert = table.insert
    local math_floor = math.floor
    
    local last_press = 0
    local direction = 0
    local anti_aim_on_use_direction = 0
    local cheked_ticks = 0
    
    local E_POSE_PARAMETERS = {
        STRAFE_YAW = 0,
        STAND = 1,
        LEAN_YAW = 2,
        SPEED = 3,
        LADDER_YAW = 4,
        LADDER_SPEED = 5,
        JUMP_FALL = 6,
        MOVE_YAW = 7,
        MOVE_BLEND_CROUCH = 8,
        MOVE_BLEND_WALK = 9,
        MOVE_BLEND_RUN = 10,
        BODY_YAW = 11,
        BODY_PITCH = 12,
        AIM_BLEND_STAND_IDLE = 13,
        AIM_BLEND_STAND_WALK = 14,
        AIM_BLEND_STAND_RUN = 14,
        AIM_BLEND_CROUCH_IDLE = 16,
        AIM_BLEND_CROUCH_WALK = 17,
        DEATH_YAW = 18
    }

    local RgbaToHexText = function(colors, text)
	return ("\a%02x%02x%02x%02x%s"):format(colors[1], colors[2], colors[3], colors[4], text)
    end

    local function contains(source, target)
        for id, name in pairs(ui.get(source)) do
            if name == target then
                return true
            end
        end
    
        return false
    end
    local recorded_max_tickbase = 0
    local defensive_wait_ticks = 0
    local function is_defensive(index)
        cheked_ticks = math.max(entity.get_prop(index, 'm_nTickBase'), cheked_ticks or 64)
        if math.abs(entity.get_prop(index, 'm_nTickBase') - cheked_ticks) > 64 then
            recorded_max_tickbase = math.abs(entity.get_prop(index, 'm_nTickBase') - cheked_ticks)
        end
        return math.abs(entity.get_prop(index, 'm_nTickBase') - cheked_ticks-1) ~= 1 and math.abs(entity.get_prop(index, 'm_nTickBase') - cheked_ticks-1) < 14
    end
    
    local settings = {}
    local anti_aim_settings = {}
    local anti_aim_states = {'Global', 'Standing', 'Moving', 'Slow motion', 'Crouch', 'Crouch Move', 'Air', 'Air Crouch', 'Fakelag', 'Legit'}
    local anti_aim_different = {'', ' ', '  ', '   ', '    ', '     ', '      ', '       ', '        ', '         '}
    
    local text4 = ui.new_label(tab, "Fake lag", colors.main .. "‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾")
    local builderchoice = ui.new_combobox(tab, "Fake lag", '\nbuilder', 'Builder','Keybinds', 'Defensive')
    settings.anti_aim_state = ui.new_combobox(tab, container, colors.main ..' ➥\aFFFFFF9B  State    -----------------------------------', anti_aim_states)
    local winpos = ui.new_combobox(tab, container,colors.main .." •  \aFFFFFFCEESP Preview", "-", "Left", "Right")
    local master_switch = ui.new_checkbox(tab, container, '\aFFFFFF9B •  Log Aimbot Shots')
    local console_filter = ui.new_checkbox(tab, container, '\aFFFFFF9B •  Console Filter')
    local m_elements = ui.new_multiselect(tab, container, colors.main .." •  \aFFFFFFCEAnimations", {"Body lean", "Slide slow-walking", "Pitch 0 onland", "Leg Breaker-in air", "Leg Breaker-landing", "Moonwalk"})
    local slide_elements = ui.new_multiselect("AA", "Fake lag", colors.main .."• \aFFFFFFCESliding elements", {"While walking", "While running", "While crouching"})
    local body_lean_value = ui.new_slider("AA", "Fake lag", colors.main .."• \aFFFFFFCEBody lean value", 0, 100, 0, true, "%", 0.01, {[0] = "Disabled", [35] = "Small", [50] = "Medium", [75] = "High", [100] = "Extreme"})
    local break_air_value = ui.new_slider("AA", "Fake lag", colors.main .."• \aFFFFFFCEBreakable air value", 0, 10, 5, true, "%", 0.1, {[0] = "Disabled", [5] = "Default", [10] = "Maximum"})
    local force_safe_point = ui.reference('RAGE', 'Aimbot', 'Force safe point')
    local trashtalk = ui.new_checkbox(tab, container, '\aFFFFFF9B •  Trash Talk')
    local clantagchanger = ui.new_checkbox(tab, container, colors.main .. ' •  \aFFFFFFCEClan Tag')
    local fastladder = ui.new_checkbox(tab, container, '\aFFFFFF9B •  Fast Ladder')
    local hitmarker = ui.new_checkbox(tab, container, '\aFFFFFF9B •  Hit Marker')
    local ManualIndication = ui.new_checkbox(tab, container, ("%s %s"):format(RgbaToHexText({185, 181, 255, 255}, " • "), RgbaToHexText({255, 255, 255, 206}, "Manual Arrows")))
    local ManualColor = ui.new_color_picker(tab, container, "Manual Color", 185, 181, 255, 255)
    local ManualArrowStyle = ui.new_combobox(tab, container, "\nManual style", {"Mini", "<>", "⯇⯈"})
    local CrosshairIndication = ui.new_checkbox(tab, container, ("%s %s"):format(RgbaToHexText({185, 181, 255, 255}, " • "), RgbaToHexText({255, 255, 255, 206}, "Crosshair ind")))
    local CrosshairStyle = ui.new_combobox(tab, container, "\nPattern", {"Concen", "Manifold"})
    local CrosshairNameStyle = ui.new_combobox(tab, container, "Style", {"Desync", "Color Side", "Animation"})
    local CrosshairBarLabel = ui.new_label(tab, container, " •  \aFFFFFFCEBar Color")
    local CrosshairBarColor = ui.new_color_picker(tab, container, " •  \aFFFFFFCEBar Color\nBar Color", 185, 181, 255, 255)
    local CrosshairRealSideLabel = ui.new_label(tab, container, " •  \aFFFFFFCEMain Color")
    local CrosshairRealSideColor = ui.new_color_picker(tab, container, " •  \aFFFFFFCEMain Color\n Color", 255, 255, 255, 255)
    local CrosshairFakeSideLabel = ui.new_label(tab, container, " •  \aFFFFFFCEMinor Color")
    local CrosshairFakeSideColor = ui.new_color_picker(tab, container, " •  \aFFFFFFCEMinor Color\n Color", 185, 181, 255, 255)
    local CrosshairAnimationStyle = ui.new_combobox(tab, container, "\aFFFFFF9B •  Animation Style", {"Stationary", "Opposite", "Directory"})
    local CrosshairAnimationSide = ui.new_combobox(tab, container, "\aFFFFFF9B •  Animation Side", {"Default", "Reversed", "Repeatedly"})
    local CrosshairHotkeyStyle = ui.new_multiselect(tab, container, "\aFFFFFF9B •  Hotkeys Style", {"Simplicity", "Complete"})
    local CrosshairHotkeysDoubleTapLabel = ui.new_label(tab, container,  " •  \aFFFFFFCEDT Color")
    local CrosshairHotkeysDoubleTapColor = ui.new_color_picker(tab, container, " •  \aFFFFFFCEDT Color\n Color", 255, 255, 255, 255)
    local CrosshairHotkeysonshotLabel = ui.new_label(tab, container, "\aFFFFFF9B •  Hide Color")
    local CrosshairHotkeysonshotColor = ui.new_color_picker(tab, container, "\aFFFFFF9B •  Hide Color\n Color", 185, 181, 255, 255)
    local CrosshairHotkeysOtherLabel = ui.new_label(tab, container, "\aFFFFFF9B •  Other Color")
    local CrosshairHotkeysOtherColor = ui.new_color_picker(tab, container, "\aFFFFFF9B •  Other Color\n Color", 185, 181, 255, 255)
    local CrosshairHotkeysExtraLabel = ui.new_label(tab, container,  " •  \aFFFFFFCEComplete Color")
    local CrosshairHotkeysExtraColor = ui.new_color_picker(tab, container, " •  \aFFFFFFCEComplete Color\n Color", 185, 181, 255, 255)
    local CrosshairHotkeySettings = ui.new_multiselect(tab, container, "Hotkey Settings", {"Fraction", "Thickness", "Animation Speed"})
    local lag_debug =  ui.new_checkbox(tab, container,  ' •  \aFFFFFFCELag debug')
    local resolver =  ui.new_checkbox(tab, container,  ' •  \aFFFFFFCECasset Resolver[beta]')
    local HitlogIndication = ui.new_checkbox(tab, container, colors.main .." •  \aFFFFFFCEHitlogs")
    local HitlogColor = ui.new_color_picker(tab, container, "Hitlog Color", 255, 255, 255, 255)
    local HitlogStyle = ui.new_combobox(tab, container, "\aFFFFFF9B •  Style", {"Novel","-"})
    local HitlogBackgroundStyle = ui.new_combobox(tab, container, "\nBackground", {"Blur", "Rect"})
    
    
    local CachedLerp = {}
    local IsDefensiveForce = false
    local PlayerStateName = "default"
    local CachedStaticSingleAnimation = {}
    local RelativeAnimationTextSwitch = {}
    local StaticAnimationTextSwitch = {}
    local CachedSurfaceFont = {}
    local CachedStaticConditionAnimation = {}
    Lerp = function(current, target, percentage)
	if type(current) == "table" and type(target) == "table" then
		return {
			Lerp(current[1] or current.x or 0, target[1] or target.x or 0, percentage),
			Lerp(current[2] or current.y or 0, target[2] or target.y or 0, percentage),
			Lerp(current[3] or current.z or 0, target[3] or target.z or 0, percentage),
			Lerp(current[4] or current.w or 0, target[4] or target.w or 0, percentage)
		}
	end

	return current + ((target - current) * percentage)
    end

    local CreateSurfaceFont = function(name, size, width, flags)
	local CachedKey = ("%s%s%s%s"):format(name, size, width, table.concat(flags or {}))
	if not CachedSurfaceFont[CachedKey] then
		CachedSurfaceFont[CachedKey] = Surface.create_font(name, size, width, flags)
	end

	return CachedSurfaceFont[CachedKey]
    end

    local NewLerp = function(current, target, animation, key)
	if not CachedLerp[key] then
		CachedLerp[key] = current
	end

	local frametime = globals.frametime() * (animation / 10)
	if math.abs(target - CachedLerp[key]) < 0.001 then
		CachedLerp[key] = target
		return target
	end

	CachedLerp[key] = Lerp(CachedLerp[key], target, frametime)
	return target > CachedLerp[key] and math.min(CachedLerp[key], target) or math.max(CachedLerp[key], target)
    end

    local CreateStaticTargetAnimation = function(current, target, animation, key)
	if not CachedStaticSingleAnimation[key] then
		CachedStaticSingleAnimation[key] = current
	end

	local frametime = globals.frametime() * (animation / 10)
	local delta = target > CachedStaticSingleAnimation[key] and frametime or - frametime
	if math.abs(target - CachedStaticSingleAnimation[key]) < frametime then
		return target
	end

	CachedStaticSingleAnimation[key] = CachedStaticSingleAnimation[key] + delta
	return target > CachedStaticSingleAnimation[key] and math.min(CachedStaticSingleAnimation[key], target) or math.max(CachedStaticSingleAnimation[key], target)
   end

   local GetClientEntity = vtable_bind("client.dll", "VClientEntityList003", 3, "void*(__thiscall*)(void*, int)")
   local GGetEyePosition = ffi.cast("Vector(__thiscall*)(void*)", client.find_signature("client.dll", "\x55\x8B\xEC\x56\x8B\xF1\x8B\x06\xFF\x50\x28"))
   local GetEyePosition = function(player)
	local vecEye = GGetEyePosition(GetClientEntity(player))
	return vector(vecEye.x, vecEye.y, vecEye.z)
   end

   local ExtrapolatePosition = function(player, origin, ticks)
	if not entity.is_alive(player) then
		return origin
	end

	local Velocity = vector(entity.get_prop(player, "m_vecVelocity"))
	return origin + ((Velocity * globals.tickinterval()) * ticks)
   end

    local CanAttack = function(player, only_fire, adder)
	if not player or not entity.is_alive(player) then
		return false
	end

	local ActiveWeapon = entity.get_player_weapon(player)
	if not ActiveWeapon then
		return false
	end

	local NextAttack = entity.get_prop(player, "m_flNextAttack")
	local SimulationTme = entity.get_prop(player, "m_flSimulationTime")
	local PrimaryAttack = entity.get_prop(ActiveWeapon, "m_flNextPrimaryAttack")
	local WeaponIndex = entity.get_prop(ActiveWeapon, "m_iItemDefinitionIndex")
	local SecondaryAttack = entity.get_prop(ActiveWeapon, "m_flNextSecondaryAttack")
	if WeaponIndex == 64 then
		return SimulationTme > PrimaryAttack
	end

	return SimulationTme > (only_fire and (PrimaryAttack + (adder or 0)) or math.max(NextAttack, PrimaryAttack, SecondaryAttack))
    end

    local RectangleOutline = function(x, y, w, h, round, thickness, color, settings, round_percentage)
	if color[4] <= 0 or thickness <= 0 then
		return
	end

	local Radius = math.min(w / 2, h / 2, round)
	local Condition = settings or {true, true, true, true, true, true}
	if Radius == 0 then
		renderer.rectangle(x, y, w, thickness, color[1], color[2], color[3], color[4])
		renderer.rectangle(x, y + h - thickness, w, thickness, color[1], color[2], color[3], color[4])
	else
		local RoundPercentage = round_percentage or 0.25
		local RoundRadiusPercentage = RoundPercentage / 0.25
		if Condition[1] then
			renderer.rectangle(x + Radius, y, w - Radius * 2, thickness, color[1], color[2], color[3], color[4])
		end

		if Condition[2] then
			renderer.rectangle(x + Radius, y + h - thickness, w - Radius * 2, thickness, color[1], color[2], color[3], color[4])
		end

		if Condition[3] or Condition[1] then
			renderer.circle_outline(x + Radius, y + Radius, color[1], color[2], color[3], color[4], Radius, 180, RoundPercentage, thickness)
		end

		if Condition[4] or Condition[2] then
			renderer.circle_outline(x + Radius, y + h - Radius, color[1], color[2], color[3], color[4], Radius, 90 + ((1 - RoundRadiusPercentage) * 90), RoundPercentage, thickness)
		end

		if Condition[5] or Condition[1] then
			renderer.circle_outline(x + w - Radius, y + Radius, color[1], color[2], color[3], color[4], Radius, - 90 + ((1 - RoundRadiusPercentage) * 90), RoundPercentage, thickness)
		end

		if Condition[6] or Condition[2] then
			renderer.circle_outline(x + w - Radius, y + h - Radius, color[1], color[2], color[3], color[4], Radius, 0, RoundPercentage, thickness)
		end

		if Condition[3] or Condition[4] then
			renderer.rectangle(x, y + Radius, thickness, h - Radius * 2, color[1], color[2], color[3], color[4])
		end

		if Condition[5] or Condition[6] then
			renderer.rectangle(x + w - thickness, y + Radius, thickness, h - Radius * 2, color[1], color[2], color[3], color[4])
		end
	end
    end

    local RenderRoundRectangle = function(x, y, w, h, radius, color)
	if color[4] <= 0 then
		return
	end

	renderer.rectangle(x, y + radius, radius, h - radius * 2, color[1], color[2], color[3], color[4])
	renderer.rectangle(x + radius, y, w - radius * 2, radius, color[1], color[2], color[3], color[4])
	renderer.circle(x + radius, y + radius, color[1], color[2], color[3], color[4], radius, 180, 0.25)
	renderer.circle(x + radius, y + h - radius, color[1], color[2], color[3], color[4], radius, 270, 0.25)
	renderer.rectangle(x + radius, y + h - radius, w - radius * 2, radius, color[1], color[2], color[3], color[4])
	renderer.rectangle(x + radius, y + radius, w - radius * 2, h - radius * 2, color[1], color[2], color[3], color[4])
	renderer.circle(x + w - radius, y + radius, color[1], color[2], color[3], color[4], radius, 90, 0.25)
	renderer.circle(x + w - radius, y + h - radius, color[1], color[2], color[3], color[4], radius, 0, 0.25)
	renderer.rectangle(x + w - radius, y + radius, radius, h - radius * 2, color[1], color[2], color[3], color[4])
    end

    local RenderGlowOutline = function(x, y, w, h, width, rounding, color, settings, round_percentage)
	if color[4] <= 0 then
		return
	end

	for index = 0, width do
		if color[4] * (index / width) > 5 then
			local GlowAccentColor = {color[1], color[2], color[3], color[4] * (index / width) ^ 2}
			if GlowAccentColor[4] > 0 then
				RectangleOutline(x + (index - width), y + (index - width), w - (index - width - 1) * 2, h + 2 - (index - width) * 2, rounding + 1 * (width - index + 1), 1, GlowAccentColor, settings, round_percentage)
			end
		end
	end
    end
    local RgbaToHexGradientText = function(color_1, color_2, text)
	local gradient_text = ""
	for index = 1, text:len() do
		local current_text = text:sub(index, index)
		local current_color = Lerp(color_1, color_2, index / text:len())
		gradient_text = ("%s%s"):format(gradient_text, RgbaToHexText(current_color, current_text))
	end

	return gradient_text
    end

    local players = {}

local res_data = {
    records = {},
    get_max_desync = function(animstate)
        local speedfactor = func.clamp(animstate.feet_speed_forwards_or_sideways, 0, 1)
        local avg_speedfactor = (animstate.stop_to_full_running_fraction * -0.3 - 0.2) * speedfactor + 1

        local duck_amount = animstate.duck_amount
        if duck_amount > 0 then
            local duck_speed = duck_amount * speedfactor

            avg_speedfactor = avg_speedfactor + (duck_speed * (0.5 - avg_speedfactor))
        end

        return func.clamp(avg_speedfactor, .5, 1)
    end,
    get_simtime = function(ent)
        local pointer = native_get_client_entity(ent)
        if pointer then
            return entity.get_prop(ent, "m_flSimulationTime"),
                ffi.cast("float*", ffi.cast("uintptr_t", pointer) + 0x26C)[0]
        else
            return 0
        end
    end,
    get_animstate = function(ent)
        local pointer = native_get_client_entity(ent)
        if pointer then
            return ffi.cast(
                ffi.typeof 'struct { char pad0[0x18]; float anim_update_timer; char pad1[0xC]; float started_moving_time; float last_move_time; char pad2[0x10]; float last_lby_time; char pad3[0x8]; float run_amount; char pad4[0x10]; void* entity; void* active_weapon; void* last_active_weapon; float last_client_side_animation_update_time; int	 last_client_side_animation_update_framecount; float eye_timer; float eye_angles_y; float eye_angles_x; float goal_feet_yaw; float current_feet_yaw; float torso_yaw; float last_move_yaw; float lean_amount; char pad5[0x4]; float feet_cycle; float feet_yaw_rate; char pad6[0x4]; float duck_amount; float landing_duck_amount; char pad7[0x4]; float current_origin[3]; float last_origin[3]; float velocity_x; float velocity_y; char pad8[0x4]; float unknown_float1; char pad9[0x8]; float unknown_float2; float unknown_float3; float unknown; float m_velocity; float jump_fall_velocity; float clamped_velocity; float feet_speed_forwards_or_sideways; float feet_speed_unknown_forwards_or_sideways; float last_time_started_moving; float last_time_stopped_moving; bool on_ground; bool hit_in_ground_animation; char pad10[0x4]; float time_since_in_air; float last_origin_z; float head_from_ground_distance_standing; float stop_to_full_running_fraction; char pad11[0x4]; float magic_fraction; char pad12[0x3C]; float world_force; char pad13[0x1CA]; float min_yaw; float max_yaw; } **',
                ffi.cast("char*", ffi.cast("void***", pointer)) + 0x9960)[0]
        end
    end

}

    local CreateAnimationText = function(text, colors_1, colors_2, speed, is_reserved, automatic_reversed)
	local fraction_list = {}
	local current_text = ""
	if #text <= 0 then
		return ""
	end

	local text_length = #text
	local animation_reversed = is_reserved
	local maximized_different = text_length * 5
	local animation_smooth = globals.curtime() / (11 - (speed / 10))
	if automatic_reversed then
		animation_reversed =StaticAnimationTextSwitch[text]
	end

	for index = 1, #text do
		local between = math.abs((index * 5) / maximized_different)
		fraction_list[index] = math.abs(1 * math.cos(2 * math.pi * animation_smooth + (animation_reversed and between or - between)))
	end

	for index, fraction in pairs(fraction_list) do
		local this_color = Lerp(colors_1, colors_2, fraction)
		current_text = ("%s%s"):format(current_text, RgbaToHexText(this_color, text:sub(index, index)))
	end

	if automatic_reversed then
		if not StaticAnimationTextSwitch[text] then
			StaticAnimationTextSwitch[text] = false
		end

		if not StaticAnimationTextSwitch[text] and fraction_list[1] >= 0.99 then
			StaticAnimationTextSwitch[text] = true
		elseif StaticAnimationTextSwitch[text] and fraction_list[1] <= 0.01 then
			StaticAnimationTextSwitch[text] = false
		end
	end

	return current_text
    end

    local CreateStaticResetAnimation = function(min, max, condition, animation, key)
	if not CachedStaticConditionAnimation[key] then
		CachedStaticConditionAnimation[key] = {
			Condition = nil,
			Var = min
		}
	end

	local frametime = globals.frametime() * (animation / 10)
	if CachedStaticConditionAnimation[key].Condition ~= condition then
		CachedStaticConditionAnimation[key].Var = min
		CachedStaticConditionAnimation[key].Condition = condition
	end

	local delta = max > CachedStaticConditionAnimation[key].Var and frametime or - frametime
	if math.abs(max - CachedStaticConditionAnimation[key].Var) < frametime then
		return max
	end

	CachedStaticConditionAnimation[key].Var = CachedStaticConditionAnimation[key].Var + delta
	return CachedStaticConditionAnimation[key].Var
   end

    local CreateRelativeAnimationText = function(text, colors_1, colors_2, speed, is_reserved, automatic_reversed)
	local fraction_list = {}
	local current_text = ""
	if #text <= 0 then
		return ""
	end

	local text_length = #text
	local animation_reversed = is_reserved
	local maximized_different = text_length * 5
	local length_between = (#text / 2) + 1
	local animation_smooth = globals.curtime() / (11 - (speed / 10))
	if automatic_reversed then
		animation_reversed = RelativeAnimationTextSwitch[text]
	end

	for index = 1, length_between do
		local between = math.abs((index * 5) / maximized_different)
		fraction_list[index] = math.abs(1 * math.cos(2 * math.pi * animation_smooth + (animation_reversed and - between or between)))
	end

	for index, fraction in pairs(fraction_list) do
		fraction_list[length_between + index] = fraction_list[length_between - index]
	end

	if automatic_reversed then
		if not RelativeAnimationTextSwitch[text] then
			RelativeAnimationTextSwitch[text] = false
		end

		if not RelativeAnimationTextSwitch[text] and fraction_list[1] <= 0.01 then
			RelativeAnimationTextSwitch[text] = true
		elseif RelativeAnimationTextSwitch[text] and fraction_list[1] >= 0.99 then
			RelativeAnimationTextSwitch[text] = false
		end
	end

	for index, fraction in pairs(fraction_list) do
		local this_color = Lerp(colors_1, colors_2, fraction)
		current_text = ("%s%s"):format(current_text, RgbaToHexText(this_color, text:sub(index, index)))
	end

	return current_text
    end


local RenderGlowOutlineRectangle = function(x, y, w, h, rounding, glow_thickness, colors, settings, round_percentage)
	if settings then
		local BackgroundAlpha = colors.Background[4] or 255
		if settings[7] and settings[7] == "Blur" then
			renderer.blur(x, y, w, h, BackgroundAlpha / 255, BackgroundAlpha / 255)
		elseif settings[7] and settings[7] == "Rect" then
			RenderRoundRectangle(x, y, w, h, rounding, colors.Background)
		end

	elseif not settings then
		RenderRoundRectangle(x, y, w, h, rounding, colors.Background)
	end

	RectangleOutline(x - 1, y - 1, w + 2, h + 2, rounding, 1, colors.Outline, settings, round_percentage)
	if glow_thickness > 0 then
		RenderGlowOutline(x - 2, y - 1, w + 2, h, glow_thickness, rounding, colors.Glow or {colors.Outline[1], colors.Outline[2], colors.Outline[3], 100 * (colors.Outline[4] / 255)}, settings, round_percentage)
	end
end


GetStaticTargetAnimation = function(key, set_var)
	if not CachedStaticSingleAnimation[key] then
		CachedStaticSingleAnimation[key] = 0
	end

	if set_var then
		CachedStaticSingleAnimation[key] = set_var
	end

	return CachedStaticSingleAnimation[key]
end

local HexTextToOriginal = function(text)
	local OriginalText = tostring(text)
	local HexText = OriginalText:gmatch("\a%x%x%x%x%x%x%x%x")()
	while (HexText ~= nil) do
		OriginalText = OriginalText:gsub(HexText, "")
		HexText = OriginalText:gmatch("\a%x%x%x%x%x%x%x%x")()
	end

	return OriginalText
end

local GetLerpAnimation = function(key, set_var)
	if not CachedLerp[key] then
		CachedLerp[key] = 0
	end

	if set_var then
		CachedLerp[key] = set_var
	end

	return CachedLerp[key]
end

local ToInteger = function(var)
	return math.floor(var + 0.5)
end


local GetTimeScale = function()
	return client.timestamp() / 1000
end

local GetMathVars = function(...)
	local numbers = type(...) == "table" and ... or {...}
	return {
		min = math.min(unpack(numbers)),
		max = math.max(unpack(numbers))
	}
end

local Clamp = function(var, min, max)
	local math_vars = GetMathVars(min, max)
	return math.max(math.min(var, math_vars.max), min)
end

local TechSvg = renderer.load_svg([[<svg width="500" height="500" xmlns="http://www.w3.org/2000/svg" xml:space="preserve" version="1.1" fill="#000000"><g><title>background</title><rect fill="none" id="canvas_background" height="674" width="1278" y="-1" x="-1"/></g><g><title>Layer 1</title><g id="svg_1"><g id="svg_2"><path fill="#7f85ff" id="svg_3" d="m433.136,277.264c-23.416,-26.6 -55.576,-53.948 -92.964,-79.372c-1.556,-20.912 -4.028,-41.152 -7.388,-60.188c12.848,-4.056 25.256,-7.316 37.012,-9.676c40.056,-8.044 68.608,-4.788 76.396,8.704c8.172,14.14 -5.28,43.048 -35.1,75.444c-4.388,4.764 -4.084,12.18 0.684,16.568c4.756,4.388 12.184,4.084 16.572,-0.684c38.708,-42.044 52.26,-78.648 38.164,-103.056c-13.644,-23.632 -48.676,-30.54 -101.328,-19.968c-34.744,6.98 -74.5,21.152 -115.216,40.824c-18.824,-9.084 -37.528,-17.036 -55.632,-23.632c13.448,-60.548 35.312,-98.772 55.664,-98.772c16.012,0 34.072,25.312 47.128,66.06c1.98,6.164 8.576,9.568 14.748,7.588c6.168,-1.972 9.568,-8.58 7.588,-14.748c-17.264,-53.876 -41.284,-82.356 -69.464,-82.356c-38.92,0 -66.172,54.52 -80.472,125.98c0,0.004 -0.008,0.012 -0.008,0.02c-0.316,0.916 -0.472,1.844 -0.552,2.772c-4.248,21.876 -7.28,45.272 -9.088,69.136c-17.368,11.82 -33.688,24.1 -48.52,36.552c-9.932,-9.1 -18.96,-18.212 -26.888,-27.22c-26.992,-30.656 -38.452,-57.016 -30.664,-70.508c8.152,-14.116 39.812,-16.94 82.632,-7.376c6.316,1.42 12.588,-2.564 14,-8.888c1.412,-6.324 -2.568,-12.588 -8.888,-14c-55.616,-12.42 -93.992,-5.844 -108.06,18.536c-13.648,23.632 -2.108,57.428 33.368,97.736c23.416,26.6 55.572,53.944 92.964,79.368c1.552,20.916 4.028,41.156 7.384,60.192c-12.848,4.056 -25.248,7.316 -37.012,9.676c-40.044,8.04 -68.604,4.788 -76.392,-8.704c-8.248,-14.28 5.476,-43.48 35.812,-76.208c4.404,-4.748 4.12,-12.168 -0.628,-16.572c-4.752,-4.404 -12.168,-4.128 -16.576,0.624c-39.292,42.396 -53.116,79.292 -38.916,103.884c9.492,16.44 29.332,24.788 58.248,24.788c12.656,0 27.052,-1.6 43.076,-4.82c34.744,-6.98 74.504,-21.152 115.22,-40.824c18.82,9.084 37.52,17.036 55.632,23.636c-13.448,60.544 -35.316,98.768 -55.668,98.768c-15.968,0 -33.992,-25.2 -47.036,-65.768c-1.984,-6.168 -8.584,-9.56 -14.752,-7.576c-6.168,1.98 -9.556,8.584 -7.576,14.752c17.256,53.672 41.244,82.044 69.36,82.044c38.872,0 66.108,-54.408 80.424,-125.752c0.032,-0.08 0.076,-0.148 0.096,-0.224c0.344,-1.016 0.496,-2.044 0.56,-3.068c4.224,-21.796 7.24,-45.1 9.04,-68.868c17.372,-11.816 33.704,-24.104 48.528,-36.548c9.932,9.1 18.956,18.212 26.884,27.22c26.988,30.656 38.448,57.016 30.66,70.508c-8.12,14.072 -39.668,16.924 -82.32,7.448c-6.312,-1.392 -12.584,2.58 -13.992,8.904c-1.408,6.328 2.584,12.588 8.904,13.996c18.228,4.052 34.592,6.056 48.856,6.052c29.112,0 49.444,-8.344 58.872,-24.668c13.64,-23.636 2.104,-57.432 -33.376,-97.736zm-303.868,-27.252c9.112,-7.532 18.84,-14.984 28.98,-22.316c-0.24,7.444 -0.364,14.888 -0.364,22.304c0,7.508 0.16,14.98 0.396,22.424c-10.212,-7.372 -19.888,-14.868 -29.012,-22.412zm181.092,-104.576c1.964,11.652 3.552,23.8 4.836,36.244c-6.276,-3.884 -12.652,-7.712 -19.132,-11.456c-6.508,-3.752 -13.06,-7.348 -19.616,-10.868c11.48,-5.16 22.812,-9.788 33.912,-13.92zm-120.572,0.072c11.016,4.104 22.28,8.784 33.64,13.872c-6.5,3.496 -13,7.096 -19.484,10.84c-6.468,3.74 -12.828,7.588 -19.12,11.492c1.324,-12.64 3.004,-24.72 4.964,-36.204zm-0.144,209.056c-1.964,-11.652 -3.556,-23.8 -4.832,-36.244c6.272,3.884 12.648,7.708 19.136,11.456c6.5,3.752 13.052,7.348 19.612,10.868c-11.488,5.16 -22.82,9.788 -33.916,13.92zm120.568,-0.064c-11.02,-4.112 -22.28,-8.792 -33.636,-13.88c6.5,-3.496 12.996,-7.096 19.488,-10.84c6.456,-3.736 12.816,-7.584 19.116,-11.488c-1.324,12.64 -3.004,24.72 -4.968,36.208zm7.32,-65.516c-10.756,7.056 -21.844,13.92 -33.196,20.48c-11.432,6.596 -22.892,12.764 -34.292,18.52c-11.492,-5.792 -22.992,-11.952 -34.372,-18.52c-11.432,-6.6 -22.504,-13.44 -33.188,-20.436c-0.728,-12.844 -1.144,-25.888 -1.144,-39.028c0,-13.372 0.404,-26.372 1.132,-38.976c10.752,-7.052 21.828,-13.92 33.2,-20.488c11.432,-6.6 22.888,-12.768 34.284,-18.52c11.492,5.792 22.992,11.952 34.38,18.52c11.424,6.6 22.5,13.436 33.18,20.432c0.732,12.848 1.144,25.888 1.144,39.032c0,13.376 -0.408,26.376 -1.128,38.984zm24.22,-16.672c0.244,-7.444 0.364,-14.892 0.364,-22.312c0,-7.508 -0.16,-14.98 -0.388,-22.424c10.2,7.368 19.872,14.856 28.988,22.396c-9.12,7.536 -18.812,15.004 -28.964,22.34z"/></g></g><g id="svg_4"><g id="svg_5"><path fill="#7f85ff" id="svg_6" d="m251,210.916c-21.552,0 -39.088,17.532 -39.088,39.084s17.536,39.084 39.088,39.084s39.088,-17.532 39.088,-39.084c0,-21.552 -17.532,-39.084 -39.088,-39.084z"/></g></g></g></svg>]], 15, 15)
local HitlogCached = {}
local AimHit = function( e)
	if not e.target or not ui.get(HitlogIndication) then
		return
	end

	local Timer = globals.curtime()
	local Damage = ToInteger(e.damage)
	local TargetName = entity.get_player_name(e.target)
	local Hitchance = ToInteger(e.hit_chance)
	local HitlogStyle = ui.get(HitlogStyle)
	local Backtrack = e.backtrack or 0
	local Hitboxes = ({"Body", "Head", "Chest", "Stomach", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Neck", "?", "Gear"})[e.hitgroup + 1] or "Gear"
	local Text = ("hit %s 's %s for %i damage"):format(
		TargetName, Hitboxes, Damage
	)

	if HitlogStyle == "Novel" then
		Text = function(modified)
			local modifier = type(modified) == "number" and modified or 1
			return ("Hit %s 's %s %s %s %s: %s  %s: %s%s}"):format(
				TargetName,
				RgbaToHexText({185, 183, 241, modifier * 255}, Hitboxes),
				RgbaToHexText({255, 255, 255, modifier * 255}, "for"),
				RgbaToHexText({185, 183, 241, modifier * 255}, Damage),
				RgbaToHexText({255, 255, 255, modifier * 255}, "damage,  hitchance"),
				RgbaToHexText({185, 183, 241, modifier * 255}, Hitchance),
				RgbaToHexText({255, 255, 255, modifier * 255}, "{bt"),
				RgbaToHexText({246, 88, 88, modifier * 255}, Backtrack),
				RgbaToHexText({255, 255, 255, modifier * 255}, "ticks")
			)
		end
	end

	table.insert(HitlogCached, {
		Text = Text,
		Index = e.id,
		Timer = Timer,
		Release = false
	})
end

local AimMiss = function(e)
	if not e.target or not ui.get(HitlogIndication) then
		return
	end

	local Timer = globals.curtime()
	local TargetName = entity.get_player_name(e.target)
	local Hitchance = ToInteger(e.hit_chance)
	local HitlogStyle = ui.get(HitlogStyle)
	local CurrentReason = e.reason == "?" and "resolver" or e.reason
	local Backtrack = e.backtrack or 0
	local Hitboxes = ({"Body", "Head", "Chest", "Stomach", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Neck", "?", "Gear"})[e.hitgroup + 1] or "Gear"
	local Text = ("miss shot %s 's due to %s"):format(
		TargetName, CurrentReason
	)

	if HitlogStyle == "Novel" then
		Text = function(modified)
			local modifier = type(modified) == "number" and modified or 1
			return ("%s %s 's for %s  %s%s"):format(
				RgbaToHexText({246, 88, 88, modifier * 255}, "Missed "),
				RgbaToHexText({255, 255, 255, modifier * 255}, TargetName),
				RgbaToHexText({185, 183, 241, modifier * 255}, Hitboxes),
				RgbaToHexText({255, 255, 255, modifier * 255}, "due to "),
				RgbaToHexText({246, 88, 88, modifier * 255}, CurrentReason),
				RgbaToHexText({255, 255, 255, modifier * 255}, ", hitchance: "),
				RgbaToHexText({185, 183, 241, modifier * 255}, Hitchance),
				RgbaToHexText({255, 255, 255, modifier * 255}, ", {bt:  "),
				RgbaToHexText({246, 88, 88, modifier * 255}, Backtrack),
				RgbaToHexText({255, 255, 255, modifier * 255}, "ticks")
			)
		end
	end

	table.insert(HitlogCached, {
		Text = Text,
		Index = e.id,
		Timer = Timer,
		Release = false
	})
end


client.set_event_callback("aim_miss", AimMiss)
client.set_event_callback("aim_hit", AimHit)

local ScreenSize = {client.screen_size()}

local dragging_hitlog = dragging_fn('Hitlog', (ScreenSize[1] / 2) - 200, ScreenSize[2] / 2 + 200)
local render_hitlog = function()
	if not ui.get(HitlogIndication) then
		return
	end

		local HitlogStyle = ui.get(HitlogStyle)
		local Timer = globals.curtime()

        local alpha = get_menu_alpha()
		local menu_animat = alpha / 255 * NewLerp(0, ui.is_menu_open() and 1 or 0, 80, "Hitlog Menu Anim")
		local HitlogCachedPreview = {}
		local dragging_size = vector(400, 150)
		local x, y = dragging_hitlog:get()
		if (ui.is_menu_open()) then
			local mouse_pos = vector(ui_mouse_position())
		local PreviewText = ("hit %s 's %s for %i damage"):format(
			"enemy", "Head", 50
		)

		local PreviewText2 = ("hit %s 's %s for %i damage"):format(
			"target", "Stomach", 60
		)

		if HitlogStyle == "Novel" then
			PreviewText = function(modified)
				local modifier = type(modified) == "number" and modified or 1
				return ("Hit %s 's %s %s %s %s: %s  %s: %s%s}"):format(
					"enemy",
					RgbaToHexText({185, 183, 241, modifier * 255}, "Head"),
					RgbaToHexText({255, 255, 255, modifier * 255}, "for"),
					RgbaToHexText({185, 183, 241, modifier * 255}, 11),
					RgbaToHexText({255, 255, 255, modifier * 255}, "damage,  hitchance"),
					RgbaToHexText({185, 183, 241, modifier * 255}, 80),
					RgbaToHexText({255, 255, 255, modifier * 255}, "{bt"),
					RgbaToHexText({246, 88, 88, modifier * 255}, 2),
					RgbaToHexText({255, 255, 255, modifier * 255}, "ticks")
				)
			end

			PreviewText2 = function(modified)
				local modifier = type(modified) == "number" and modified or 1
				return ("Hit %s 's %s %s %s %s: %s  %s: %s%s}"):format(
					"target",
					RgbaToHexText({185, 183, 241, modifier * 255}, "Stomach"),
					RgbaToHexText({255, 255, 255, modifier * 255}, "for"),
					RgbaToHexText({185, 183, 241, modifier * 255}, 60),
					RgbaToHexText({255, 255, 255, modifier * 255}, "damage,  hitchance"),
					RgbaToHexText({185, 183, 241, modifier * 255}, 40),
					RgbaToHexText({255, 255, 255, modifier * 255}, "{bt"),
					RgbaToHexText({246, 88, 88, modifier * 255}, 1),
					RgbaToHexText({255, 255, 255, modifier * 255}, "ticks")
				)
			end
		end

			table.insert(HitlogCachedPreview, {
				Text = PreviewText,
				Index = 2,
				Timer = Timer,
				Release = false
			})


		local PreviewTextMiss = ("miss shot %s 's due to %s"):format(
			"enemy", "resolver"
		)

		if HitlogStyle == "Novel" then
			PreviewTextMiss= function(modified)
			local modifier = type(modified) == "number" and modified or 1
			return ("%s %s 's for %s  %s%s"):format(
				RgbaToHexText({246, 88, 88, modifier * 255}, "Missed "),
				RgbaToHexText({255, 255, 255, modifier * 255}, "enemy"),
				RgbaToHexText({185, 183, 241, modifier * 255}, "head"),
				RgbaToHexText({255, 255, 255, modifier * 255}, "due to "),
				RgbaToHexText({246, 88, 88, modifier * 255}, "resolver"),
				RgbaToHexText({255, 255, 255, modifier * 255}, ", hitchance: "),
				RgbaToHexText({185, 183, 241, modifier * 255}, 60),
				RgbaToHexText({255, 255, 255, modifier * 255}, ", {bt:  "),
				RgbaToHexText({246, 88, 88, modifier * 255}, 0),
				RgbaToHexText({255, 255, 255, modifier * 255}, "ticks")
			)
			end
		end


			table.insert(HitlogCachedPreview, {
				Text = PreviewText,
				Index = 4,
				Timer = Timer,
				Release = false
			})

			table.insert(HitlogCachedPreview, {
				Text = PreviewTextMiss,
				Index = 1,
				Timer = Timer,
				Release = false
			})

			local bound = dragging_size + vector(x, y)
			local is_hover = mouse_pos.x > x and mouse_pos.y > y and mouse_pos.x < bound.x and mouse_pos.y < bound.y

			local is_press = client.key_state(0x01)
			local hover_animat = NewLerp(0, is_hover and (is_press and 2 or 1) or 0, 80, "Hitlog Drag Anim")

			RenderRoundRectangle(x, y, dragging_size.x + 6, dragging_size.y, 3, { 150, 150, 150, hover_animat * (menu_animat * 75)})

		end

	    local sizeheight = 350
	    local CenterSize = vector(x + 200, y)
		local UpdaterIndex = 0
		local Curtime = globals.curtime()
		local Smooth = globals.frametime() * 5
		local HitlogColor = {ui.get(HitlogColor)}
		local HitlogLimitation = ui.get(HitlogIndication)
		local HitlogAnimation = ui.get(HitlogIndication)
		local HitlogSmoothed = 85
		local HitlogAnimationText = ui.get(HitlogIndication)
		local HitlogBackground =ui.get(HitlogBackgroundStyle)
		local HitlogOverrideBackground = ui.get(HitlogIndication)
		local HitlogAnimationStyle = ui.get(HitlogIndication)
		local HitlogLimitationMaximized = 6
		local HitlogTextSmoothed = 90
		local HitlogHeight = 250
		local HitlogBetween = 35
		local HitlogReleaseTimer = 3.5
		for index, data in pairs(ui.is_menu_open() and HitlogCachedPreview or HitlogCached) do
			local CurrentText = data.Text
			local TimeBetween = math.abs(Curtime - data.Timer)
			local AnimationModifier = ui.is_menu_open() and menu_animat or HitlogAnimation and (HitlogAnimationStyle == "Static" and CreateStaticTargetAnimation(0, data.Release and 0 or 1, HitlogSmoothed, ("[%s]Hitlogs"):format(data.Index)) or NewLerp(0, data.Release and 0 or 1, HitlogSmoothed, ("[%s]Hitlogs"):format(data.Index))) or (data.Release and 0 or 1)
			local AnimationTextModifier = ui.is_menu_open() and menu_animat or HitlogAnimation and (HitlogAnimationStyle == "Static" and CreateStaticTargetAnimation(0, data.Release and 0 or 1, HitlogTextSmoothed, ("[%s]Hitlogs Text"):format(data.Index)) or NewLerp(0, data.Release and 0 or 1, HitlogTextSmoothed, ("[%s]Hitlogs Text"):format(data.Index))) or (data.Release and 0 or 1)
			if type(CurrentText) == "function" then
				CurrentText = HitlogStyle == "Novel" and CurrentText(AnimationModifier)
			end

			if HitlogLimitation and index > HitlogLimitationMaximized then
				local Remote = HitlogCached[1]
				GetLerpAnimation(("[%s]Hitlogs"):format(Remote.Index), 0)
				GetLerpAnimation(("[%s]Hitlogs Text"):format(Remote.Index), 0)
				GetStaticTargetAnimation(("[%s]Hitlogs"):format(Remote.Index), 0)
				GetStaticTargetAnimation(("[%s]Hitlogs Text"):format(Remote.Index), 0)
				table.remove(HitlogCached, 1)
			elseif AnimationModifier >= 1 and TimeBetween > HitlogReleaseTimer and not data.Release then
				data.Release = true
			elseif data.Release and AnimationModifier <= 0 then
				GetLerpAnimation(("[%s]Hitlogs"):format(data.Index), 0)
				GetLerpAnimation(("[%s]Hitlogs Text"):format(data.Index), 0)
				GetStaticTargetAnimation(("[%s]Hitlogs"):format(data.Index), 0)
				GetStaticTargetAnimation(("[%s]Hitlogs Text"):format(data.Index), 0)
				table.remove(HitlogCached, index)
			end

			local Weight = HitlogHeight * AnimationModifier
			local DifferentBetween = HitlogBetween * AnimationModifier
			if HitlogStyle == "Novel" then
				local TextSize = vector(renderer.measure_text(HitlogStyle == "Style #1" and "-" or "", CurrentText))
				local TextAnimationSize = HitlogAnimationText and TextSize * AnimationTextModifier or TextSize
				local HitlogTextSize = TextAnimationSize + vector(20)
				local GlowOutlinePosition = vector(CenterSize.x - (HitlogTextSize.x / 2) - 5, CenterSize.y + sizeheight - Weight - 10 - (UpdaterIndex * DifferentBetween))
				RenderGlowOutlineRectangle(GlowOutlinePosition.x + (HitlogTextSize.x / 300), GlowOutlinePosition.y + HitlogTextSize.y, HitlogTextSize.x + ToInteger(HitlogTextSize.x / 18), 24, 4, 15, {
					Background = {25, 25, 25, AnimationModifier * 155},
					Glow = {HitlogColor[1], HitlogColor[2], HitlogColor[3], AnimationModifier * 40},
					Outline = {HitlogColor[1], HitlogColor[2], HitlogColor[3], AnimationModifier * HitlogColor[4]}
				}, {false, false, true, true, true, true, HitlogOverrideBackground and HitlogBackground or ""}, 0.2)
				local HitlogTextSize = vector(renderer.measure_text(HitlogStyle == "Style #1" and "-" or "", CurrentText)) + vector(10)
				renderer.text(CenterSize.x - (HitlogTextSize.x / 2.14) + ((TextSize.x - TextAnimationSize.x) / 2) + 10, CenterSize.y + sizeheight + (HitlogTextSize.y / 1) - Weight - 5 - (UpdaterIndex * DifferentBetween), 255, 255, 255, 255 * AnimationModifier, "", ToInteger(TextAnimationSize.x + 2), CurrentText)
				renderer.texture(TechSvg,
					CenterSize.x - (TextAnimationSize.x / 2.14) - 15,
					CenterSize.y + sizeheight + (HitlogTextSize.y / 1) - Weight - 6 - (UpdaterIndex * DifferentBetween),
					15, 15, 255, 255, 255, AnimationModifier * 255
				)
			end

			UpdaterIndex = UpdaterIndex + AnimationModifier
		end


		dragging_hitlog:drag(dragging_size.x, dragging_size.y)
end

	local NotifyCached = {}
	local LightPinkedColor = {185, 181, 241, 255}
	local NotifyBackgroundColor = {255, 255, 255, 15}
	local NotifyPercentageLineColor = {148, 151, 205, 255}
	local paint_notifys = function()
	local NotifyUpdaterIndex = 0
	local TimeScale = GetTimeScale()
	local ScreenSize = vector(client.screen_size())
	for index, data in pairs(NotifyCached) do
		local HeightBetween = 125
		local CurrentUpdateIndex = NotifyUpdaterIndex
		local TimePercentage = data.Switch and 0.025 or 1
		local NotifyAnimationColor = data.AnimationColor or LightPinkedColor
		local NotifyAnimation = NewLerp(0, data.Switch and 0 or 1, 100, ("[%s]Notify Logs"):format(data.Index))
		local NotifyHeight = NewLerp(CurrentUpdateIndex * HeightBetween, ToInteger(CurrentUpdateIndex * HeightBetween), 100, ("[%s]Notify Between Logs"):format(data.Index))
		if not data.CurrentIndex then
			data.CurrentIndex = index
		end

		local NotifyReleaseTimer = (data.ReleaseTimer or 2.5) + (data.CurrentIndex * 0.55)
		if data.Switch and NotifyAnimation <= 0 then
			GetLerpAnimation(("[%s]Notify Logs"):format(data.Index), 0)
			GetLerpAnimation(("[%s]Notify Between Logs"):format(data.Index), 0)
			table.remove(NotifyCached, index)
		elseif NotifyAnimation < 1 and not data.Switch then
			data.Timer = TimeScale
		elseif NotifyAnimation >= 1 then
			local DifferentTimer = math.abs(TimeScale - data.Timer)
			TimePercentage = Clamp(1 - (DifferentTimer / NotifyReleaseTimer), 0.025, 1)
			if DifferentTimer > NotifyReleaseTimer then
				data.Switch = true
			end
		end

		local NotifyText = CreateRelativeAnimationText(
			data.Text,
			{NotifyAnimationColor[1], NotifyAnimationColor[2], NotifyAnimationColor[3], NotifyAnimation * NotifyAnimationColor[4]},
			{255, 255, 255, NotifyAnimation * 255},
			85, true, false
		)

		local SvgRectAddSize = vector(27, 27)
		local OriginalText = HexTextToOriginal(NotifyText)
		local TextSize = vector(renderer.measure_text("b", OriginalText))
		local NotifySvgSize = (data.Svg and data.Svg.Size or vector(0, 0))
		local TitleTextSize = vector(renderer.measure_text("b+", data.Title))
		local AddonMaximizedSize = vector(math.max(TextSize.x, TitleTextSize.x), math.max(TextSize.y, TitleTextSize.y))
		if data.UserName then
			local OriginalUserText = HexTextToOriginal(data.UserName)
			local UserTextSize = vector(renderer.measure_text("b", OriginalText))
			AddonMaximizedSize = vector(math.max(UserTextSize.x, AddonMaximizedSize.x), AddonMaximizedSize.y + UserTextSize.y)
		end

		if data.ConfigsName then
			local OriginalConfigText = HexTextToOriginal(data.ConfigsName)
			local ConfigTextSize = vector(renderer.measure_text("b", OriginalConfigText))
			AddonMaximizedSize = vector(math.max(ConfigTextSize.x, AddonMaximizedSize.x), AddonMaximizedSize.y + ConfigTextSize.y)
		end

		local SvgRectSize = data.Svg.Size + SvgRectAddSize
		local UpperTextAddonSize = 33 + TitleTextSize.y + TextSize.y
		local NotifySize = vector(70, 50) + vector(AddonMaximizedSize.x + NotifySvgSize.x, math.max(AddonMaximizedSize.y, NotifySvgSize.y))
		RenderRoundRectangle(ScreenSize.x - ((NotifySize.x + 20) * NotifyAnimation), 20 + NotifyHeight, NotifySize.x, NotifySize.y, 8, {NotifyBackgroundColor[1], NotifyBackgroundColor[2], NotifyBackgroundColor[3], NotifyAnimation * NotifyBackgroundColor[4]})
		renderer.blur(ScreenSize.x - ((NotifySize.x + 20) * NotifyAnimation), 20 + NotifyHeight, NotifySize.x, NotifySize.y, NotifyAnimation, NotifyAnimation)
		local NotifyPercentageRectWidth = (NotifySize.x - 3) * TimePercentage
		if NotifyPercentageRectWidth >= 5 then
			RenderRoundRectangle(ScreenSize.x - ((NotifySize.x + 19) * NotifyAnimation), NotifySize.y + 14 + NotifyHeight, (NotifySize.x - 3) * TimePercentage, 5, 4, {NotifyPercentageLineColor[1], NotifyPercentageLineColor[2], NotifyPercentageLineColor[3], NotifyAnimation * NotifyPercentageLineColor[4]})
		end

		renderer.text(
			ScreenSize.x - (NotifySize.x * NotifyAnimation) + NotifySvgSize.x + 30,
			30 + NotifyHeight,
			255, 255, 255, NotifyAnimation * 255, "b+", 0, data.Title
		)

		renderer.text(
			ScreenSize.x - (NotifySize.x * NotifyAnimation) + NotifySvgSize.x + 30,
			33 + TitleTextSize.y + NotifyHeight,
			255, 255, 255, 0, "b", 0, NotifyText
		)

		if data.ConfigsName then
			renderer.text(
				ScreenSize.x - (NotifySize.x * NotifyAnimation) + NotifySvgSize.x + 30,
				UpperTextAddonSize + 1 + NotifyHeight,
				255, 255, 255, NotifyAnimation * 255, "b", 0, data.ConfigsName
			)

			local OriginalText = HexTextToOriginal(data.ConfigsName)
			local TextSize = vector(renderer.measure_text("b", OriginalText))
			UpperTextAddonSize = UpperTextAddonSize + TextSize.y + 1
		end

		if data.UserName then
			renderer.text(
				ScreenSize.x - (NotifySize.x * NotifyAnimation) + NotifySvgSize.x + 30,
				UpperTextAddonSize + 1 + NotifyHeight,
				255, 255, 255, NotifyAnimation * 255, "b", 0, data.UserName
			)

			local OriginalText = HexTextToOriginal(data.UserName)
			local TextSize = vector(renderer.measure_text("b", OriginalText))
			UpperTextAddonSize = UpperTextAddonSize + TextSize.y + 1
		end

		if data.Svg then
			RenderRoundRectangle(
				ScreenSize.x - (NotifySize.x * NotifyAnimation) + 5 - (SvgRectAddSize.x / 2),
				45 - (SvgRectAddSize.y / 2) + NotifyHeight,
			SvgRectSize.x, SvgRectSize.y, 8, {0, 0, 0, NotifyAnimation * 255})
			renderer.texture(data.Svg.Texture,
				ScreenSize.x - (NotifySize.x * NotifyAnimation) + 5,
				45 + NotifyHeight,
				data.Svg.Size.x, data.Svg.Size.y, 255, 255, 255, NotifyAnimation * 255
			)
		end

		NotifyUpdaterIndex = NotifyUpdaterIndex + NotifyAnimation
	end

	end

local dragging_crosshair = dragging_fn('Crosshair', (ScreenSize[1] / 2) - 40, ScreenSize[2] / 2)
    local paint_crosshair_indicator = function()
	if not ui.get(CrosshairIndication) then
		return
	end

	local local_player = entity.get_local_player()
	if not local_player or not entity.is_alive(local_player) then
		return
	end


	local PrevScoped = entity.get_prop(local_player, "m_bIsScoped")
	local ScreenSize = vector(client.screen_size())
	local pos = vector(dragging_crosshair:get())
	local CenterSize = pos  + vector(38, 10)
	local dragging_size = vector(80, 80)
        local alpha = get_menu_alpha()
		local menu_animat = alpha / 255 * NewLerp(0, ui.is_menu_open() and 1 or 0, 80, "Crosshair Menu Anim")
	if  ui.is_menu_open() then

			local mouse_pos = vector(ui_mouse_position())
			local bound = dragging_size + pos
			local is_hover = mouse_pos.x > pos.x and mouse_pos.y > pos.y and mouse_pos.x < bound.x and mouse_pos.y < bound.y
			local is_press = client.key_state(0x01)
			local hover_animat = NewLerp(0, is_hover and (is_press and 2 or 1) or 0, 80, "Crosshair Drag Anim")

			RenderRoundRectangle(pos.x, pos.y, dragging_size.x + 3, dragging_size.y, 3, { 150, 150, 150, hover_animat * (menu_animat * 75)})
	end

	dragging_crosshair:drag(dragging_size.x, dragging_size.y)



	local CrosshairFraction = 1
	local Hotkeys = {}
	local IsHitable = false
	local DifferentOffset = 0
	local NameAnimationSpeed = 80
	local IsScoped = PrevScoped == 1
	local EmptySize = vector(0, 0)
	local CrosshairScopeAnimationSmoothed = 85
	local FakeDuck = ui.get(reference.duck_peek_assist)
	local ForceBaim = ui.get(reference.force_body)
	local CanAttack = CanAttack(local_player, true)
	local SelfHealth = entity.get_prop(local_player, "m_iHealth")
	local LegitAA = false
	local HeadPosition = vector(entity.hitbox_position(local_player, 0))
	local ThreatTarget = client.current_threat()
	local StomachPosition = vector(entity.hitbox_position(local_player, 2))
	local Freestanding = ui.get(reference.freestanding[2])
	local GlowText = ui.get(CrosshairIndication)
	local CrosshairStyle = ui.get(CrosshairStyle)
	local BarColor = {ui.get(CrosshairBarColor)}
	local HotkeyAnimation = ui.get(CrosshairIndication)
	local CrosshairName = "Casset.lua"
	local VelocityModifier = entity.get_prop(local_player, "m_flVelocityModifier")
	local CrosshairNameStyle = ui.get(CrosshairNameStyle)
	local NameRealSideColor = {ui.get(CrosshairRealSideColor)}
	local NameFakeSideColor = {ui.get(CrosshairFakeSideColor)}
	local CrosshairScopeAnimation = ui.get(CrosshairIndication)
	local CrosshairAnimationSide =ui.get(CrosshairAnimationSide)
	local ExtraHotkeysColor = {ui.get(CrosshairHotkeysExtraColor)}
	local OtherHotkeysColor = {ui.get(CrosshairHotkeysOtherColor)}
	local CrosshairAnimationStyle = ui.get(CrosshairAnimationStyle)
	local onshotHotkeyColor = {ui.get(CrosshairHotkeysonshotColor)}
	local CrosshairScopeAnimationStyle = ui.get(CrosshairIndication)
	local onshot = ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])
	local GlowFraction = contains(CrosshairHotkeySettings, "Fraction") and 100 or 70
	local DoubleTapHotkeyColor = {ui.get(CrosshairHotkeysDoubleTapColor)}
	local GlowThickness = contains(CrosshairHotkeySettings, "Thickness") and (100 / 10) or 10
	local DoubleTap = ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])
	local HotkeyAnimationSmoothed = contains(CrosshairHotkeySettings, "Animation Speed") and 80 or 80
	local BasePosition = vector(1 * CenterSize.x, 1 * CenterSize.y)
	local DamageOverride = ui.get(reference.min_damage_override[1]) and ui.get(reference.min_damage_override[2])
	local NameTextSize = vector(renderer.measure_text(CrosshairStyle == "Manifold" and "c-" or "cbr", CrosshairStyle == "Manifold" and "PRI-VATE" or CrosshairName))
	local CrosshairScopeAnimationPercentage = CreateStaticTargetAnimation(0, IsScoped and 1 or 0, CrosshairScopeAnimationSmoothed, "Crosshair Scope Animation") or NewLerp(0, IsScoped and 1 or 0, CrosshairScopeAnimationSmoothed, "Crosshair Scope Animation")
	if ThreatTarget and entity.is_alive(ThreatTarget) and not entity.is_dormant(ThreatTarget) then
		local TargetEyePosition = ExtrapolatePosition(ThreatTarget, GetEyePosition(ThreatTarget), 14)
		local _, HeadDamage = client.trace_bullet(ThreatTarget, TargetEyePosition.x, TargetEyePosition.y, TargetEyePosition.z, HeadPosition.x, HeadPosition.y, HeadPosition.z)
		local _, StomachDamage = client.trace_bullet(ThreatTarget, TargetEyePosition.x, TargetEyePosition.y, TargetEyePosition.z, StomachPosition.x, StomachPosition.y, StomachPosition.z)
		if HeadDamage > 0 or StomachDamage > 50 or math.max(HeadDamage, StomachDamage) > SelfHealth then
			IsHitable = true
		end
	end

	local PlayerStateTextSize = vector(renderer.measure_text(CrosshairStyle == "Manifold" and "c-" or "c-", CrosshairStyle == "Manifold" and ("H E L I O S / %s"):format(("%i"):format(VelocityModifier * 100), "%") or PlayerStateName:upper()))
	local ScopedTextSize = {
		Name = (CrosshairScopeAnimation and NameTextSize or EmptySize) * CrosshairScopeAnimationPercentage,
		Bar = (CrosshairScopeAnimation and vector(50, 5) or EmptySize) * CrosshairScopeAnimationPercentage,
		PlayerState = (CrosshairScopeAnimation and PlayerStateTextSize or EmptySize) * CrosshairScopeAnimationPercentage
	}

	if GlowText and CrosshairStyle == "Concen" then
		RenderGlowOutline(BasePosition.x + 2 - (NameTextSize.x / 2) + (ScopedTextSize.Name.x / 2), BasePosition.y + 25, NameTextSize.x, 0, GlowThickness, 0, {NameRealSideColor[1], NameRealSideColor[2], NameRealSideColor[3], GlowFraction * CrosshairFraction})
	end

	local flPoseParameter = entity.get_prop(local_player, "m_flPoseParameter", 11)
	local flAbsFeetDelta = math.max(- 60, math.min(60, flPoseParameter * 120 - 60 + 0.5))
	if CrosshairNameStyle == "Desync" and CrosshairStyle == "Concen" then
		local NameRealSideColor = {NameRealSideColor[1], NameRealSideColor[2], NameRealSideColor[3], NameRealSideColor[4] * CrosshairFraction}
		local NameFakeSideColor = {NameFakeSideColor[1], NameFakeSideColor[2], NameFakeSideColor[3], NameFakeSideColor[4] * CrosshairFraction}
		renderer.text(BasePosition.x + 3 + (ScopedTextSize.Name.x / 2), BasePosition.y + 25, 255, 255, 255 * CrosshairFraction, 0, "cbr", 0, (CrosshairAnimationStyle == "Stationary" and 
			RgbaToHexGradientText(NameRealSideColor, NameFakeSideColor, CrosshairName) or CrosshairAnimationStyle == "Opposite" and 
			CreateRelativeAnimationText(
				CrosshairName,
				NameRealSideColor,
				NameFakeSideColor,
				NameAnimationSpeed, CrosshairAnimationSide == "Reversed", CrosshairAnimationSide == "Repeatedly"
			) or CreateAnimationText(CrosshairName, NameRealSideColor, NameFakeSideColor, NameAnimationSpeed, CrosshairAnimationSide == "Reversed", CrosshairAnimationSide == "Repeatedly"))
		)

		RenderRoundRectangle(BasePosition.x - 21 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 31, 46, 3, 2, {0, 0, 0, CrosshairFraction * 60})
		if direction == - 90 then
			renderer.rectangle(BasePosition.x + 3 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 32, - (23 * (math.abs(flAbsFeetDelta) / 60)), 1.5, BarColor[1], BarColor[2], BarColor[3], CrosshairFraction * BarColor[4])
		elseif direction == 90 then
			renderer.rectangle(BasePosition.x + 3 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 32, (23 * (math.abs(flAbsFeetDelta) / 60)), 1.5, BarColor[1], BarColor[2], BarColor[3], CrosshairFraction * BarColor[4])
		else
			renderer.rectangle(BasePosition.x + 3 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 32, 23 * (flAbsFeetDelta / 60), 1.5, BarColor[1], BarColor[2], BarColor[3], CrosshairFraction * BarColor[4])
		end

		renderer.text(BasePosition.x + 1 + (ScopedTextSize.PlayerState.x / 2), BasePosition.y + 38, 255, 255, 255, CrosshairFraction * 255, "c-", 0, PlayerStateName:upper())
		DifferentOffset = DifferentOffset + 27
	elseif CrosshairNameStyle ~= "Desync" or CrosshairStyle == "Manifold" then
		local NameRealSideColor = {NameRealSideColor[1], NameRealSideColor[2], NameRealSideColor[3], NameRealSideColor[4] * CrosshairFraction}
		local NameFakeSideColor = {NameFakeSideColor[1], NameFakeSideColor[2], NameFakeSideColor[3], NameFakeSideColor[4] * CrosshairFraction}
		renderer.text(BasePosition.x + ((CrosshairScopeAnimation and IsScoped) and 11 or 1) + (ScopedTextSize.Name.x / 2), BasePosition.y + 35, 255, 255, 255 * CrosshairFraction, 0, "c-", 0, (CrosshairAnimationStyle == "Stationary" and 
			RgbaToHexGradientText(NameRealSideColor, NameFakeSideColor, "CASSET") or CrosshairAnimationStyle == "Opposite" and 
			CreateRelativeAnimationText(
				"CASSET",
				NameRealSideColor,
				NameFakeSideColor,
				NameAnimationSpeed, CrosshairAnimationSide == "Reversed", CrosshairAnimationSide == "Repeatedly"
			) or CreateAnimationText("CASSET", NameRealSideColor, NameFakeSideColor, NameAnimationSpeed, CrosshairAnimationSide == "Reversed", CrosshairAnimationSide == "Repeatedly"))
		)

		RenderRoundRectangle(BasePosition.x - 23 + 5 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 29, 45, 3, 2, {0, 0, 0, CrosshairFraction * 60})
		if direction == - 90 then
			renderer.rectangle(BasePosition.x + 4 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 30, - (23 * (math.abs(flAbsFeetDelta) / 60)), 1.5, BarColor[1], BarColor[2], BarColor[3], CrosshairFraction * BarColor[4])
		elseif direction == 90 then
			renderer.rectangle(BasePosition.x + 4 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 30, (23 * (math.abs(flAbsFeetDelta) / 60)), 1.5, BarColor[1], BarColor[2], BarColor[3], CrosshairFraction * BarColor[4])
		else
			renderer.rectangle(BasePosition.x + 4 + (ScopedTextSize.Bar.x / 2), BasePosition.y + 30, 23 * (flAbsFeetDelta / 60), 1.5, BarColor[1], BarColor[2], BarColor[3], CrosshairFraction * BarColor[4])
		end
		local NameRadius = (CrosshairName):len() / 2
		local DebugPulse = (math.sin(math.abs(- math.pi + (globals.curtime() * (5/ 6 - 2.2)) % (math.pi * 2))) * 255)
		local NameRealSideColor = {NameRealSideColor[1], NameRealSideColor[2], NameRealSideColor[3], NameRealSideColor[4] * CrosshairFraction}
		local NameFakeSideColor = {NameFakeSideColor[1], NameFakeSideColor[2], NameFakeSideColor[3], NameFakeSideColor[4] * CrosshairFraction}
		local NameSideText = {CrosshairName:sub(1, NameRadius), CrosshairName:sub(NameRadius + 1, CrosshairName:len())}

		renderer.text(BasePosition.x + (ScopedTextSize.Name.x / 2), BasePosition.y + (CrosshairStyle == "Manifold" and 23 or 25), 255, 255, 255 * CrosshairFraction, 0, CrosshairStyle == "Manifold" and "c-" or "c-", 0, NameText)
		if CrosshairStyle == "Concen" then
			renderer.text(BasePosition.x + (ScopedTextSize.PlayerState.x / 2), BasePosition.y + 36, 255, 255, 255, 255 * CrosshairFraction, "c-", 0, PlayerStateName:upper())
		elseif CrosshairStyle == "Manifold" then
			local PlayerStatePowCrosshairSize = (CrosshairScopeAnimation and EmptySize) * CrosshairScopeAnimationPercentage
			if GlowText then
				RenderGlowOutline(BasePosition.x - ((CrosshairScopeAnimation and IsScoped) and 5 or 10) + (ScopedTextSize.PlayerState.x / 2), BasePosition.y + 34, 25, 0, GlowThickness, 0, {185, 181, 241, GlowFraction * CrosshairFraction})
			end

			renderer.text(BasePosition.x+ ((CrosshairScopeAnimation and IsScoped) and 6 or 2) + (ScopedTextSize.PlayerState.x / 2), BasePosition.y + 25, 255, 255, 255, 0, "c-", 0, ("%s %s %s"):format(
				RgbaToHexText(NameRealSideColor, " REC"),
				RgbaToHexText({255, 255, 255, 255 * CrosshairFraction}, "|"),
				RgbaToHexText(NameFakeSideColor, ("%s%s"):format(("%i"):format(VelocityModifier * 100), "%"))
			))
		end

		DifferentOffset = DifferentOffset + 24
	end

	if contains(CrosshairHotkeyStyle, "Simplicity") then
		table.insert(Hotkeys, {
			Type = "DT",
			Color = DoubleTapHotkeyColor,
			Toggle = DoubleTap and not FakeDuck,
			Text = CanAttack and "DT" or "AUTO"
		})

		table.insert(Hotkeys, {
			Type = "OS",
			Text = "OS",
			Color = onshotHotkeyColor,
			Toggle = onshot
		})

		table.insert(Hotkeys, {
			Text = "Dmg",
			Type = "DMG",
			Toggle = DamageOverride,
			Color = OtherHotkeysColor
		})

		table.insert(Hotkeys, {
			Text = "Baim",
			Type = "BAIM",
			Toggle = ForceBaim,
			Color = OtherHotkeysColor
		})

		table.insert(Hotkeys, {
			Text = "Duck",
			Type = "DUCK",
			Toggle = FakeDuck,
			Color = OtherHotkeysColor
		})

		table.insert(Hotkeys, {
			Text = "Fs",
			Type = "FS",
			Toggle = Freestanding,
			Color = OtherHotkeysColor
		})
	end

	if contains(CrosshairHotkeyStyle, "Complete") then
		table.insert(Hotkeys, {
			Type = "DEFENSIVE",
			Text = "Defensive",
			Color = ExtraHotkeysColor,
			Toggle = IsDefensiveForce
		})
	end

	for index, data in pairs(Hotkeys) do
		local IsDoubleTap = data.Type == "DT"
		local TargetPercentage = (data.Toggle and 1 or 0)
		local HotkeySize = vector(renderer.measure_text("cbr", data.Text:upper()))
		local ScopedHotkeysTextSize = (CrosshairScopeAnimation and vector(renderer.measure_text("c-", data.Text:upper())) or EmptySize) * CrosshairScopeAnimationPercentage
		local HotkeysModifier = (HotkeyAnimation and CreateStaticTargetAnimation(0, TargetPercentage, HotkeyAnimationSmoothed, ("[%s]Hotkey"):format(data.Type)) or TargetPercentage) * CrosshairFraction
		DifferentOffset = DifferentOffset + (HotkeysModifier * 11)
		local TextPercentage = HotkeysModifier
		if IsDoubleTap and HotkeyAnimation then
			TextPercentage = TextPercentage * CreateStaticResetAnimation(0, 1, data.Toggle and CanAttack, 25, ("[%s]Hotkey"):format(data.Type))
		end

		if GlowText then
			local CurrentHotkeySize = (TextPercentage * HotkeySize.x)
            if CrosshairStyle == "Concen" then
			    RenderGlowOutline(BasePosition.x + 1 - (CurrentHotkeySize / 3) + 1 + (ScopedHotkeysTextSize.x / 2), BasePosition.y + 9 + DifferentOffset, (CurrentHotkeySize / 1.5), 0, GlowThickness, 0, {data.Color[1], data.Color[2], data.Color[3], GlowFraction * HotkeysModifier})
            elseif CrosshairStyle == "Manifold" then
                RenderGlowOutline(BasePosition.x - (CurrentHotkeySize / 3) + 2 + (ScopedHotkeysTextSize.x / 2) + ((CrosshairScopeAnimation and IsScoped) and 21 or 0), BasePosition.y + 9 + DifferentOffset, (CurrentHotkeySize / 1.5), 0, GlowThickness, 0, {data.Color[1], data.Color[2], data.Color[3], GlowFraction * HotkeysModifier})
		
            end
        end

		if HotkeysModifier > 0 and TextPercentage > 0 then
            if CrosshairStyle == "Concen" then
			    renderer.text(BasePosition.x + 1 + (ScopedHotkeysTextSize.x / 2), BasePosition.y + 10 + DifferentOffset, data.Color[1], data.Color[2], data.Color[3], HotkeysModifier * data.Color[4], "c-", TextPercentage * HotkeySize.x, data.Text:upper())
            elseif CrosshairStyle == "Manifold" then
			renderer.text(BasePosition.x + (ScopedHotkeysTextSize.x / 2) + ((CrosshairScopeAnimation and IsScoped) and 22 or 1), BasePosition.y + 10 + DifferentOffset, data.Color[1], data.Color[2], data.Color[3], HotkeysModifier * data.Color[4], "c-", TextPercentage * HotkeySize.x, data.Text:upper())
            end
        end
	end
    end

    local paint_manual = function()
	local local_player = entity.get_local_player()
	if not local_player or not entity.is_alive(local_player) then
		return
	end

	local PrevScoped = entity.get_prop(local_player, "m_bIsScoped")
	local ScreenSize = vector(client.screen_size())
	local CenterSize = ScreenSize / 2
	if ui.get(ManualIndication) then
		local IsScoped = PrevScoped == 1
		local ManualColor = {ui.get(ManualColor)}
		local ManualArrowsPulse = ui.get(ManualIndication)
		local ManualArrowStyle = ui.get(ManualArrowStyle)
		local ManualPulseSmoothed = 50 / 20
		local ManualDistance =  80
		local ManualHeightAnimation = 0
		local ManualModifier = ManualArrowsPulse and (math.sin(math.abs(- math.pi + (globals.curtime() * (5/ 6 - ManualPulseSmoothed)) % (math.pi * 2))) * ManualColor[4]) or ManualColor[4]
		local ManualArrows = ({
			["Mini"] = {"❮ ", "❯"},
			["<>"] = {"< ", ">"},
			["⯇⯈"] = {"⯇ ", "⯈"}
		})[ManualArrowStyle]
		if ManualArrowStyle == "<>" then
			renderer.text(CenterSize.x + 2 - 80 , CenterSize.y - 2 , 100, 100, 100, ManualModifier, "c+", 0, "< ")
			renderer.text(CenterSize.x + 2 + 80 , CenterSize.y - 2 , 100, 100, 100, ManualModifier, "c+", 0, ">")
		end

		if direction == - 90 or direction == 90 then
			if ManualArrowStyle == "Mini" then
				local CurrentFont = CreateSurfaceFont("Verdana", 23, 650, {0x010, 0x080})
				Surface.draw_text(CenterSize.x - 4 + (direction == - 90 and - ManualDistance or ManualDistance), CenterSize.y - 14 + ManualHeightAnimation, ManualColor[1], ManualColor[2], ManualColor[3], ManualModifier, CurrentFont, ManualArrows[direction == - 90 and 1 or 2])
			elseif ManualArrowStyle == "<>" then
				renderer.text(CenterSize.x + 2 + (direction == - 90 and - ManualDistance or ManualDistance), CenterSize.y - 2 + ManualHeightAnimation, ManualColor[1], ManualColor[2], ManualColor[3], ManualModifier, "c+", 0, ManualArrows[direction == - 90 and 1 or 2])
			else
				renderer.text(CenterSize.x + 2 + (direction == - 90 and - ManualDistance or ManualDistance), CenterSize.y - 2 + ManualHeightAnimation, ManualColor[1], ManualColor[2], ManualColor[3], ManualModifier, "c+", 0, ManualArrows[direction == - 90 and 1 or 2])
			end
		end
	end
    end




    for i = 1, #anti_aim_states do
        anti_aim_settings[i] = {
            override_state = ui.new_checkbox(tab, container, colors.main ..' • \aFFFFFFCEEnable ' .. anti_aim_states[i]),
            text7 = ui.new_label(tab, container, '\n'),
            pitch1 = ui.new_combobox(tab, container, colors.main ..' •  \aFFFFFF9BPitch   --------------------------------------' .. anti_aim_different[i], '-', 'Default', 'Up', 'Down', 'Minimal', 'Random', 'Custom'),
            pitch2 = ui.new_slider(tab, container, '\nPitch' .. anti_aim_different[i], -89, 89, 0, true, '°'),
            yaw_base = ui.new_combobox(tab, container, '\nYaw base' .. anti_aim_different[i], 'Local view', 'At targets'),
            text8 = ui.new_label(tab, container, '\n'),
            yaw1 = ui.new_combobox(tab, container,colors.main ..' •  \aFFFFFF9BYaw   ---------------------------------------' .. anti_aim_different[i], '-', '180', 'Spin', 'Static', '180 Z', 'Crosshair'),
            yaw2_left = ui.new_slider(tab, container, '\nYaw left' .. anti_aim_different[i], -180, 180, 0, true, '°L'),
            yaw2_right = ui.new_slider(tab, container, '\nYaw right' .. anti_aim_different[i], -180, 180, 0, true, '°R'),
            yaw2_randomize = ui.new_slider(tab, container, colors.main ..'\aFFFFFF9B •  Random' .. anti_aim_different[i], 0, 180, 0, true, '°'),
            text5 = ui.new_label(tab, container, '\n'),
            yaw_jitter1 = ui.new_combobox(tab, container, colors.main ..' •  \aFFFFFF9BDesync  ------------------------------------' .. anti_aim_different[i], '-', 'Offset', 'Center', 'Random', 'Skitter', 'Delay'),
            yaw_jitter2_delay = ui.new_slider(tab, container, '\nYaw jitter delay' .. anti_aim_different[i], 2, 10, 2, true, 't'),
            yaw_jitter2_left = ui.new_slider(tab, container, '\nYaw jitter left' .. anti_aim_different[i], -180, 180, 0, true, '°L'),
            yaw_jitter2_right = ui.new_slider(tab, container, '\nYaw jitter right' .. anti_aim_different[i], -180, 180, 0, true, '°R'),
            yaw_jitter2_randomize = ui.new_slider(tab, container, colors.main ..'\aFFFFFF9B •  Random' .. anti_aim_different[i], 0, 180, 0, true, '°'),
            text6 = ui.new_label(tab, container, '\n'),
            body_yaw1 = ui.new_combobox(tab, container, colors.main ..' •  \aFFFFFF9BBody yaw' .. anti_aim_different[i], '-', 'Opposite', 'Jitter', 'Static'),
            body_yaw2 = ui.new_slider(tab, container, '\nBody Yaw' .. anti_aim_different[i], -180, 180, 0, true, '°'),
            freestanding_body_yaw = ui.new_checkbox(tab, container, colors.main ..'\aFFFFFF9B •  FS body yaw' .. anti_aim_different[i]),
            roll = ui.new_slider(tab, container, colors.main ..'\aFFFFFF9B •  Roll' .. anti_aim_different[i], -45, 45, 0, true, '°'),
            defensive_anti_aimbot = ui.new_multiselect(tab, container, colors.main ..' •  \aFFFFFFCEDefensive anti-aim','Force', 'Defensive'),
            defensive_pitch = ui.new_multiselect(tab, container, '\ndefcondition' .. anti_aim_different[i], 'Pitch', 'Yaw', 'Yaw Jitter', 'Body Yaw'),
            defensive_pitch1 = ui.new_slider(tab, container,  colors.main ..'\aFFFFFF9B •  Pitch' .. anti_aim_different[i], 1, 7, 1, true, "", 1, { [1] = 'Off',[2] =  'Default',[3] =  'Up',[4] =  'Down',[5] =  'Minimal',[6] =  'Random',[7] =  'Custom'}),
            defensive_pitch2 = ui.new_slider(tab, container, '\n· Pitch 3' .. anti_aim_different[i], -89, 89, 0, true, '°'),
            defensive_pitch3 = ui.new_slider(tab, container, '\n· Pitch 4' .. anti_aim_different[i], -89, 89, 0, true, '°'),
            textdef1 = ui.new_label(tab, container, '\n'),
            defensive_yaw1 = ui.new_slider(tab, container, colors.main ..'\aFFFFFF9B •  Yaw' .. anti_aim_different[i], 1, 5, 1, true, "", 1, { [1] = '180',[2] = 'Spin',[3] = '180 Z',[4] = 'Sideways',[5] = 'Random'}),
            defensive_yaw2 = ui.new_slider(tab, container, '\n Yaw 2' .. anti_aim_different[i], -180, 180, 0, true, '°T'),
            textdef2 = ui.new_label(tab, container, '\n'),
            defensive_yawjitter1 = ui.new_slider(tab, container, colors.main ..'\aFFFFFF9B •  Desync' .. anti_aim_different[i], 1, 4, 1, true, "", 1, { [1] = 'Offset',[2] = 'Center',[3] = 'Random',[4] = 'Skitter'}),
            defensive_yawjitter2 = ui.new_slider(tab, container, '\nYaw jitter 2' .. anti_aim_different[i], -180, 180, 0, true, '°'),
            textdef3 = ui.new_label(tab, container, '\n'),
            defensive_body_yaw1 = ui.new_slider(tab, container, colors.main ..'\aFFFFFF9B •  Body yaw' .. anti_aim_different[i], 1, 3, 1, true, "", 1, { [1] = 'Opposite',[2] = 'Jitter',[3] = 'Static'}),
            defensive_body_yaw2 = ui.new_slider(tab, container, '\nBody Yaw 2' .. anti_aim_different[i], -180, 180, 0, true, '°'),
            force_defensive = ui.new_checkbox(tab, container, colors.main ..' •  \aFFFFFFCEForce defensive' .. anti_aim_different[i]),
            force_defensive_on_peek = ui.new_checkbox(tab, container,colors.main ..'\aFFFFFF9B •  Force defensive - on peek' .. anti_aim_different[i])
        }
    end

    settings.avoid_backstab = ui.new_checkbox(tab, container,'\aFFFFFF9B •  Avoid backstab')
    settings.safe_head_in_air = ui.new_checkbox(tab, container, colors.main ..' •  \aFFFFFFCESafe head in air')
    settings.manualantiaim = ui.new_label(tab, container, colors.main ..' •  \aFFFFFFCEManual anti-aim')
    settings.manual_left = ui.new_hotkey(tab, container, colors.main ..'\aFFFFFFCE    Left')
    settings.manual_right = ui.new_hotkey(tab, container, colors.main ..'\aFFFFFFCE    Right')
    settings.manual_forward = ui.new_hotkey(tab, container, colors.main ..'\aFFFFFFCE    Forward')
    settings.edge_yaw = ui.new_hotkey(tab, container, colors.main ..' •  \aFFFFFFCEEdge yaw')
    settings.freestanding = ui.new_hotkey(tab, container, colors.main ..' •  \aFFFFFFCEFreestanding')
    settings.freestanding_conditions = ui.new_multiselect(tab, container, '\nfs', 'Standing', 'Moving', 'Slow motion', 'Crouching', 'In air')
    settings.texttweaks = ui.new_label(tab, container,'\n1123')
    settings.tweaks = ui.new_multiselect(tab, container, colors.main ..' •  \aFFFFFF9BTweaks   -----------------------------------', 'Off jitter while freestanding', 'Off jitter on manual')


    local data = {
        integers = {
            settings.anti_aim_state,
            anti_aim_settings[1].override_state, anti_aim_settings[2].override_state, anti_aim_settings[3].override_state, anti_aim_settings[4].override_state, anti_aim_settings[5].override_state, anti_aim_settings[6].override_state, anti_aim_settings[7].override_state, anti_aim_settings[8].override_state, anti_aim_settings[9].override_state, anti_aim_settings[10].override_state,
            anti_aim_settings[1].text7, anti_aim_settings[2].text7, anti_aim_settings[3].text7, anti_aim_settings[4].text7, anti_aim_settings[5].text7, anti_aim_settings[6].text7, anti_aim_settings[7].text7, anti_aim_settings[8].text7, anti_aim_settings[9].text7, anti_aim_settings[10].text7,
            anti_aim_settings[1].text8, anti_aim_settings[2].text8, anti_aim_settings[3].text8, anti_aim_settings[4].text8, anti_aim_settings[5].text8, anti_aim_settings[6].text8, anti_aim_settings[7].text8, anti_aim_settings[8].text8, anti_aim_settings[9].text8, anti_aim_settings[10].text8,
            anti_aim_settings[1].force_defensive, anti_aim_settings[2].force_defensive, anti_aim_settings[3].force_defensive, anti_aim_settings[4].force_defensive, anti_aim_settings[5].force_defensive, anti_aim_settings[6].force_defensive, anti_aim_settings[7].force_defensive, anti_aim_settings[8].force_defensive, anti_aim_settings[9].force_defensive, anti_aim_settings[10].force_defensive,
            anti_aim_settings[1].force_defensive_on_peek, anti_aim_settings[2].force_defensive_on_peek, anti_aim_settings[3].force_defensive_on_peek, anti_aim_settings[4].force_defensive_on_peek, anti_aim_settings[5].force_defensive_on_peek, anti_aim_settings[6].force_defensive_on_peek, anti_aim_settings[7].force_defensive_on_peek, anti_aim_settings[8].force_defensive_on_peek, anti_aim_settings[9].force_defensive_on_peek, anti_aim_settings[10].force_defensive_on_peek,
            anti_aim_settings[1].pitch1, anti_aim_settings[2].pitch1, anti_aim_settings[3].pitch1, anti_aim_settings[4].pitch1, anti_aim_settings[5].pitch1, anti_aim_settings[6].pitch1, anti_aim_settings[7].pitch1, anti_aim_settings[8].pitch1, anti_aim_settings[9].pitch1, anti_aim_settings[10].pitch1,
            anti_aim_settings[1].pitch2, anti_aim_settings[2].pitch2, anti_aim_settings[3].pitch2, anti_aim_settings[4].pitch2, anti_aim_settings[5].pitch2, anti_aim_settings[6].pitch2, anti_aim_settings[7].pitch2, anti_aim_settings[8].pitch2, anti_aim_settings[9].pitch2, anti_aim_settings[10].pitch2,
            anti_aim_settings[1].yaw_base, anti_aim_settings[2].yaw_base, anti_aim_settings[3].yaw_base, anti_aim_settings[4].yaw_base, anti_aim_settings[5].yaw_base, anti_aim_settings[6].yaw_base, anti_aim_settings[7].yaw_base, anti_aim_settings[8].yaw_base, anti_aim_settings[9].yaw_base, anti_aim_settings[10].yaw_base,
            anti_aim_settings[1].yaw1, anti_aim_settings[2].yaw1, anti_aim_settings[3].yaw1, anti_aim_settings[4].yaw1, anti_aim_settings[5].yaw1, anti_aim_settings[6].yaw1, anti_aim_settings[7].yaw1, anti_aim_settings[8].yaw1, anti_aim_settings[9].yaw1, anti_aim_settings[10].yaw1,
            anti_aim_settings[1].yaw2_left, anti_aim_settings[2].yaw2_left, anti_aim_settings[3].yaw2_left, anti_aim_settings[4].yaw2_left, anti_aim_settings[5].yaw2_left, anti_aim_settings[6].yaw2_left, anti_aim_settings[7].yaw2_left, anti_aim_settings[8].yaw2_left, anti_aim_settings[9].yaw2_left, anti_aim_settings[10].yaw2_left,
            anti_aim_settings[1].yaw2_right, anti_aim_settings[2].yaw2_right, anti_aim_settings[3].yaw2_right, anti_aim_settings[4].yaw2_right, anti_aim_settings[5].yaw2_right, anti_aim_settings[6].yaw2_right, anti_aim_settings[7].yaw2_right, anti_aim_settings[8].yaw2_right, anti_aim_settings[9].yaw2_right, anti_aim_settings[10].yaw2_right,
            anti_aim_settings[1].text5, anti_aim_settings[2].text5, anti_aim_settings[3].text5, anti_aim_settings[4].text5, anti_aim_settings[5].text5, anti_aim_settings[6].text5, anti_aim_settings[7].text5, anti_aim_settings[8].text5, anti_aim_settings[9].text5, anti_aim_settings[10].text5,
            anti_aim_settings[1].textdef1, anti_aim_settings[2].textdef1, anti_aim_settings[3].textdef1, anti_aim_settings[4].textdef1, anti_aim_settings[5].textdef1, anti_aim_settings[6].textdef1, anti_aim_settings[7].textdef1, anti_aim_settings[8].textdef1, anti_aim_settings[9].textdef1, anti_aim_settings[10].textdef1,
            anti_aim_settings[1].textdef2, anti_aim_settings[2].textdef2, anti_aim_settings[3].textdef2, anti_aim_settings[4].textdef2, anti_aim_settings[5].textdef2, anti_aim_settings[6].textdef2, anti_aim_settings[7].textdef2, anti_aim_settings[8].textdef2, anti_aim_settings[9].textdef2, anti_aim_settings[10].textdef2,
            anti_aim_settings[1].textdef3, anti_aim_settings[2].textdef3, anti_aim_settings[3].textdef3, anti_aim_settings[4].textdef3, anti_aim_settings[5].textdef3, anti_aim_settings[6].textdef3, anti_aim_settings[7].textdef3, anti_aim_settings[8].textdef3, anti_aim_settings[9].textdef3, anti_aim_settings[10].textdef3,
            anti_aim_settings[1].yaw2_randomize, anti_aim_settings[2].yaw2_randomize, anti_aim_settings[3].yaw2_randomize, anti_aim_settings[4].yaw2_randomize, anti_aim_settings[5].yaw2_randomize, anti_aim_settings[6].yaw2_randomize, anti_aim_settings[7].yaw2_randomize, anti_aim_settings[8].yaw2_randomize, anti_aim_settings[9].yaw2_randomize, anti_aim_settings[10].yaw2_randomize,
            anti_aim_settings[1].yaw_jitter1, anti_aim_settings[2].yaw_jitter1, anti_aim_settings[3].yaw_jitter1, anti_aim_settings[4].yaw_jitter1, anti_aim_settings[5].yaw_jitter1, anti_aim_settings[6].yaw_jitter1, anti_aim_settings[7].yaw_jitter1, anti_aim_settings[8].yaw_jitter1, anti_aim_settings[9].yaw_jitter1, anti_aim_settings[10].yaw_jitter1,
            anti_aim_settings[1].yaw_jitter2_left, anti_aim_settings[2].yaw_jitter2_left, anti_aim_settings[3].yaw_jitter2_left, anti_aim_settings[4].yaw_jitter2_left, anti_aim_settings[5].yaw_jitter2_left, anti_aim_settings[6].yaw_jitter2_left, anti_aim_settings[7].yaw_jitter2_left, anti_aim_settings[8].yaw_jitter2_left, anti_aim_settings[9].yaw_jitter2_left, anti_aim_settings[10].yaw_jitter2_left,
            anti_aim_settings[1].yaw_jitter2_right, anti_aim_settings[2].yaw_jitter2_right, anti_aim_settings[3].yaw_jitter2_right, anti_aim_settings[4].yaw_jitter2_right, anti_aim_settings[5].yaw_jitter2_right, anti_aim_settings[6].yaw_jitter2_right, anti_aim_settings[7].yaw_jitter2_right, anti_aim_settings[8].yaw_jitter2_right, anti_aim_settings[9].yaw_jitter2_right, anti_aim_settings[10].yaw_jitter2_right,
            anti_aim_settings[1].yaw_jitter2_randomize, anti_aim_settings[2].yaw_jitter2_randomize, anti_aim_settings[3].yaw_jitter2_randomize, anti_aim_settings[4].yaw_jitter2_randomize, anti_aim_settings[5].yaw_jitter2_randomize, anti_aim_settings[6].yaw_jitter2_randomize, anti_aim_settings[7].yaw_jitter2_randomize, anti_aim_settings[8].yaw_jitter2_randomize, anti_aim_settings[9].yaw_jitter2_randomize, anti_aim_settings[10].yaw_jitter2_randomize,
            anti_aim_settings[1].yaw_jitter2_delay, anti_aim_settings[2].yaw_jitter2_delay, anti_aim_settings[3].yaw_jitter2_delay, anti_aim_settings[4].yaw_jitter2_delay, anti_aim_settings[5].yaw_jitter2_delay, anti_aim_settings[6].yaw_jitter2_delay, anti_aim_settings[7].yaw_jitter2_delay, anti_aim_settings[8].yaw_jitter2_delay, anti_aim_settings[9].yaw_jitter2_delay, anti_aim_settings[10].yaw_jitter2_delay,
            anti_aim_settings[1].defensive_yawjitter1, anti_aim_settings[2].defensive_yawjitter1, anti_aim_settings[3].defensive_yawjitter1, anti_aim_settings[4].defensive_yawjitter1, anti_aim_settings[5].defensive_yawjitter1, anti_aim_settings[6].defensive_yawjitter1, anti_aim_settings[7].defensive_yawjitter1, anti_aim_settings[8].defensive_yawjitter1, anti_aim_settings[9].defensive_yawjitter1, anti_aim_settings[10].defensive_yawjitter1,
            anti_aim_settings[1].defensive_yawjitter2, anti_aim_settings[2].defensive_yawjitter2, anti_aim_settings[3].defensive_yawjitter2, anti_aim_settings[4].defensive_yawjitter2, anti_aim_settings[5].defensive_yawjitter2, anti_aim_settings[6].defensive_yawjitter2, anti_aim_settings[7].defensive_yawjitter2, anti_aim_settings[8].defensive_yawjitter2, anti_aim_settings[9].defensive_yawjitter2, anti_aim_settings[10].defensive_yawjitter2,
            anti_aim_settings[1].defensive_body_yaw1, anti_aim_settings[2].defensive_body_yaw1, anti_aim_settings[3].defensive_body_yaw1, anti_aim_settings[4].defensive_body_yaw1, anti_aim_settings[5].defensive_body_yaw1, anti_aim_settings[6].defensive_body_yaw1, anti_aim_settings[7].defensive_body_yaw1, anti_aim_settings[8].defensive_body_yaw1, anti_aim_settings[9].defensive_body_yaw1, anti_aim_settings[10].defensive_body_yaw1,
            anti_aim_settings[1].defensive_body_yaw2, anti_aim_settings[2].defensive_body_yaw2, anti_aim_settings[3].defensive_body_yaw2, anti_aim_settings[4].defensive_body_yaw2, anti_aim_settings[5].defensive_body_yaw2, anti_aim_settings[6].defensive_body_yaw2, anti_aim_settings[7].defensive_body_yaw2, anti_aim_settings[8].defensive_body_yaw2, anti_aim_settings[9].defensive_body_yaw2, anti_aim_settings[10].defensive_body_yaw2,
            anti_aim_settings[1].text6, anti_aim_settings[2].text6, anti_aim_settings[3].text6, anti_aim_settings[4].text6, anti_aim_settings[5].text6, anti_aim_settings[6].text6, anti_aim_settings[7].text6, anti_aim_settings[8].text6, anti_aim_settings[9].text6, anti_aim_settings[10].text6,
            anti_aim_settings[1].body_yaw1, anti_aim_settings[2].body_yaw1, anti_aim_settings[3].body_yaw1, anti_aim_settings[4].body_yaw1, anti_aim_settings[5].body_yaw1, anti_aim_settings[6].body_yaw1, anti_aim_settings[7].body_yaw1, anti_aim_settings[8].body_yaw1, anti_aim_settings[9].body_yaw1, anti_aim_settings[10].body_yaw1,
            anti_aim_settings[1].body_yaw2, anti_aim_settings[2].body_yaw2, anti_aim_settings[3].body_yaw2, anti_aim_settings[4].body_yaw2, anti_aim_settings[5].body_yaw2, anti_aim_settings[6].body_yaw2, anti_aim_settings[7].body_yaw2, anti_aim_settings[8].body_yaw2, anti_aim_settings[9].body_yaw2, anti_aim_settings[10].body_yaw2,
            anti_aim_settings[1].freestanding_body_yaw, anti_aim_settings[2].freestanding_body_yaw, anti_aim_settings[3].freestanding_body_yaw, anti_aim_settings[4].freestanding_body_yaw, anti_aim_settings[5].freestanding_body_yaw, anti_aim_settings[6].freestanding_body_yaw, anti_aim_settings[7].freestanding_body_yaw, anti_aim_settings[8].freestanding_body_yaw, anti_aim_settings[9].freestanding_body_yaw, anti_aim_settings[10].freestanding_body_yaw,
            anti_aim_settings[1].roll, anti_aim_settings[2].roll, anti_aim_settings[3].roll, anti_aim_settings[4].roll, anti_aim_settings[5].roll, anti_aim_settings[6].roll, anti_aim_settings[7].roll, anti_aim_settings[8].roll, anti_aim_settings[9].roll, anti_aim_settings[10].roll,
            anti_aim_settings[1].defensive_pitch, anti_aim_settings[2].defensive_pitch, anti_aim_settings[3].defensive_pitch, anti_aim_settings[4].defensive_pitch, anti_aim_settings[5].defensive_pitch, anti_aim_settings[6].defensive_pitch, anti_aim_settings[7].defensive_pitch, anti_aim_settings[8].defensive_pitch, anti_aim_settings[9].defensive_pitch, anti_aim_settings[10].defensive_pitch,
            anti_aim_settings[1].defensive_pitch1, anti_aim_settings[2].defensive_pitch1, anti_aim_settings[3].defensive_pitch1, anti_aim_settings[4].defensive_pitch1, anti_aim_settings[5].defensive_pitch1, anti_aim_settings[6].defensive_pitch1, anti_aim_settings[7].defensive_pitch1, anti_aim_settings[8].defensive_pitch1, anti_aim_settings[9].defensive_pitch1, anti_aim_settings[10].defensive_pitch1,
            anti_aim_settings[1].defensive_pitch2, anti_aim_settings[2].defensive_pitch2, anti_aim_settings[3].defensive_pitch2, anti_aim_settings[4].defensive_pitch2, anti_aim_settings[5].defensive_pitch2, anti_aim_settings[6].defensive_pitch2, anti_aim_settings[7].defensive_pitch2, anti_aim_settings[8].defensive_pitch2, anti_aim_settings[9].defensive_pitch2, anti_aim_settings[10].defensive_pitch2,
            anti_aim_settings[1].defensive_pitch3, anti_aim_settings[2].defensive_pitch3, anti_aim_settings[3].defensive_pitch3, anti_aim_settings[4].defensive_pitch3, anti_aim_settings[5].defensive_pitch3, anti_aim_settings[6].defensive_pitch3, anti_aim_settings[7].defensive_pitch3, anti_aim_settings[8].defensive_pitch3, anti_aim_settings[9].defensive_pitch3, anti_aim_settings[10].defensive_pitch3,
            anti_aim_settings[1].defensive_anti_aimbot, anti_aim_settings[2].defensive_anti_aimbot, anti_aim_settings[3].defensive_anti_aimbot, anti_aim_settings[4].defensive_anti_aimbot, anti_aim_settings[5].defensive_anti_aimbot, anti_aim_settings[6].defensive_anti_aimbot, anti_aim_settings[7].defensive_anti_aimbot, anti_aim_settings[8].defensive_anti_aimbot, anti_aim_settings[9].defensive_anti_aimbot, anti_aim_settings[10].defensive_anti_aimbot,
            anti_aim_settings[1].defensive_yaw1, anti_aim_settings[2].defensive_yaw1, anti_aim_settings[3].defensive_yaw1, anti_aim_settings[4].defensive_yaw1, anti_aim_settings[5].defensive_yaw1, anti_aim_settings[6].defensive_yaw1, anti_aim_settings[7].defensive_yaw1, anti_aim_settings[8].defensive_yaw1, anti_aim_settings[9].defensive_yaw1, anti_aim_settings[10].defensive_yaw1,
            anti_aim_settings[1].defensive_yaw2, anti_aim_settings[2].defensive_yaw2, anti_aim_settings[3].defensive_yaw2, anti_aim_settings[4].defensive_yaw2, anti_aim_settings[5].defensive_yaw2, anti_aim_settings[6].defensive_yaw2, anti_aim_settings[7].defensive_yaw2, anti_aim_settings[8].defensive_yaw2, anti_aim_settings[9].defensive_yaw2, anti_aim_settings[10].defensive_yaw2,
            settings.avoid_backstab,
            settings.safe_head_in_air,
            settings.freestanding_conditions,
            settings.texttweaks,
            settings.tweaks, master_switch, console_filter, trashtalk, hitmarker, fastladder, clantagchanger, lag_debug, resolver
        }
    }
    local configs_elements = {
        builderchoice,
        settings.anti_aim_state,
        winpos,
        master_switch,
        console_filter,
        settings.avoid_backstab,
        settings.safe_head_in_air,
        settings.freestanding_conditions,
        settings.tweaks,
        data.integers.override_state,
        data.integers.force_defensive,
        data.integers.force_defensive_on_peek,
        data.integers.pitch1,
        data.integers.pitch2,
        data.integers.yaw_base,
        data.integers.yaw1,
        data.integers.yaw2_left,
        data.integers.yaw2_right,
        data.integers.yaw2_randomize,
        data.integers.yaw_jitter1,
        data.integers.yaw_jitter2_left,
        data.integers.yaw_jitter2_right,
        data.integers.yaw_jitter2_randomize,
        data.integers.yaw_jitter2_delay,
        data.integers.defensive_yawjitter1,
        data.integers.defensive_yawjitter2,
        data.integers.defensive_body_yaw1,
        data.integers.defensive_body_yaw2,
        data.integers.body_yaw1, 
        data.integers.body_yaw2,
        data.integers.freestanding_body_yaw,
        data.integers.roll,
        data.integers.defensive_pitch,
        data.integers.defensive_pitch1,
        data.integers.defensive_pitch2,
        data.integers.defensive_pitch3,
        data.integers.defensive_anti_aimbot,
        data.integers.defensive_yaw1,
        data.integers.defensive_yaw2,
    
        }
        local GetPackages = function()
            local Configs = {}
            for Key, Data in pairs(configs_elements) do
                local type = ui.type(Data)
                if type == "color_picker" then
                    Configs[Key] = {"Color", {ui.get(Data)}}
                elseif type ~= "color_picker" and type ~= "button" and type ~= "label" then
                    Configs[Key] = ui.get(Data)
                end
            end
            
            return Configs
        end
    
	local ExtrapolatePosition = function(player, origin, ticks)
	if not entity.is_alive(player) then
		return origin
	end

	local Velocity = vector(entity.get_prop(player, "m_vecVelocity"))
	return origin + ((Velocity * globals.tickinterval()) * ticks)
end

    local function import(text)
        local status, config =
            pcall(
            function()
                return json.parse(base64.decode(text))
            end
        )
        local status, config2 =
            pcall(
            function()
                return json.parse(base64.decode(text))
            end
        )
        if not status or status == nil then
            print("Casset.lua - error while importing!")
            return
        end
    
        if config ~= nil then
            for k, v in pairs(config) do
                k = ({[1] = 'integers'})[k]
    
                for k2, v2 in pairs(v) do
                    if k == 'integers' then 
                        ui.set(data[k][k2], v2)
                    end
                end
            end
        end
    

        print("Casset.lua - config successfully imported!")
    
    end
    
    client.set_event_callback('setup_command', function(cmd)
        local self = entity.get_local_player()
    
        if entity.get_player_weapon(self) == nil then return end
    
        local using = false
        local anti_aim_on_use = false
    
        local inverted = entity.get_prop(self, "m_flPoseParameter", 11) * 120 - 60
    
        local is_planting = entity.get_prop(self, 'm_bInBombZone') == 1 and entity.get_classname(entity.get_player_weapon(self)) == 'CC4' and entity.get_prop(self, 'm_iTeamNum') == 2
        local CPlantedC4 = entity.get_all('CPlantedC4')[1]
    
        local eye_x, eye_y, eye_z = client.eye_position()
        local pitch, yaw = client.camera_angles()
    
        local sin_pitch = math.sin(math.rad(pitch))
        local cos_pitch = math.cos(math.rad(pitch))
    
        local sin_yaw = math.sin(math.rad(yaw))
        local cos_yaw = math.cos(math.rad(yaw))
    
        local direction_vector = {cos_pitch * cos_yaw, cos_pitch * sin_yaw, -sin_pitch}
    
        local fraction, entity_index = client.trace_line(self, eye_x, eye_y, eye_z, eye_x + (direction_vector[1] * 8192), eye_y + (direction_vector[2] * 8192), eye_z + (direction_vector[3] * 8192))
    
        if CPlantedC4 ~= nil then
            dist_to_c4 = vector(entity.get_prop(self, 'm_vecOrigin')):dist(vector(entity.get_prop(CPlantedC4, 'm_vecOrigin')))
    
            if entity.get_prop(CPlantedC4, 'm_bBombDefused') == 1 then dist_to_c4 = 56 end
    
            is_defusing = dist_to_c4 < 56 and entity.get_prop(self, 'm_iTeamNum') == 3
        end
    
        if entity_index ~= -1 then
            if vector(entity.get_prop(self, 'm_vecOrigin')):dist(vector(entity.get_prop(entity_index, 'm_vecOrigin'))) < 146 then
                using = entity.get_classname(entity_index) ~= 'CWorld' and entity.get_classname(entity_index) ~= 'CFuncBrush' and entity.get_classname(entity_index) ~= 'CCSPlayer'
            end
        end
    

        if cmd.in_use == 1 and not using and not is_planting and not is_defusing and ui.get(anti_aim_settings[10].override_state) then cmd.buttons = bit.band(cmd.buttons, bit.bnot(bit.lshift(1, 5))); anti_aim_on_use = true; state_id = 10 else if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == false and (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == false and ui.get(anti_aim_settings[9].override_state) then anti_aim_on_use = false; state_id = 9 else if (cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0) and entity.get_prop(self, 'm_flDuckAmount') > 0.8 and ui.get(anti_aim_settings[8].override_state) then anti_aim_on_use = false; state_id = 8 elseif (cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0) and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and ui.get(anti_aim_settings[7].override_state) then anti_aim_on_use = false; state_id = 7 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and (entity.get_prop(self, 'm_flDuckAmount') > 0.8 or ui.get(reference.duck_peek_assist)) and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and ui.get(anti_aim_settings[6].override_state) then anti_aim_on_use = false; state_id = 6 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and entity.get_prop(self, 'm_flDuckAmount') > 0.8 and vector(entity.get_prop(self, 'm_vecVelocity')):length() < 2 and ui.get(anti_aim_settings[5].override_state) then anti_aim_on_use = false; state_id = 5 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == true and ui.get(anti_aim_settings[4].override_state) then anti_aim_on_use = false; state_id = 4 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == false and ui.get(anti_aim_settings[3].override_state) then anti_aim_on_use = false; state_id = 3 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() < 2 and entity.get_prop(self, 'm_flDuckAmount') < 0.8 and ui.get(anti_aim_settings[2].override_state) then anti_aim_on_use = false; state_id = 2 else anti_aim_on_use = false; state_id = 1 end end end
        if cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0 then freestanding_state_id = 5 elseif (entity.get_prop(self, 'm_flDuckAmount') > 0.8 or ui.get(reference.duck_peek_assist)) and bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 then freestanding_state_id = 4 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == true then freestanding_state_id = 3 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() > 2 and (ui.get(reference.slow_motion[1]) and ui.get(reference.slow_motion[2])) == false then freestanding_state_id = 2 elseif bit.band(entity.get_prop(self, 'm_fFlags'), 1) ~= 0 and vector(entity.get_prop(self, 'm_vecVelocity')):length() < 2 then freestanding_state_id = 1 end
        IsDefensiveForce = false
        cmd.force_defensive = ui.get(anti_aim_settings[state_id].force_defensive)
               
        PlayerStateName = anti_aim_states[state_id]
        if ui.get(anim_label) then
            
                ui.set(settings.manual_forward, 'On hotkey')
                ui.set(settings.manual_right, 'On hotkey')
                ui.set(settings.manual_left, 'On hotkey')
                
                if ui.get(anti_aim_settings[state_id].pitch1) == '-' then
                    ui.set(reference.pitch[1], 'Off')
                else
                    ui.set(reference.pitch[1], ui.get(anti_aim_settings[state_id].pitch1))
                end

                ui.set(reference.pitch[2], ui.get(anti_aim_settings[state_id].pitch2))
                ui.set(reference.yaw_base, (direction == 180 or direction == 90 or direction == -90) and anti_aim_on_use == false and 'Local view' or ui.get(anti_aim_settings[state_id].yaw_base))
                if ui.get(anti_aim_settings[state_id].yaw1) == '-' then
                    ui.set(reference.yaw[1], (direction == 180 or direction == 90 or direction == -90) and anti_aim_on_use == false and '180' or 'Off')
                else
                    ui.set(reference.yaw[1], (direction == 180 or direction == 90 or direction == -90) and anti_aim_on_use == false and '180' or ui.get(anti_aim_settings[state_id].yaw1))
                end
        

            if ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
                if inverted > 0 then
                    if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                        direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_left) or -90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_left) or 90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw_jitter2_left) or 180
        
                        last_press = globals.realtime()
                    end
                else
                    if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                        direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_right) or -90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw_jitter2_right) or 90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw_jitter2_right) or 180
        
                        last_press = globals.realtime()
                    end
                end
            else
                if inverted > 0 then
                    if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                        direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw2_left) or -90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw2_left) or 90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw2_left) or 180
        
                        last_press = globals.realtime()
                    end
                else
                    if ui.get(settings.manual_left) and last_press + 0.2 < globals.realtime() then
                        direction = direction == -90 and ui.get(anti_aim_settings[state_id].yaw2_right) or -90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_right) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 90 and ui.get(anti_aim_settings[state_id].yaw2_right) or 90
        
                        last_press = globals.realtime()
                    elseif ui.get(settings.manual_forward) and last_press + 0.2 < globals.realtime() then
                        direction = direction == 180 and ui.get(anti_aim_settings[state_id].yaw2_right) or 180
        
                        last_press = globals.realtime()
                    end
                end
            end
        end    

       	local allow_defensive_activate = true
        local refuse_defensive = false
	if ui.get(anti_aim_settings[state_id].force_defensive_on_peek) then
		allow_defensive_activate = false
		local tr = client.current_threat()
        		local me = entity.get_local_player()
		if tr then
			
			local vecEyePosition = vector(client.eye_position())
			local HeadPosition = vector(entity.hitbox_position(tr, 0))

			local EyePosition = ExtrapolatePosition(me, vecEyePosition, 2)
			local PredictEyePosition = ExtrapolatePosition(me, vecEyePosition, 32)

			local _, HeadDamage = client.trace_bullet(tr, EyePosition.x, EyePosition.y, EyePosition.z, HeadPosition.x, HeadPosition.y, HeadPosition.z)
			local _, PredictHeadDamage = client.trace_bullet(tr, PredictEyePosition.x, PredictEyePosition.y, PredictEyePosition.z, HeadPosition.x, HeadPosition.y, HeadPosition.z)
			if HeadDamage <= 0 and PredictHeadDamage > 0 then
				allow_defensive_activate = true

			end 


		end
	end

        if ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
            if math.random(0, 1) ~= 0 then
                yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
            else
                yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
            end
    
            if inverted > 0 then
                if yaw_jitter2_left == 180 then yaw_jitter2_left = -180 elseif yaw_jitter2_left == 90 then yaw_jitter2_left = 89 elseif yaw_jitter2_left == -90 then yaw_jitter2_left = -89 end
    
                if not (direction == 180 or direction == 90 or direction == -90) then direction = yaw_jitter2_left end
            else
                if yaw_jitter2_right == 180 then yaw_jitter2_right = -180 elseif yaw_jitter2_right == 90 then yaw_jitter2_right = 89 elseif yaw_jitter2_right == -90 then yaw_jitter2_right = -89 end
    
                if not (direction == 180 or direction == 90 or direction == -90) then direction = yaw_jitter2_right end
            end
        else
            if inverted > 0 then
                if math.random(0, 1) ~= 0 then yaw2_left = ui.get(anti_aim_settings[state_id].yaw2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) else yaw2_left = ui.get(anti_aim_settings[state_id].yaw2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) end
    
                if yaw2_left == 180 then yaw2_left = -180 elseif yaw2_left == 90 then yaw2_left = 89 elseif yaw2_left == -90 then yaw2_left = -89 end
    
                if not (direction == 90 or direction == -90 or direction == 180) then direction = yaw2_left end
            else
                if math.random(0, 1) ~= 0 then yaw2_right = ui.get(anti_aim_settings[state_id].yaw2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) else yaw2_right = ui.get(anti_aim_settings[state_id].yaw2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize)) end
    
                if yaw2_right == 180 then yaw2_right = -180 elseif yaw2_right == 90 then yaw2_right = 89 elseif yaw2_right == -90 then yaw2_right = -89 end
    
                if not (direction == 90 or direction == -90 or direction == 180) then direction = yaw2_right end
            end
        end
    
        if anti_aim_on_use == true then
            if ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
                if inverted > 0 then
                    if math.random(0, 1) ~= 0 then
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                    else
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                    end
                else
                    if math.random(0, 1) ~= 0 then
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                    else
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize))
                    end
                end
            else
                if inverted > 0 then
                    if math.random(0, 1) ~= 0 then
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                    else
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                    end
                else
                    if math.random(0, 1) ~= 0 then
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                    else
                        anti_aim_on_use_direction = ui.get(anti_aim_settings[state_id].yaw2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw2_randomize))
                    end
                end
            end
        end
    
        if direction > 180 or direction < -180 then direction = -180 end
        if anti_aim_on_use_direction > 180 or anti_aim_on_use_direction < -180 then anti_aim_on_use_direction = -180 end
    
        ui.set(reference.yaw[2], anti_aim_on_use == false and direction or anti_aim_on_use_direction)
        if ui.get(anti_aim_settings[state_id].yaw_jitter1) == '-' then
            ui.set(reference.yaw_jitter[1], ((direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false or ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' or 'Off') and 'Off')
        else
            ui.set(reference.yaw_jitter[1], ((direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false or ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' or ui.get(anti_aim_settings[state_id].yaw1) == '-') and 'Off' or ui.get(anti_aim_settings[state_id].yaw_jitter1))
        end
        if inverted > 0 then
            if math.random(0, 1) ~= 0 then yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) else yaw_jitter2_left = ui.get(anti_aim_settings[state_id].yaw_jitter2_left) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) end
    
            if yaw_jitter2_left > 180 or yaw_jitter2_left < -180 then yaw_jitter2_left = -180 end
    
            ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and yaw_jitter2_left or 0)
        else
            if math.random(0, 1) ~= 0 then yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) - math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) else yaw_jitter2_right = ui.get(anti_aim_settings[state_id].yaw_jitter2_right) + math.random(0, ui.get(anti_aim_settings[state_id].yaw_jitter2_randomize)) end
    
            if yaw_jitter2_right > 180 or yaw_jitter2_right < -180 then yaw_jitter2_right = -180 end
    
            ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and yaw_jitter2_right or 0)
        end
    
        if ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
            if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == true or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == true then
                ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or 'Static')
            else
                ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or 'Jitter')
            end
        else
            if ui.get(anti_aim_settings[state_id].body_yaw1) == '-' then
                ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or 'Off')
            else
                ui.set(reference.body_yaw[1], (direction == 180 or direction == 90 or direction == -90) and contains(settings.tweaks, 'Off jitter on manual') and anti_aim_on_use == false and 'Opposite' or ui.get(anti_aim_settings[state_id].body_yaw1))
            end
        end
    
        if cmd.command_number % ui.get(anti_aim_settings[state_id].yaw_jitter2_delay) + 1 > ui.get(anti_aim_settings[state_id].yaw_jitter2_delay) - 1 then
            delayed_jitter = not delayed_jitter
        end
    
        if ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' then
            if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == true or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == true then
                ui.set(reference.body_yaw[2], delayed_jitter and -90 or 90)
            else
                ui.set(reference.body_yaw[2], -60)
            end
        elseif ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].defensive_yawjitter1) == 5 then
            if (ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) == true or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])) == true then
                ui.set(reference.body_yaw[2], delayed_jitter and -90 or 90)
            else
                ui.set(reference.body_yaw[2], -40)
            end
        else
            ui.set(reference.body_yaw[2], ui.get(anti_aim_settings[state_id].body_yaw2))
        end
    
        ui.set(reference.freestanding_body_yaw, ui.get(anti_aim_settings[state_id].yaw1) ~= '-' and ui.get(anti_aim_settings[state_id].yaw_jitter1) == 'Delay' and false or ui.get(anti_aim_settings[state_id].freestanding_body_yaw))
        ui.set(reference.roll, ui.get(anti_aim_settings[state_id].roll))
	-- is_defensive_active = true

	 allow_defensive_activate = true
     refuse_defensive = false
    if (entity_get_player_weapon(entity_get_local_player()) ~= nil and globals_curtime() < entity_get_prop(entity_get_player_weapon(entity_get_local_player()), "m_fLastShotTime", 0) + globals_tickinterval() * 2) or (ui.get(reference.duck_peek_assist)) then
        if not ui.get(reference.on_shot_anti_aim[2]) then
            defensive_wait_ticks = globals_tickcount() +(recorded_max_tickbase) 
        end
    end

    if defensive_wait_ticks > globals_tickcount() then
        refuse_defensive = true
    end

        if contains(anti_aim_settings[state_id].defensive_anti_aimbot, "Defensive") and is_defensive_active and allow_defensive_activate and not refuse_defensive and ((ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])) or (ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2]))) and not (direction == 180 or direction == 90 or direction == -90) then

            if contains(anti_aim_settings[state_id].defensive_pitch, 'Pitch') then
                if ui.get(anti_aim_settings[state_id].defensive_pitch1) == 1 then
                    ui.set(reference.pitch[1], 'Off')
                elseif ui.get(anti_aim_settings[state_id].defensive_pitch1) == 2 then
                    ui.set(reference.pitch[1], 'Default')
                elseif ui.get(anti_aim_settings[state_id].defensive_pitch1) == 3 then
                    ui.set(reference.pitch[1], 'Up')
                elseif ui.get(anti_aim_settings[state_id].defensive_pitch1) == 4 then
                    ui.set(reference.pitch[1], 'Down')
                elseif ui.get(anti_aim_settings[state_id].defensive_pitch1) == 5 then
                    ui.set(reference.pitch[1], 'Minimal')
                elseif ui.get(anti_aim_settings[state_id].defensive_pitch1) == 7 then
                    ui.set(reference.pitch[1], 'Custom')
                    ui.set(reference.pitch[2], ui.get(anti_aim_settings[state_id].defensive_pitch2))
    
                elseif ui.get(anti_aim_settings[state_id].defensive_pitch1) == 6 then
                    ui.set(reference.pitch[1], 'Custom')
                    ui.set(reference.pitch[2], math.random(ui.get(anti_aim_settings[state_id].defensive_pitch2), ui.get(anti_aim_settings[state_id].defensive_pitch3)))
                else
                    ui.set(reference.pitch[2], ui.get(anti_aim_settings[state_id].defensive_pitch2))
                end
            end
    
            if contains(anti_aim_settings[state_id].defensive_pitch, 'Yaw') then
                ui.set(reference.yaw_jitter[1], 'Off')
                ui.set(reference.body_yaw[1], 'Opposite')
    
                if ui.get(anti_aim_settings[state_id].defensive_yaw1) == 1 then
                    ui.set(reference.yaw[1], '180')
    
                    ui.set(reference.yaw[2], ui.get(anti_aim_settings[state_id].defensive_yaw2))
                elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 2 then
                    ui.set(reference.yaw[1], 'Spin')
    
                    ui.set(reference.yaw[2], ui.get(anti_aim_settings[state_id].defensive_yaw2))
                elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 3 then
                    ui.set(reference.yaw[1], '180 Z')
    
                    ui.set(reference.yaw[2], ui.get(anti_aim_settings[state_id].defensive_yaw2))
                elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 4 then
                    ui.set(reference.yaw[1], '180')
    
                    if cmd.command_number % 3 >= 2 then
                        ui.set(reference.yaw[2], math.random(85, 100))
                    else
                        ui.set(reference.yaw[2], math.random(-100, -85))
                    end
                elseif ui.get(anti_aim_settings[state_id].defensive_yaw1) == 5 then
                    ui.set(reference.yaw[1], '180')
    
                    ui.set(reference.yaw[2], math.random(-180, 180))
                end
            end
            if contains(anti_aim_settings[state_id].defensive_pitch, 'Yaw Jitter') then
                if ui.get(anti_aim_settings[state_id].defensive_yawjitter1) == 1 then
                    ui.set(reference.yaw_jitter[1], 'Offset')
    
                    ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].defensive_yawjitter2))
                elseif ui.get(anti_aim_settings[state_id].defensive_yawjitter1) == 2 then
                    ui.set(reference.yaw_jitter[1], 'Center')
    
                    ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].defensive_yawjitter2))
                elseif ui.get(anti_aim_settings[state_id].defensive_yawjitter1) == 3 then
                    ui.set(reference.yaw_jitter[1], 'Random')
    
                    ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].defensive_yawjitter2))
                elseif ui.get(anti_aim_settings[state_id].defensive_yawjitter1) == 4 then
                    ui.set(reference.yaw_jitter[1], 'Skitter')
                    ui.set(reference.yaw_jitter[2], ui.get(anti_aim_settings[state_id].defensive_yawjitter2))
                end
            end
            if contains(anti_aim_settings[state_id].defensive_pitch, 'Body Yaw') then
                if ui.get(anti_aim_settings[state_id].defensive_body_yaw1) == 1 then
                    ui.set(reference.body_yaw[1], 'Opposite')
    
                    ui.set(reference.body_yaw[2], ui.get(anti_aim_settings[state_id].defensive_body_yaw2))
                elseif ui.get(anti_aim_settings[state_id].defensive_body_yaw1) == 2 then
                    ui.set(reference.body_yaw[1], 'Jitter')
    
                    ui.set(reference.body_yaw[2], ui.get(anti_aim_settings[state_id].defensive_body_yaw2))
                elseif ui.get(anti_aim_settings[state_id].defensive_body_yaw1) == 3 then
                    ui.set(reference.body_yaw[1], 'Static')
    
                    ui.set(reference.body_yaw[2], ui.get(anti_aim_settings[state_id].defensive_body_yaw2))
                end
            end
        end
    
        if ui.get(settings.safe_head_in_air) and (cmd.in_jump == 1 or bit.band(entity.get_prop(self, 'm_fFlags'), 1) == 0) and entity.get_prop(self, 'm_flDuckAmount') > 0.8 and (entity.get_classname(entity.get_player_weapon(self)) == 'CKnife' or entity.get_classname(entity.get_player_weapon(self)) == 'CWeaponTaser') and anti_aim_on_use == false and not (direction == 180 or direction == 90 or direction == -90) then
            ui.set(reference.pitch[1], 'Down')
            ui.set(reference.yaw[1], '180')
            ui.set(reference.yaw[2], 0)
            ui.set(reference.yaw_jitter[1], 'Off')
            ui.set(reference.body_yaw[1], 'Off')
            ui.set(reference.roll, 0)
        end
    
        ui.set(reference.edge_yaw, ui.get(settings.edge_yaw) and anti_aim_on_use == false and true or false)
    
        if ui.get(settings.freestanding) and ((contains(settings.freestanding_conditions, 'Standing') and freestanding_state_id == 1) or (contains(settings.freestanding_conditions, 'Moving') and freestanding_state_id == 2) or (contains(settings.freestanding_conditions, 'Slow motion') and freestanding_state_id == 3) or (contains(settings.freestanding_conditions, 'Crouching') and freestanding_state_id == 4) or (contains(settings.freestanding_conditions, 'In air') and freestanding_state_id == 5)) and anti_aim_on_use == false and not (direction == 180 or direction == 90 or direction == -90) then
            ui.set(reference.freestanding[1], true)
            ui.set(reference.freestanding[2], 'Always on')
    
            if contains(settings.tweaks, 'Off jitter while freestanding') then
                ui.set(reference.yaw[1], '180')
                ui.set(reference.yaw[2], 0)
                ui.set(reference.yaw_jitter[1], 'Off')
                ui.set(reference.body_yaw[1], 'Opposite')
                ui.set(reference.body_yaw[2], 0)
                ui.set(reference.freestanding_body_yaw, true)
            end
        else
            ui.set(reference.freestanding[1], false)
            ui.set(reference.freestanding[2], 'On hotkey')
        end
    
        if ui.get(settings.avoid_backstab) and anti_aim_on_use == false and not (direction == 180 or direction == 90 or direction == -90) then
            local players = entity.get_players(true)
    
            if players ~= nil then
                for i, enemy in pairs(players) do
                    for h = 0, 18 do
                        local head_x, head_y, head_z = entity.hitbox_position(players[i], h)
                        local wx, wy = renderer.world_to_screen(head_x, head_y, head_z)
                        local fractions, entindex_hit = client.trace_line(self, eye_x, eye_y, eye_z, head_x, head_y, head_z)
    
                        if 250 >= vector(entity.get_prop(enemy, 'm_vecOrigin')):dist(vector(entity.get_prop(self, 'm_vecOrigin'))) and entity.is_alive(enemy) and entity.get_player_weapon(enemy) ~= nil and entity.get_classname(entity.get_player_weapon(enemy)) == 'CKnife' and (entindex_hit == players[i] or fractions == 1) and not entity.is_dormant(players[i]) then
                            ui.set(reference.yaw[1], '180')
                            ui.set(reference.yaw[2], -180)
                        end
                    end
                end
            end
        end
    end)


    local function rgba_to_hex(r, g, b, a)
        return bit.tohex(r, 2) .. bit.tohex(g, 2) .. bit.tohex(b, 2) .. bit.tohex(a, 2)
    end
    local fade_text = function(rgba, text)
        local final_text = ""
        local curtime = globals.curtime()
        local r, g, b, a = unpack(rgba)

        for i = 1, #text do
            local color = rgba_to_hex(r, g, b, a * math.abs(1 * math.cos(2 * 3 * curtime / 4 + i * 5 / 30)))
            final_text = final_text .. "\a" .. color .. text:sub(i, i)
        end

        return final_text
    end
    local function on_paint()
        local me = entity.get_local_player()
        if me == nil then return end
        local rr,gg,bb = 87, 235, 61
        local width, height = client.screen_size()
        local r2, g2, b2, a2 = 55, 55, 55,255
        local highlight_fraction =  (globals.realtime() / 2 % 1.2 * 2) - 1.2
        local output = ""
        local text_to_draw = "C A S S E T - L U A"
        for idx = 1, #text_to_draw do
            local character = text_to_draw:sub(idx, idx)
            local character_fraction = idx / #text_to_draw
            local r1, g1, b1, a1 = 255, 255, 255, 255
            local highlight_delta = (character_fraction - highlight_fraction)
            if highlight_delta >= 0 and highlight_delta <= 1.4 then
                if highlight_delta > 0.7 then
                highlight_delta = 1.4 - highlight_delta
                end
                local r_fraction, g_fraction, b_fraction, a_fraction = r2 - r1, g2 - g1, b2 - b1
                r1 = r1 + r_fraction * highlight_delta / 0.8
                g1 = g1 + g_fraction * highlight_delta / 0.8
                b1 = b1 + b_fraction * highlight_delta / 0.8
            end
            output = output .. ('\a%02x%02x%02x%02x%s'):format(r1, g1, b1, 255, text_to_draw:sub(idx, idx))
        end
        output = output
        
        local r,g,b,a = 87, 235, 61
        renderer.text(width - (width-90), height - 555, r, g, b, 255, "cbr", 0, output .. ' \aB9B7F1FF[Beta]')
    end
    client.set_event_callback("paint", on_paint)
    
    client.set_event_callback('paint_ui', function()
        if entity.get_local_player() == nil then cheked_ticks = 0 end
    
        if ui.is_menu_open() then
            ui.set_visible(reference.pitch[1], false)
            ui.set_visible(reference.pitch[2], false)
            ui.set_visible(reference.enabled, false)
            ui.set_visible(reference.lm, false)
            ui.set_visible(reference.enablefl, false)
            ui.set_visible(reference.yaw_base, false)
            ui.set_visible(reference.fakelag[1], false)
            ui.set_visible(reference.fl_var, false)
            ui.set_visible(reference.fl_amount, false)
            ui.set_visible(reference.yaw[1], false)
            ui.set_visible(reference.yaw[2], false)
            ui.set_visible(reference.yaw_jitter[1], false)
            ui.set_visible(reference.yaw_jitter[2], false)
            ui.set_visible(reference.body_yaw[1], false)
            ui.set_visible(reference.body_yaw[2], false)
            ui.set_visible(reference.freestanding_body_yaw, false)
            ui.set_visible(reference.edge_yaw, false)
            ui.set_visible(reference.freestanding[1], false)
            ui.set_visible(reference.freestanding[2], false)
            ui.set_visible(reference.roll, false)
            ui.set_visible(settings.anti_aim_state, aa_tab and ui.get(builderchoice) == 'Builder')
            ui.set_visible(settings.avoid_backstab, misc_tab)
            ui.set_visible(settings.safe_head_in_air, misc_tab and ui.get(builderchoice) == 'Builder')
            ui.set_visible(settings.manual_forward, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.manualantiaim, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.manual_right, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.manual_left, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.edge_yaw, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.freestanding, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.freestanding_conditions, aa_tab and ui.get(builderchoice) == 'Keybinds')
            ui.set_visible(settings.texttweaks, aa_tab and ui.get(builderchoice) == 'Builder')
            ui.set_visible(settings.tweaks, aa_tab and ui.get(builderchoice) == 'Builder')
            ui.set_visible(trashtalk, misc_tab)
            ui.set_visible(m_elements, misc_tab)
            ui.set_visible(slide_elements, misc_tab and contains(m_elements, "Slide slow-walking"))
            ui.set_visible(body_lean_value, misc_tab and contains(m_elements, "Body lean"))
            ui.set_visible(break_air_value, misc_tab and contains(m_elements, "Leg Breaker-in air"))
            ui.set_visible(master_switch, vis_tab)
            ui.set_visible(winpos, vis_tab)
            ui.set_visible(console_filter, vis_tab)
            ui.set_visible(hitmarker, vis_tab)
            ui.set_visible(ManualIndication, vis_tab)
            ui.set_visible(ManualColor, vis_tab and ui.get(ManualIndication))
            ui.set_visible(ManualArrowStyle, vis_tab and ui.get(ManualIndication))
            ui.set_visible(CrosshairIndication, vis_tab)
            ui.set_visible(CrosshairStyle, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairNameStyle, false)
            ui.set_visible(HitlogIndication, vis_tab)
            ui.set_visible(HitlogColor, vis_tab and ui.get(HitlogIndication))
            ui.set_visible(HitlogStyle, vis_tab and ui.get(HitlogIndication))
            ui.set_visible(HitlogBackgroundStyle, vis_tab and ui.get(HitlogIndication))

            

            ui.set_visible(CrosshairBarLabel, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairBarColor, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairRealSideLabel, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairRealSideColor, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairFakeSideLabel, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairFakeSideColor, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairAnimationStyle, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairAnimationSide, vis_tab and ui.get(CrosshairIndication) and ui.get(CrosshairAnimationStyle) ~= "Stationary")
            ui.set_visible(CrosshairHotkeyStyle, vis_tab and ui.get(CrosshairIndication))
            ui.set_visible(CrosshairHotkeysDoubleTapLabel, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(CrosshairHotkeysDoubleTapColor, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(CrosshairHotkeysonshotLabel, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(CrosshairHotkeysonshotColor, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(CrosshairHotkeysOtherLabel, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(CrosshairHotkeysOtherColor, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(CrosshairHotkeysExtraLabel, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Complete"))
            ui.set_visible(CrosshairHotkeysExtraColor, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Complete"))
            ui.set_visible(CrosshairHotkeySettings, vis_tab and ui.get(CrosshairIndication) and contains(CrosshairHotkeyStyle, "Simplicity"))
            ui.set_visible(fastladder, misc_tab)
            ui.set_visible(clantagchanger, misc_tab)
            ui.set_visible(lag_debug, misc_tab)
            ui.set_visible(resolver, misc_tab)
            ui.set_visible(text4, true)
            ui.set_visible(anim_label, true)
            ui.set_visible(text11234, true)
            ui.set_visible(builderchoice, aa_tab)
            ui.set(anim_label, fade_text(colors.main_rgba, "Casset_Dev"))
            ui.set(reference.fl_amount, "Maximum")
            ui.set(reference.fl_var, 10)
            ui.set(reference.fakelag[1], 14)
    
            for i = 1, #anti_aim_states do
                ui.set_visible(anti_aim_settings[i].override_state, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i]); ui.set(anti_aim_settings[1].override_state, true); ui.set_visible(anti_aim_settings[1].override_state, false)
                ui.set_visible(anti_aim_settings[i].text7, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i]); ui.set(anti_aim_settings[1].override_state, true); ui.set_visible(anti_aim_settings[1].override_state, false)
                ui.set_visible(anti_aim_settings[i].force_defensive, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Force"));
                ui.set_visible(anti_aim_settings[i].force_defensive_on_peek, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive")); ui.set_visible(anti_aim_settings[9].force_defensive, false)
                ui.set_visible(anti_aim_settings[i].pitch1,aa_tab and ui.get(builderchoice) == 'Builder' and  ui.get(settings.anti_aim_state) == anti_aim_states[i])
                ui.set_visible(anti_aim_settings[i].pitch2, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].pitch1) == 'Custom')
                ui.set_visible(anti_aim_settings[i].yaw_base, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i])
                ui.set_visible(anti_aim_settings[i].yaw1, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i])
                ui.set_visible(anti_aim_settings[i].yaw2_left, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= '-' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay')
                ui.set_visible(anti_aim_settings[i].yaw2_right, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= '-' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay')
                ui.set_visible(anti_aim_settings[i].text5, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= '-')
                ui.set_visible(anti_aim_settings[i].textdef1, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive")  and contains(anti_aim_settings[i].defensive_pitch, 'Pitch'))
                ui.set_visible(anti_aim_settings[i].textdef2, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive")  and contains(anti_aim_settings[i].defensive_pitch, 'Yaw'))
                ui.set_visible(anti_aim_settings[i].textdef3, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive")  and contains(anti_aim_settings[i].defensive_pitch, 'Yaw Jitter'))
                ui.set_visible(anti_aim_settings[i].yaw2_randomize, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw1) ~= '-' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay')
                ui.set_visible(anti_aim_settings[i].yaw_jitter1, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] )
                ui.set_visible(anti_aim_settings[i].yaw_jitter2_left, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) ~= '-')
                ui.set_visible(anti_aim_settings[i].yaw_jitter2_right, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) ~= '-')
                ui.set_visible(anti_aim_settings[i].yaw_jitter2_randomize, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) ~= '-')
                ui.set_visible(anti_aim_settings[i].yaw_jitter2_delay, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) == 'Delay')
                ui.set_visible(anti_aim_settings[i].text6, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= '-')
                ui.set_visible(anti_aim_settings[i].body_yaw1, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay')
                ui.set_visible(anti_aim_settings[i].body_yaw2, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and (ui.get(anti_aim_settings[i].body_yaw1) ~= '-' and ui.get(anti_aim_settings[i].body_yaw1) ~= 'Opposite') and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay')
                ui.set_visible(anti_aim_settings[i].freestanding_body_yaw, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(anti_aim_settings[i].body_yaw1) ~= '-' and ui.get(anti_aim_settings[i].yaw_jitter1) ~= 'Delay')
                ui.set_visible(anti_aim_settings[i].roll, aa_tab and ui.get(settings.anti_aim_state) == anti_aim_states[i] and ui.get(builderchoice) == 'Builder')
                ui.set_visible(anti_aim_settings[i].defensive_anti_aimbot, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i])
                ui.set_visible(anti_aim_settings[i].defensive_pitch, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive")); ui.set_visible(anti_aim_settings[9].defensive_pitch, false)
                ui.set_visible(anti_aim_settings[i].text8, aa_tab and ui.get(builderchoice) == 'Builder' and ui.get(settings.anti_aim_state) == anti_aim_states[i]); ui.set(anti_aim_settings[1].override_state, true); ui.set_visible(anti_aim_settings[1].override_state, false)
                ui.set_visible(anti_aim_settings[i].defensive_pitch1, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Pitch')); ui.set_visible(anti_aim_settings[9].defensive_pitch1, false)
                ui.set_visible(anti_aim_settings[i].defensive_pitch2, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Pitch') and (ui.get(anti_aim_settings[i].defensive_pitch1) == 6 or ui.get(anti_aim_settings[i].defensive_pitch1) == 7)); ui.set_visible(anti_aim_settings[9].defensive_pitch2, false)
                ui.set_visible(anti_aim_settings[i].defensive_pitch3, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Pitch') and ui.get(anti_aim_settings[i].defensive_pitch1) == 6); ui.set_visible(anti_aim_settings[9].defensive_pitch3, false)
                ui.set_visible(anti_aim_settings[i].defensive_yaw1, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Yaw')); ui.set_visible(anti_aim_settings[9].defensive_yaw1, false)
                ui.set_visible(anti_aim_settings[i].defensive_yaw2, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Yaw')); ui.set_visible(anti_aim_settings[9].defensive_yaw2, false)
                ui.set_visible(anti_aim_settings[i].defensive_yawjitter1, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Yaw Jitter')); ui.set_visible(anti_aim_settings[9].defensive_yawjitter1, false)
                ui.set_visible(anti_aim_settings[i].defensive_yawjitter2, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Yaw Jitter')); ui.set_visible(anti_aim_settings[9].defensive_yawjitter2, false)
                ui.set_visible(anti_aim_settings[i].defensive_body_yaw1, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Body Yaw')); ui.set_visible(anti_aim_settings[9].defensive_yawjitter1, false)
                ui.set_visible(anti_aim_settings[i].defensive_body_yaw2, aa_tab and ui.get(builderchoice) == 'Defensive' and ui.get(settings.anti_aim_state) == anti_aim_states[i] and contains(anti_aim_settings[i].defensive_anti_aimbot, "Defensive") and contains(anti_aim_settings[i].defensive_pitch, 'Body Yaw')); ui.set_visible(anti_aim_settings[9].defensive_yawjitter2, false)
            end
        end
    end)

        
    local NotifyLogIndex = 0
    local SettingsSvg = renderer.load_svg([[<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg">
    <path d="M13.0242 9.24999C13.4944 9.24999 13.8513 8.81719 13.6614 8.38695C13.0412 6.9812 11.6352 6 10 6C9.85376 6 9.70936 6.00785 9.56719 6.02314C9.09929 6.07349 8.90249 6.59904 9.13779 7.00659L10.2165 8.87499C10.3505 9.10704 10.5981 9.24999 10.866 9.24999L13.0242 9.24999Z" fill="#FFF"/>
    <path d="M7.83948 7.75785C7.60411 7.35018 7.05027 7.25778 6.77194 7.63742C6.28661 8.29942 6 9.11624 6 10C6 10.8838 6.28662 11.7006 6.77198 12.3626C7.05031 12.7423 7.60415 12.6499 7.83952 12.2422L8.91751 10.3751C9.05149 10.143 9.05149 9.85711 8.91751 9.62506L7.83948 7.75785Z" fill="#FFF"/>
    <path d="M9.13785 12.9934C8.90255 13.401 9.09936 13.9265 9.56726 13.9769C9.70941 13.9922 9.85379 14 10 14C11.6352 14 13.0412 13.0188 13.6614 11.613C13.8513 11.1828 13.4944 10.75 13.0242 10.75H10.8661C10.5982 10.75 10.3506 10.8929 10.2166 11.125L9.13785 12.9934Z" fill="#FFF"/>
    <path fill-rule="evenodd" clip-rule="evenodd" d="M14.1295 4.34724L14.7744 3.23028C14.9815 2.87156 14.8586 2.41286 14.4999 2.20576C14.1412 1.99865 13.6825 2.12156 13.4754 2.48028L12.8311 3.59615C12.1832 3.30927 11.4835 3.11784 10.75 3.03971V1.75C10.75 1.33579 10.4142 1 10 1C9.58579 1 9.25 1.33579 9.25 1.75V3.03971C8.51649 3.11784 7.81683 3.30927 7.16886 3.59616L6.52462 2.4803C6.31752 2.12158 5.85882 1.99867 5.5001 2.20578C5.14139 2.41289 5.01848 2.87158 5.22559 3.2303L5.87046 4.34725C5.28784 4.7736 4.77359 5.28784 4.34725 5.87046L3.23009 5.22547C2.87137 5.01836 2.41267 5.14127 2.20557 5.49999C1.99846 5.85871 2.12137 6.3174 2.48009 6.52451L3.59615 7.16887C3.30927 7.81683 3.11784 8.51649 3.03971 9.25H1.75C1.33579 9.25 1 9.58579 1 10C1 10.4142 1.33579 10.75 1.75 10.75H3.03971C3.11784 11.4835 3.30926 12.1832 3.59614 12.8311L2.48009 13.4755C2.12137 13.6826 1.99846 14.1413 2.20557 14.5C2.41267 14.8587 2.87137 14.9816 3.23009 14.7745L4.34723 14.1295C4.77355 14.7121 5.28775 15.2263 5.87031 15.6526L5.22538 16.7697C5.01827 17.1284 5.14118 17.5871 5.4999 17.7942C5.85861 18.0013 6.31731 17.8784 6.52441 17.5197L7.1687 16.4038C7.81671 16.6907 8.51643 16.8822 9.25 16.9603V18.25C9.25 18.6642 9.58579 19 10 19C10.4142 19 10.75 18.6642 10.75 18.25V16.9603C11.4836 16.8822 12.1833 16.6907 12.8313 16.4038L13.4756 17.5197C13.6827 17.8784 14.1414 18.0013 14.5001 17.7942C14.8588 17.5871 14.9817 17.1284 14.7746 16.7697L14.1297 15.6526C14.7122 15.2263 15.2264 14.7121 15.6527 14.1296L16.7698 14.7745C17.1285 14.9816 17.5872 14.8587 17.7943 14.5C18.0014 14.1413 17.8785 13.6826 17.5198 13.4755L16.4038 12.8312C16.6907 12.1832 16.8822 11.4835 16.9603 10.75H18.25C18.6642 10.75 19 10.4142 19 10C19 9.58579 18.6642 9.25 18.25 9.25H16.9603C16.8822 8.51646 16.6907 7.81678 16.4038 7.16879L17.5198 6.52451C17.8785 6.3174 18.0014 5.85871 17.7943 5.49999C17.5872 5.14127 17.1285 5.01836 16.7698 5.22547L15.6527 5.8704C15.2264 5.2878 14.7121 4.77358 14.1295 4.34724ZM10 4.5C9.0112 4.5 8.08334 4.76094 7.28153 5.2177C7.27126 5.22431 7.26079 5.2307 7.2501 5.23687C7.23978 5.24283 7.22937 5.24852 7.21889 5.25393C6.40668 5.7309 5.72776 6.4104 5.25148 7.22307C5.24674 7.2321 5.2418 7.24107 5.23666 7.24999C5.2313 7.25926 5.22578 7.26837 5.2201 7.27733C4.76185 8.0801 4.5 9.00947 4.5 10C4.5 10.9904 4.76179 11.9197 5.21995 12.7224C5.22569 12.7314 5.23126 12.7406 5.23666 12.75C5.24185 12.759 5.24683 12.768 5.25161 12.7772C5.72819 13.5903 6.40765 14.27 7.2205 14.747C7.23036 14.7521 7.24017 14.7575 7.2499 14.7631C7.26 14.769 7.26992 14.775 7.27965 14.7812C8.08189 15.2387 9.01042 15.5 10 15.5C10.9897 15.5 11.9184 15.2386 12.7207 14.781C12.7303 14.7749 12.7401 14.7689 12.7501 14.7632C12.7597 14.7576 12.7694 14.7523 12.7792 14.7472C13.5913 14.2707 14.2704 13.5918 14.7469 12.7797C14.7521 12.7697 14.7575 12.7598 14.7632 12.75C14.7691 12.7398 14.7751 12.7298 14.7814 12.72C15.2387 11.9179 15.5 10.9894 15.5 10C15.5 9.01046 15.2387 8.08196 14.7813 7.27974C14.7751 7.27001 14.769 7.26009 14.7632 7.24999C14.7576 7.24025 14.7522 7.23044 14.7471 7.22057C14.2708 6.40891 13.5923 5.73024 12.7808 5.25375C12.7704 5.24838 12.7601 5.24275 12.7499 5.23685C12.7393 5.23074 12.7289 5.22441 12.7188 5.21788C11.9169 4.761 10.9889 4.5 10 4.5Z" fill="#FFF"/></svg>]], 48, 48)
        local function handle_db()
            database.write("[localtions]Configs", ConfigsList)
            database.write("[localtions]Configs Raw", ConfigsRaw)
        end
    
        configs_list_box = ui.new_listbox("AA", "Anti-aimbot angles", "Configs List", ConfigsList)
        confgis_create_input = ui.new_textbox("AA", "Anti-aimbot angles", "\n Config Name")
        create_btn = ui.new_button("AA", "Anti-aimbot angles", "Create", function()
            local text = ui.get(confgis_create_input)
            if #text < 2  or table.has(ConfigsList, text)  then
                return
            end
    
    
            table.insert(ConfigsList, text)
            ConfigsRaw[text] = nil
            ui.update(configs_list_box, ConfigsList)
            handle_db()
            NotifyLogIndex = NotifyLogIndex + 1
        table.insert(NotifyCached, {
            Switch = false,
            CurrentIndex = false,
            Timer = GetTimeScale(),
            Index = NotifyLogIndex,
            AnimationColor = LightPinkedColor,
            ConfigsName = ("Config: %s"):format(text),
            UserName = ("User: %s"):format("Casset"),
            Text = "Create",
            Title = ("Casset%s"):format(RgbaToHexText(LightPinkedColor, "_Cassetelopment")),
            Svg = {
                Size =  vector(48, 48),
                Texture = SettingsSvg
            }
        })
        end)
    
        delete_btn = ui.new_button("AA", "Anti-aimbot angles", "Delete", function()
            local index = ui.get(configs_list_box) or 0
            if index > #ConfigsList then
                return
            end
    
            local cfgIndex = math.max(1, index + 1)
            local name = ConfigsList[ cfgIndex]
            if not name then
                return
            end
    
            if table.haskey(ConfigsRaw, name) then
                ConfigsRaw[name] = nil
            end
    
            ConfigsList[ cfgIndex] = nil
            ui.update(configs_list_box, ConfigsList)
            handle_db()
    
            NotifyLogIndex = NotifyLogIndex + 1
        table.insert(NotifyCached, {
            Switch = false,
            CurrentIndex = false,
            Timer = GetTimeScale(),
            Index = NotifyLogIndex,
            AnimationColor = LightPinkedColor,
            ConfigsName = ("Config: %s"):format(name ),
            UserName = ("User: %s"):format("Casset"),
            Text = "Delete",
            Title = ("Casset%s"):format(RgbaToHexText(LightPinkedColor, "_Development")),
            Svg = {
                Size =  vector(48, 48),
                Texture = SettingsSvg
            }
        })
        end)
    
        load_btn = ui.new_button("AA", "Anti-aimbot angles", "Load", function()
            local index = ui.get(configs_list_box) or 0
            if index > #ConfigsList then
                return
            end
    
            local cfgIndex = math.max(1, index + 1)
            local data = ConfigsRaw[ConfigsList[ cfgIndex]];
            if not data then
                return
            end
    
            local cfgs = json.parse(data)
            for key, data in pairs(cfgs) do
                if type(data) == "table" and data[1] == "Color" then
                    ui.set(configs_elements[key], unpack(data[2]))
                else
                    ui.set(configs_elements[key], data)
                end
            end
            handle_db()
            NotifyLogIndex = NotifyLogIndex + 1
        table.insert(NotifyCached, {
            Switch = false,
            CurrentIndex = false,
            Timer = GetTimeScale(),
            Index = NotifyLogIndex,
            AnimationColor = LightPinkedColor,
            ConfigsName = ("Config: %s"):format(ConfigsList[ cfgIndex]),
            UserName = ("User: %s"):format("Casset"),
            Text = "Load Successfully, Data Load From Database",
            Title = ("Casset%s"):format(RgbaToHexText(LightPinkedColor, "_Development")),
            Svg = {
                Size =  vector(48, 48),
                Texture = SettingsSvg
            }
        })
        end)
    
        save_btn = ui.new_button("AA", "Anti-aimbot angles", "Save", function()
            local index = ui.get(configs_list_box) or 0
            if index > #ConfigsList then
                return
            end
    
            local cfgIndex = math.max(1, index + 1)
            local data = ConfigsRaw[ConfigsList[cfgIndex]];
            local newdata = GetPackages()
            ConfigsRaw[ConfigsList[ math.max(1, index + 1)]] = json.stringify(newdata)
            handle_db()
            NotifyLogIndex = NotifyLogIndex + 1
        table.insert(NotifyCached, {
            Switch = false,
            CurrentIndex = false,
            Timer = GetTimeScale(),
            Index = NotifyLogIndex,
            AnimationColor = LightPinkedColor,
            ConfigsName = ("Config: %s"):format(ConfigsList[ cfgIndex]),
            UserName = ("User: %s"):format("Casset"),
            Text = "Save Successfully, Data Save To Database",
            Title = ("Casset%s"):format(RgbaToHexText(LightPinkedColor, "_Development")),
            Svg = {
                Size =  vector(48, 48),
                Texture = SettingsSvg
            }
        })
    
        end)
    
    
    
        import_btn = ui.new_button("AA", "Anti-aimbot angles", "Import settings", function() import(clipboard.get()) end)
        export_btn = ui.new_button("AA", "Anti-aimbot angles", "Export settings", function() 
            local code = {{}}
    
            for i, integers in pairs(data.integers) do
                table.insert(code[1], ui.get(integers))
            end
    
            clipboard.set(base64.encode(json.stringify(code)))
            print('Casset.lua ~ successfully exported your config')
        end)

    
        client.set_event_callback('paint_ui', function()
            if entity.get_local_player() == nil then cheked_ticks = 0 end
    
            ui.set_visible(export_btn, cfg_tab)
            ui.set_visible(import_btn, cfg_tab)

    
            ui.set_visible(configs_list_box, cfg_tab)
            ui.set_visible(load_btn, cfg_tab)
            ui.set_visible(save_btn, cfg_tab)
    
            ui.set_visible(confgis_create_input, cfg_tab)
            ui.set_visible(create_btn, cfg_tab)
            ui.set_visible(delete_btn, cfg_tab)
    
        end)
    
        ui.set_callback(console_filter, function()
            cvar.con_filter_text:set_string("cool text")
            cvar.con_filter_enable:set_int(1)
        end)
        
    
    local killsay_pharases = {
        {'1'},
        {'Bot？'},
        {'为什么会这样呢？'},
        {'Joke？'},
        {'你的aa和薯片一样脆'},
        {'anti-aim issue'},
        {'brain issue'},
        {'Casset.lua over all pidoras'},
        {'nice iq', 'bad aa'},

    }
        
    local death_say = {
        {'1', '你问我为什么扣1因为这是我帮你扣的你不配给我扣'},
        {'是不是lucky dog'},
        {'我在游戏里被你杀死，你妈在现实中被我杀死'},
        {'好累，睡一会'},
        {'看你可怜，这个头送你了'},
    }
    
        
    client.set_event_callback('player_death', function(e)
        delayed_msg = function(delay, msg)
            return client.delay_call(delay, function() client.exec('say ' .. msg) end)
        end
    
        local delay = 2.3
        local me = entity_get_local_player()
        local victim = client.userid_to_entindex(e.userid)
        local attacker = client.userid_to_entindex(e.attacker)
    
        local killsay_delay = 0
        local deathsay_delay = 0
    
        if entity_get_local_player() == nil then return end
              
        if not ui.get(trashtalk) then return end
    
        if (victim ~= attacker and attacker == me) then
            local phase_block = killsay_pharases[math.random(1, #killsay_pharases)]
    
                for i=1, #phase_block do
                    local phase = phase_block[i]
                    local interphrase_delay = #phase_block[i]/24*delay
                    killsay_delay = killsay_delay + interphrase_delay
    
                    delayed_msg(killsay_delay, phase)
                end
            end
                
        if (victim == me and attacker ~= me) then
            local phase_block = death_say[math.random(1, #death_say)]
    
            for i=1, #phase_block do
                local phase = phase_block[i]
                local interphrase_delay = #phase_block[i]/20*delay
                deathsay_delay = deathsay_delay + interphrase_delay
    
                delayed_msg(deathsay_delay, phase)
            end
        end
    end)

    local normalize_yaw = function(x)
        if x == nil then
            return 0
        end
        x = (x % 360 + 360) % 360
        return x > 180 and x - 360 or x
    end

    client.set_event_callback("net_update_end", function()
        if ui.get(resolver) then
        local local_player = entity.get_local_player()
        if not entity.is_alive(local_player) then
            return
        end
        client.update_player_list()

        for i = 1, #players do
            local v = players[i]
            if entity.is_enemy(v) then
                local st_cur, st_pre = res_data.get_simtime(v)
                st_cur, st_pre = toticks(st_cur), toticks(st_pre)

                if not res_data.records[v] then
                    res_data.records[v] = {}
                end

                local slot = res_data.records[v]

                slot[st_cur] = {
                    pose = entity.get_prop(v, "m_flPoseParameter", 11) * 60 - 1,
                    eye = select(2, entity.get_prop(v, "m_angEyeAngles"))
                }

                local value
                local allow = (slot[st_pre] and slot[st_cur]) ~= nil

                if allow then
                    local animstate = res_data.get_animstate(v)
                    local max_desync = res_data.get_max_desync(animstate)
                    if (slot[st_pre] and slot[st_cur]) and max_desync < 0.85 and (st_cur - st_pre < 2) then
                        local side = animates.text_clamp(normalize_yaw(animstate.goal_feet_yaw - slot[st_cur].eye),
                        -1, 1)
                        value = slot[st_pre] and (slot[st_pre].pose * side * max_desync) or nil
                    end

                    if value then
                        plist.set(v, "Force body yaw value", value/1)
                    end
                end

                plist.set(v, "Force body yaw", value ~= nil)
                plist.set(v, "Correction active", true)
            else
                plist.set(i, "Force body yaw", false)
                res_data.records = {}
            end
        end
    end
end)
        
    
    local clantag = {
        steam = steamworks.ISteamFriends,
        prev_ct = "",
        orig_ct = "",
        enb = false,
    }
    
    local function get_original_clantag()
        local clan_id = cvar.cl_clanid.get_int()
        if clan_id == 0 then return "\0" end
    
        local clan_count = clantag.steam.GetClanCount()
        for i = 0, clan_count do 
            local group_id = clantag.steam.GetClanByIndex(i)
            if group_id == clan_id then
                return clantag.steam.GetClanTag(group_id)
            end
        end
    end
    
    local clantag_anim = function(text, indices)
    
        time_to_ticks = function(t)
            return math.floor(0.5 + (t / globals.tickinterval()))
        end
    
        local text_anim = "               " .. text ..                       "" 
        local tickinterval = globals.tickinterval()
        local tickcount = globals.tickcount() + time_to_ticks(client.latency())
        local i = tickcount / time_to_ticks(0.3)
        i = math.floor(i % #indices)
        i = indices[i+1]+1
        return string.sub(text_anim, i, i+15)
    end
    
    local function clantag_set()
        local lua_name = "Casset"
        if ui.get(clantagchanger) then
            if ui.get(ui.reference("Misc", "Miscellaneous", "Clan tag spammer")) then ui.set(ui.reference("Misc", "Miscellaneous", "Clan tag spammer"), false) end
    
            local clan_tag = clantag_anim(lua_name, {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 11, 11, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25})
    
            if entity.get_prop(entity.get_game_rules(), "m_gamePhase") == 5 then
                clan_tag = clantag_anim('Casset.Lua', {13})
                client.set_clan_tag(clan_tag)
            elseif entity.get_prop(entity.get_game_rules(), "m_timeUntilNextPhaseStarts") ~= 0 then
                clan_tag = clantag_anim('Casset.Lua', {13})
                client.set_clan_tag(clan_tag)
            elseif clan_tag ~= clantag.prev_ct  then
                client.set_clan_tag(clan_tag)
            end
    
            clantag.prev_ct = clan_tag
            clantag.enb = true
        elseif clantag.enb == true then
            client.set_clan_tag(get_original_clantag())
            clantag.enb = false
        end
    end
    
    clantag.paint = function()
        if entity.get_local_player() ~= nil then
            if globals.tickcount() % 2 == 0 then
                clantag_set()
            end
        end
    end
    
    clantag.run_command = function(e)
        if entity.get_local_player() ~= nil then 
            if e.chokedcommands == 0 then
                clantag_set()
            end
        end
    end
    
    clantag.player_connect_full = function(e)
        if client.userid_to_entindex(e.userid) == entity.get_local_player() then 
            clantag.orig_ct = get_original_clantag()
        end
    end
    
    clantag.shutdown = function()
        client.set_clan_tag(get_original_clantag())
    end
    
    client.set_event_callback("paint", clantag.paint)
    client.set_event_callback("run_command", clantag.run_command)
    client.set_event_callback("player_connect_full", clantag.player_connect_full)
    client.set_event_callback("shutdown", clantag.shutdown)
    
    
    client.set_event_callback('net_update_end', function()
        if entity.get_local_player() ~= nil then
            is_defensive_active = is_defensive(entity.get_local_player())
        end
    end)
    
    
    client.set_event_callback('setup_command', function(cmd)
        if ui.get(fastladder) then
            local pitch, yaw = client.camera_angles()
            if entity.get_prop(entity.get_local_player(), "m_MoveType") == 9 then
                cmd.yaw = math.floor(cmd.yaw+0.5)
                cmd.roll = 0
                
                if cmd.forwardmove > 0 then
                    if pitch < 45 then
    
                        cmd.pitch = 89
                        cmd.in_moveright = 1
                        cmd.in_moveleft = 0
                        cmd.in_forward = 0
                        cmd.in_back = 1
    
                        if cmd.sidemove == 0 then
                            cmd.yaw = cmd.yaw + 90
                        end
    
                        if cmd.sidemove < 0 then
                            cmd.yaw = cmd.yaw + 150
                        end
    
                        if cmd.sidemove > 0 then
                            cmd.yaw = cmd.yaw + 30
                        end
                    end 
                end
    
                if cmd.forwardmove < 0 then
                    cmd.pitch = 89
                    cmd.in_moveleft = 1
                    cmd.in_moveright = 0
                    cmd.in_forward = 1
                    cmd.in_back = 0
                    if cmd.sidemove == 0 then
                        cmd.yaw = cmd.yaw + 90
                    end
                    if cmd.sidemove > 0 then
                        cmd.yaw = cmd.yaw + 150
                    end
                    if cmd.sidemove < 0 then
                        cmd.yaw = cmd.yaw + 30
                    end
                end
    
            end
        end
    end)
    local skeet_selected_tab = check_skeet_tab()
    if skeet_selected_tab then
----esp
        local name_esp, name_color = ui_reference("VISUALS", "Player ESP", "Name")
        local box_esp, box_color = ui_reference("VISUALS", "Player ESP", "Bounding box")
        local health_esp = ui_reference("VISUALS", "Player ESP", "Health bar")
        local flags_esp = ui_reference("VISUALS", "Player ESP", "Flags")
        local skeleton_esp, skeleton_color = ui_reference("VISUALS", "Player ESP", "Skeleton")
        local glow, glow_color = ui_reference("VISUALS", "Player ESP", "Glow")
        local weapon_esp_text = ui_reference("VISUALS", "Player ESP", "Weapon text")
        local weapon_esp_icon, weapon_esp_icon_color = ui_reference("VISUALS", "Player ESP", "Weapon icon")
        local ammo_esp, ammo_color = ui_reference("VISUALS", "Player ESP", "Ammo")
        local distance_esp = ui_reference("VISUALS", "Player ESP", "Distance")
        local money_esp = ui_reference("VISUALS", "Player ESP", "Money")
        local chams, chams_color  = ui_reference("VISUALS", "Colored models", "Player")
        local chamsb, chams_colorb, chams_combobox, chams_glow_color  = ui_reference("VISUALS", "Colored models", "Player behind wall")
        local menu_hotkey_reference = ui_reference("MISC", "Settings", "Menu key")
        local dpi_scale = ui_reference("MISC", "Settings", "DPI scale")

        --main variables
        local s = tonumber(ui_get(dpi_scale):sub(1, -2))/100
        local b_w = 7-- border width
        local screen_w, screen_h = client_screen_size()
        local key_pressed_prev = false
        local menu_open = true
        local last_change = globals_realtime()-1

        local url = {
            "https://img2.imgtp.com/2024/02/09/5mztbgvv.png", -- main model
            "https://img2.imgtp.com/2024/02/09/XZDnenqZ.png", -- glow
            "https://img2.imgtp.com/2024/02/09/DGy8bFlq.png", -- default
            "https://img2.imgtp.com/2024/02/09/6z3kKLGv.png", -- solid
            "https://img2.imgtp.com/2024/02/09/PHvhL0Ys.png", -- inner glow
            "https://img2.imgtp.com/2024/02/09/ThGwJzx0.png", -- bubble
            "https://img2.imgtp.com/2024/02/09/zRAtywIc.png", -- shaded
            "https://img2.imgtp.com/2024/02/09/HfkCWAAD.png", -- metallic
        }

        local model = {}
        for i=1, 8 do
            http.get(url[i], function(s, r)
                if s and r.status == 200 then
                    model[i] = images.load(r.body)
                end  
            end)
        end
        local function menu(s_x, s_y, s_w, s_h, s_alpha, do_gradient)
            --renderer_rectangle(s_x - 6, s_y - 6, s_w + 12, s_h + 12, 25, 25, 25, s_alpha)
            renderer_rectangle(s_x - 5, s_y - 5, s_w + 10, s_h + 10, 40, 40, 40, s_alpha)
            renderer_rectangle(s_x - 4, s_y - 4, s_w + 8, s_h + 8, 40, 40, 40, s_alpha)
            renderer_rectangle(s_x - 1, s_y - 1, s_w + 2, s_h + 2, 60, 60, 60, s_alpha)
            renderer_rectangle(s_x, s_y, s_w, s_h, 60, 60, 60, s_alpha * 20)
            
            if do_gradient then
                renderer_gradient(s_x + 1, s_y + 1, s_w / 2 - 1, s, 55, 177, 218, s_alpha, 201, 208, 205, s_alpha, true)
                renderer_gradient(s_x + s_w / 2 - 1, s_y + 1, s_w / 2, s, 201, 84, 205, s_alpha, 204, 207, 53, s_alpha, true)
                
            end
        end

        client_set_event_callback("paint_ui", function() -- inventory handling
	paint_notifys()
            local name_r, name_g, name_b, name_a = ui_get(name_color)
            local box_r, box_g, box_b, box_a = ui_get(box_color)
            local skeleton_r, skeleton_g, skeleton_b, skeleton_a = ui_get(skeleton_color)
            local ammo_r, ammo_g, ammo_b, ammo_a = ui_get(ammo_color)
            local icon_r, icon_g, icon_b, icon_a = ui_get(weapon_esp_icon_color)
            local glow_r, glow_g, glow_b, glow_a = ui_get(glow_color)
            local chams_r, chams_g, chams_b, chams_a = ui_get(chams_color)
            local chams_glow_r, chams_glow_g, chams_glow_b, chams_glow_a = ui_get(chams_glow_color)
            local flag_offset = 41
            local other_offset = 0
            local weapon_icon = images.get_weapon_icon("weapon_scar20")
            local menu_pos_x, menu_pos_y = ui_menu_position()          
            local menu_pos_w, menu_pos_h = ui_menu_size()
            if ui.get(winpos) == "-" then
                return
            elseif ui.get(winpos) == "Left" then
                x_i, y_i = menu_pos_x - 190, menu_pos_y + 6
            elseif ui.get(winpos) == "Right" then
                x_i, y_i = menu_pos_x + menu_pos_w + 5, menu_pos_y + 6
            end
            local key_pressed = ui_get(menu_hotkey_reference)
            if key_pressed and not key_pressed_prev then
                menu_open = not menu_open
                last_change = globals_realtime()
            end
            key_pressed_prev = key_pressed
            local opacity_multiplier = 0
            if menu_open then
                opacity_multiplier = 1
            end
            if globals_realtime() - last_change < 0.15 then
                opacity_multiplier = (globals_realtime() - last_change) / 0.15
                if not menu_open then
                    opacity_multiplier = 1 - opacity_multiplier
                end
            end
            for i=1, 8 do
                if model[i] == nil then
                    return
                end
            end
            -- [ MENU ]
            menu(x_i, y_i, 185, 275, 255*opacity_multiplier, true)
            -- [ NAME ]
            if ui_get(name_esp) then
                renderer_text(x_i + 90, y_i + 35, name_r, name_g, name_b, name_a*opacity_multiplier, "c", 0, "Dev")
            end
            -- [ HEALTH ]
            if ui_get(health_esp) then
                renderer_rectangle(x_i + 34, y_i + 42, 2, 140, 0, 0, 0, 120*opacity_multiplier)
                renderer_rectangle(x_i + 34, y_i + 85, 2, 135, 185, 183, 241, 255*opacity_multiplier)
                renderer_text(x_i + 29, y_i + 79, 255, 255, 255, 255*opacity_multiplier, "-", 0, "76")
            end
            -- [ BOX ]
            if ui_get(box_esp) then
                renderer_line(x_i + 40, y_i + 42, x_i + 140, y_i + 42, box_r, box_g, box_b, box_a*opacity_multiplier)
                renderer_line(x_i + 40, y_i + 42, x_i + 40, y_i + 220, box_r, box_g, box_b, box_a*opacity_multiplier)
                renderer_line(x_i + 40, y_i + 220, x_i + 140, y_i + 220, box_r, box_g, box_b, box_a*opacity_multiplier)
                renderer_line(x_i + 140, y_i + 220, x_i + 140, y_i + 42, box_r, box_g, box_b, box_a*opacity_multiplier)
            end
            -- [ MONEY ]
            if ui_get(money_esp) then
                renderer_text(x_i + 143, y_i + 41, 115, 180, 25, 255*opacity_multiplier, "-", 0, "$1123")
                flag_offset = flag_offset + 9
            end
            -- [ FLAGS ]
            if ui_get(flags_esp) then
                renderer_text(x_i + 143, y_i + flag_offset, 255, 255, 255, 255*opacity_multiplier, "-", 0, "HK")
                renderer_text(x_i + 143, y_i + flag_offset + 9, 53, 166, 208, 255*opacity_multiplier, "-", 0, "ZOOM")
                renderer_text(x_i + 143, y_i + flag_offset + 18, 255, 255, 255, 255*opacity_multiplier, "-", 0, "FAKE")
                renderer_text(x_i + 143, y_i + flag_offset + 27, 255, 0, 0, 255*opacity_multiplier, "-", 0, "PIN")
            end
            -- [ AMMO ]
            if ui_get(ammo_esp) then
                renderer_rectangle(x_i + 40, y_i + 225 + other_offset, 100, 2, 0, 0, 0, 120*opacity_multiplier)
                renderer_rectangle(x_i + 40, y_i + 225 + other_offset, 65, 2, ammo_r, ammo_g, ammo_b, ammo_a*opacity_multiplier)
                renderer_text(x_i + 105, y_i + 227 + other_offset, 255, 255, 255, 255*opacity_multiplier, "c-", 0, "13")
                other_offset = other_offset + 10
            end
            -- [ DISTANCE ]
            if ui_get(distance_esp) then
                renderer_text(x_i + 85, y_i + 226 + other_offset, 255, 255, 255, 255*opacity_multiplier, "c-", 0, "70 FT")
                other_offset = other_offset + 10
            end
            -- [ WEAPON TEXT ]
            if ui_get(weapon_esp_text) then
                renderer_text(x_i + 85, y_i + 227 + other_offset, 255, 255, 255, 255*opacity_multiplier, "c-", 0, "SCAR-20")
                other_offset = other_offset + 10
            end
            -- [ WEAPON ICON ]
            if ui_get(weapon_esp_icon) then
                weapon_icon:draw(x_i + 70, y_i + 225 + other_offset, nil, 12, icon_r, icon_g, icon_b, icon_a*opacity_multiplier, 10, "")
                other_offset = other_offset + 10
            end
            -- [ GLOW ]
            if ui_get(glow) then
                model[2]:draw(x_i+35, y_i+35, nil, 180, glow_r, glow_g, glow_b, glow_a*opacity_multiplier)
            end	
            -- [ MODEL & CHAMS ]
            if ui_get(chams) == false then
                model[1]:draw(x_i+35, y_i+35, nil, 180, 255, 255, 255, 255*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Default" then
                model[3]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Solid" then
                model[4]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Shaded" then
                model[3]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
                model[7]:draw(x_i+35, y_i+35, nil, 180, chams_glow_r, chams_glow_g, chams_glow_b, chams_glow_a*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Glow" then
                model[3]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
                model[5]:draw(x_i+35, y_i+35, nil, 180, chams_glow_r, chams_glow_g, chams_glow_b, chams_glow_a*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Bubble" then
                model[6]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
                model[7]:draw(x_i+35, y_i+35, nil, 180, chams_glow_r, chams_glow_g, chams_glow_b, chams_glow_a*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Metallic" then
                model[3]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
                model[8]:draw(x_i+35, y_i+35, nil, 180, chams_glow_r, chams_glow_g, chams_glow_b, chams_glow_a/2*opacity_multiplier)
            elseif ui_get(chams_combobox) == "Original" then
                model[1]:draw(x_i+35, y_i+35, nil, 180, chams_r, chams_g, chams_b, chams_a*opacity_multiplier)
            end
            -- [ SKELETON ]
            if ui_get(skeleton_esp) then
                --body
                renderer_line(x_i + 90, y_i + 62, x_i + 86, y_i + 125, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                --left leg
                renderer_line(x_i + 86, y_i + 125, x_i + 76, y_i + 140, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 76, y_i + 140, x_i + 78, y_i + 162, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 78, y_i + 162, x_i + 88, y_i + 195, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                --right leg
                renderer_line(x_i + 86, y_i + 125, x_i + 98, y_i + 140, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 98, y_i + 140, x_i + 100, y_i + 168, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 100, y_i + 168, x_i + 108, y_i + 195, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                --left arm
                renderer_line(x_i + 88, y_i + 85, x_i + 71, y_i + 88, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 71, y_i + 88, x_i + 62, y_i + 103, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 62, y_i + 103, x_i + 60, y_i + 82, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                --right arm
                renderer_line(x_i + 88, y_i + 85, x_i + 107, y_i + 88, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 107, y_i + 88, x_i + 115, y_i + 101, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
                renderer_line(x_i + 115, y_i + 101, x_i + 110, y_i + 125, skeleton_r, skeleton_g, skeleton_b, skeleton_a*opacity_multiplier)
            end
        end)
    end
    client.set_event_callback("setup_command", function(cmd)
        is_on_ground = cmd.in_jump == 0
    
        if table.contains(m_elements, "Leg Breaker-landing") then
            ui.set(slidewalk_directory, cmd.command_number % 3 == 0 and "Off" or "Always slide")
        end
    end)
    
    client.set_event_callback("pre_render", function()
        local self = entity.get_local_player()
        if not self or not entity.is_alive(self) then
            return
        end
    
        local self_index = c_entity.new(self)
        local self_anim_state = self_index:get_anim_state()
    
        if not self_anim_state then
            return
        end
    
        if table.contains(m_elements, "Slide slow-walking") then
            if table.contains(slide_elements, "While walking") then
                entity.set_prop(self, "m_flPoseParameter", 0, E_POSE_PARAMETERS.MOVE_BLEND_WALK)
            end
    
            if table.contains(slide_elements, "While running") then
                entity.set_prop(self, "m_flPoseParameter", 0, E_POSE_PARAMETERS.MOVE_BLEND_RUN)
            end
    
            if table.contains(slide_elements, "While crouching") then
                entity.set_prop(self, "m_flPoseParameter", 0, E_POSE_PARAMETERS.MOVE_BLEND_CROUCH)
            end
        end
    
        if table.contains(m_elements, "Leg Breaker-in air") then
            entity.set_prop(self, "m_flPoseParameter", ui.get(break_air_value) / 10, E_POSE_PARAMETERS.JUMP_FALL)
        end
    
        if table.contains(m_elements, "Leg Breaker-landing") then
            local ref = {
                leg_movement = ui.reference('AA', 'Other', 'Leg movement'),
            }
            local local_player = entity.get_local_player()
            if not entity.is_alive(local_player) then return end
    
            entity.set_prop(local_player, "m_flPoseParameter", client.random_float(0.8/10, 1), 0)
            ui.set(ref.leg_movement, client.random_int(1, 2) == 1 and "Off" or "Always slide")
        end
        
        if table.contains(m_elements, "Body lean") then
            local self_anim_overlay = self_index:get_anim_overlay(12)
            if not self_anim_overlay then
                return
            end
    
            local x_velocity = entity.get_prop(self, "m_vecVelocity[0]")
            if math.abs(x_velocity) >= 3 then
                self_anim_overlay.weight = ui.get(body_lean_value) / 100
            end
        end
    
        if table.contains(m_elements, "Pitch 0 onland") then
            if not self_anim_state.hit_in_ground_animation or not is_on_ground then
                return
            end
    
            entity.set_prop(self, "m_flPoseParameter", 0.5, E_POSE_PARAMETERS.BODY_PITCH)
        end 
    end)

    local ref = {
        leg_movement = ui.reference('AA', 'Other', 'Leg movement'),
        auto_peek = {ui.reference("Rage", "Other", "Quick peek assist")},
    }

    client.set_event_callback(
        "pre_render",
        function()
            if not entity.is_alive(entity.get_local_player()) then
                return
            end

            local localplayer = entity.get_local_player()
            if localplayer == nil then
                return
            end

            local velocity = vector(entity.get_prop(localplayer, "m_vecVelocity")):length()

            local AutoPeek = ui.get(ref.auto_peek[1]) and ui.get(ref.auto_peek[2])
            if contains(m_elements, "Moonwalk") then
                if not AutoPeek then
                    local mult = 0.50;
                    local me = ent.get_local_player()
                    local cycle = globals_realtime() * mult
                    ui.set(ref.leg_movement, 'Never slide')
                    local my_animlayer = me:get_anim_overlay(6)
                    local jump_layer = me:get_anim_overlay(4) -- MOVEMENT_JUMP_OR_FALL
                    if not is_onground then
                        my_animlayer.weight = 1
                        jump_layer.cycle = 40 / 100
                        jump_layer.sequence = 148
                    	entity.set_prop(localplayer, "m_flPoseParameter", 0, 7)
	                elseif velocity > 10 then
                        	my_animlayer.weight = 1
                        	my_animlayer.cycle = cycle % 1
                            entity.set_prop(localplayer, "m_flPoseParameter", 1, 7)
                    elseif velocity < 10 then
                        	my_animlayer.weight = 1
                        	my_animlayer.cycle = cycle % 1
                            entity.set_prop(localplayer, "m_flPoseParameter", 1, 7)
                    end
                else
                    if not is_onground then
                    local me = ent.get_local_player()
                    entity.set_prop(localplayer, "m_flPoseParameter", 1, 7)
                    ui.set(ref.leg_movement, 'Off')
		            me:get_anim_overlay(6).weight = 1
                    local my_animlayer = me:get_anim_overlay(4) -- MOVEMENT_JUMP_OR_FALL
	                my_animlayer.cycle = 40 / 100
	                my_animlayer.sequence = 148
                    end
                end
            end
        
        end
    )
    local ab = {}
    
    ab.pre_render = function()
        
    end
    
    ab.setup_command = function(e)
        if not contains(m_elements, "Leg Breaker-landing") then return end
    
        local local_player = entity.get_local_player()
        if not entity.is_alive(local_player) then return end
    
        ui.set(ref.leg_movement, 'Always slide')
    end
    
    local ui_callback = function(c)
        local enabled, addr = ui.get(c), ''
    
        if not enabled then
            addr = 'un'
        end
        
        local _func = client[addr .. 'set_event_callback']
    
        _func('pre_render', ab.pre_render)
        _func('setup_command', ab.setup_command)
    end
    
    ui.set_callback(master_switch, ui_callback)
    ui_callback(master_switch)
    
    local is_on_ground = false
    
    
    client.set_event_callback("setup_command", function(cmd)
        is_on_ground = cmd.in_jump == 0
    
        if contains(m_elements, "Leg Breaker-landing") then
            ui.set(ref.leg_movement, cmd.command_number % 3 == 0 and "Off" or "Always slide")
        end
    end)
    
    client.set_event_callback("pre_render", function()
        local self = entity.get_local_player()
        if not self or not entity.is_alive(self) then
            return
        end
    
        local self_index = ent.new(self)
        local self_anim_state = self_index:get_anim_state()
    
        if not self_anim_state then
            return
        end
    
        if contains(m_elements, "Leg Breaker-landing") then
            entity.set_prop(self, "m_flPoseParameter", E_POSE_PARAMETERS.STAND, globals.tickcount() % 4 > 1 and 5 / 10 or 1)
        
            local self_anim_overlay = self_index:get_anim_overlay(12)
            if not self_anim_overlay then
                return
            end
    
            local x_velocity = entity.get_prop(self, "m_vecVelocity[0]")
            if math.abs(x_velocity) >= 3 then
                self_anim_overlay.weight = 100 / 100
            end
        end
        
    end)
    
    
    if ui.get(lag_debug) then
        local g_esp_data = { }
        local g_sim_ticks, g_net_data = { }, { }

        local globals_tickinterval = globals.tickinterval
        local entity_is_enemy = entity.is_enemy
        local entity_get_prop = entity.get_prop
        local entity_is_dormant = entity.is_dormant
        local entity_is_alive = entity.is_alive
        local entity_get_origin = entity.get_origin
        local entity_get_local_player = entity.get_local_player
        local entity_get_player_resource = entity.get_player_resource
        local entity_get_bounding_box = entity.get_bounding_box
        local entity_get_player_name = entity.get_player_name
        local renderer_text = renderer.text
        local w2s = renderer.world_to_screen
        local line = renderer.line
        local table_insert = table.insert
        local client_trace_line = client.trace_line
        local math_floor = math.floor
        local globals_frametime = globals.frametime

        local sv_gravity = cvar.sv_gravity
        local sv_jump_impulse = cvar.sv_jump_impulse

        local time_to_ticks = function(t) return math_floor(0.5 + (t / globals_tickinterval())) end
        local vec_substract = function(a, b) return { a[1] - b[1], a[2] - b[2], a[3] - b[3] } end
        local vec_add = function(a, b) return { a[1] + b[1], a[2] + b[2], a[3] + b[3] } end
        local vec_lenght = function(x, y) return (x * x + y * y) end

        local get_entities = function(enemy_only, alive_only)
            local enemy_only = enemy_only ~= nil and enemy_only or false
            local alive_only = alive_only ~= nil and alive_only or true
            
            local result = {}

            local me = entity_get_local_player()
            local player_resource = entity_get_player_resource()
            
            for player = 1, globals.maxplayers() do
                local is_enemy, is_alive = true, true
                
                if enemy_only and not entity_is_enemy(player) then is_enemy = false end
                if is_enemy then
                    if alive_only and entity_get_prop(player_resource, 'm_bAlive', player) ~= 1 then is_alive = false end
                    if is_alive then table_insert(result, player) end
                end
            end

            return result
        end

        local extrapolate = function(ent, origin, flags, ticks)
            local tickinterval = globals_tickinterval()

            local sv_gravity = sv_gravity:get_float() * tickinterval
            local sv_jump_impulse = sv_jump_impulse:get_float() * tickinterval

            local p_origin, prev_origin = origin, origin

            local velocity = { entity_get_prop(ent, 'm_vecVelocity') }
            local gravity = velocity[3] > 0 and -sv_gravity or sv_jump_impulse

            for i=1, ticks do
                prev_origin = p_origin
                p_origin = {
                    p_origin[1] + (velocity[1] * tickinterval),
                    p_origin[2] + (velocity[2] * tickinterval),
                    p_origin[3] + (velocity[3]+gravity) * tickinterval,
                }

                local fraction = client_trace_line(-1, 
                    prev_origin[1], prev_origin[2], prev_origin[3], 
                    p_origin[1], p_origin[2], p_origin[3]
                )

                if fraction <= 0.99 then
                    return prev_origin
                end
            end

            return p_origin
        end

        local function g_net_update()
            local me = entity_get_local_player()
            local players = get_entities(true, true)

            for i=1, #players do
                local idx = players[i]
                local prev_tick = g_sim_ticks[idx]
                
                if entity_is_dormant(idx) or not entity_is_alive(idx) then
                    g_sim_ticks[idx] = nil
                    g_net_data[idx] = nil
                    g_esp_data[idx] = nil
                else
                    local player_origin = { entity_get_origin(idx) }
                    local simulation_time = time_to_ticks(entity_get_prop(idx, 'm_flSimulationTime'))
            
                    if prev_tick ~= nil then
                        local delta = simulation_time - prev_tick.tick

                        if delta < 0 or delta > 0 and delta <= 64 then
                            local m_fFlags = entity_get_prop(idx, 'm_fFlags')

                            local diff_origin = vec_substract(player_origin, prev_tick.origin)
                            local teleport_distance = vec_lenght(diff_origin[1], diff_origin[2])

                            local extrapolated = extrapolate(idx, player_origin, m_fFlags, delta-1)
            
                            if delta < 0 then
                                g_esp_data[idx] = 1
                            end

                            g_net_data[idx] = {
                                tick = delta-1,

                                origin = player_origin,
                                predicted_origin = extrapolated,

                                tickbase = delta < 0,
                                lagcomp = teleport_distance > 4096,
                            }
                        end
                    end
            
                    if g_esp_data[idx] == nil then
                        g_esp_data[idx] = 0
                    end

                    g_sim_ticks[idx] = {
                        tick = simulation_time,
                        origin = player_origin,
                    }
                end
            end
        end

        local function g_paint_handler()
            local me = entity_get_local_player()
            local player_resource = entity_get_player_resource()

            if not me or not entity_is_alive(me) then
                return
            end

            local observer_mode = entity_get_prop(me, "m_iObserverMode")
            local active_players = {}

            if (observer_mode == 0 or observer_mode == 1 or observer_mode == 2 or observer_mode == 6) then
                active_players = get_entities(true, true)
            elseif (observer_mode == 4 or observer_mode == 5) then
                local all_players = get_entities(false, true)
                local observer_target = entity_get_prop(me, "m_hObserverTarget")
                local observer_target_team = entity_get_prop(observer_target, "m_iTeamNum")

                for test_player = 1, #all_players do
                    if (
                        observer_target_team ~= entity_get_prop(all_players[test_player], "m_iTeamNum") and
                        all_players[test_player ] ~= me
                    ) then
                        table_insert(active_players, all_players[test_player])
                    end
                end
            end

            if #active_players == 0 then
                return
            end

            for idx, net_data in pairs(g_net_data) do
                if entity_is_alive(idx) and entity_is_enemy(idx) and net_data ~= nil then
                    if net_data.lagcomp then
                        local predicted_pos = net_data.predicted_origin
                        local min = vec_add({ entity_get_prop(idx, 'm_vecMins') }, predicted_pos)
                        local max = vec_add({ entity_get_prop(idx, 'm_vecMaxs') }, predicted_pos)
                        local points = {
                            {min[1], min[2], min[3]}, {min[1], max[2], min[3]},
                            {max[1], max[2], min[3]}, {max[1], min[2], min[3]},
                            {min[1], min[2], max[3]}, {min[1], max[2], max[3]},
                            {max[1], max[2], max[3]}, {max[1], min[2], max[3]},
                        }
                        local edges = {
                            {0, 1}, {1, 2}, {2, 3}, {3, 0}, {5, 6}, {6, 7}, {1, 4}, {4, 8},
                            {0, 4}, {1, 5}, {2, 6}, {3, 7}, {5, 8}, {7, 8}, {3, 4}
                        }
                        for i = 1, #edges do
                            if i == 1 then
                                local origin = { entity_get_origin(idx) }
                                local origin_w2s = { w2s(origin[1], origin[2], origin[3]) }
                                local min_w2s = { w2s(min[1], min[2], min[3]) }
                                if origin_w2s[1] ~= nil and min_w2s[1] ~= nil then
                                    line(origin_w2s[1], origin_w2s[2], min_w2s[1], min_w2s[2], 185, 181, 241, 255)
                                end
                            end
                            if points[edges[i][1]] ~= nil and points[edges[i][2]] ~= nil then
                                local p1 = { w2s(points[edges[i][1]][1], points[edges[i][1]][2], points[edges[i][1]][3]) }
                                local p2 = { w2s(points[edges[i][2]][1], points[edges[i][2]][2], points[edges[i][2]][3]) }
                    
                                line(p1[1], p1[2], p2[1], p2[2], 185, 181, 241, 255)
                            end
                        end
                    end
                    local text = {
                        [0] = '', [1] = 'LAG COMP BREAKER',
                        [2] = 'SHIFTING TICKBASE'
                    }
                    local x1, y1, x2, y2, a = entity_get_bounding_box(idx)
                    local palpha = 0
                    if g_esp_data[idx] > 0 then
                        g_esp_data[idx] = g_esp_data[idx] - globals_frametime()*2
                        g_esp_data[idx] = g_esp_data[idx] < 0 and 0 or g_esp_data[idx]

                        palpha = g_esp_data[idx]
                    end
                    local tb = net_data.tickbase or g_esp_data[idx] > 0
                    local lc = net_data.lagcomp
                    if not tb or net_data.lagcomp then
                        palpha = a
                    end
                    if x1 ~= nil and a > 0 then
                        local name = entity_get_player_name(idx)
                        local y_add = name == '' and -8 or 0
                        renderer_text(x1 + (x2-x1)/2, y1 - 18 + y_add, 255, 255, 255, palpha*255, 'c-', 0, text[tb and 2 or (lc and 1 or 0)])
                    end
                end
            end
        end
        client.set_event_callback('paint', g_paint_handler)
        client.set_event_callback('net_update_end', g_net_update)
    end
    
    local queue = {}

    local function aim_fire(c)
        queue[globals.tickcount()] = {c.x,c.y,c.z, globals.curtime() + 10}
    end    
    
    local function paintc(c)
        paint_manual()
	render_hitlog()
        paint_crosshair_indicator()
        if ui.get(hitmarker) then
            for tick, data in pairs(queue) do
                if globals.curtime() <= data[4] then
                    local x1, y1 = renderer.world_to_screen(data[1], data[2], data[3])
                    if x1 ~= nil and y1 ~= nil then
                       --renderer.circle_outline(x1,y1,255,255,255,255,5,0,1.0,1)
                       renderer.line(x1 - 6,y1,x1 + 6,y1,255,255,255,255)
                       renderer.line(x1,y1 - 6,x1,y1 + 6 ,181,175,255,255)
                    end
                end
            end
        end
    end
    
    client.set_event_callback("aim_fire",aim_fire)
    client.set_event_callback("paint",paintc)
    
    client.set_event_callback("round_prestart", function()
        recorded_max_tickbase = 0
        defensive_wait_ticks = 0
        queue = {}
    end)
    
    
    local time_to_ticks = function(t) return math_floor(0.5 + (t / globals_tickinterval())) end
    local vec_substract = function(a, b) return { a[1] - b[1], a[2] - b[2], a[3] - b[3] } end
    local vec_lenght = function(x, y) return (x * x + y * y) end
    
    local g_impact = { }
    local g_aimbot_data = { }
    local g_sim_ticks, g_net_data = { }, { }
    
    local cl_data = {
        tick_shifted = false,
        tick_base = 0
    }
    
    local float_to_int = function(n) 
        return n >= 0 and math.floor(n+.5) or math.ceil(n-.5)
    end
    
    local get_entities = function(enemy_only, alive_only)
        local enemy_only = enemy_only ~= nil and enemy_only or false
        local alive_only = alive_only ~= nil and alive_only or true
        
        local result = {}
        local player_resource = entity_get_player_resource()
        
        for player = 1, globals.maxplayers() do
            local is_enemy, is_alive = true, true
            
            if enemy_only and not entity_is_enemy(player) then is_enemy = false end
            if is_enemy then
                if alive_only and entity_get_prop(player_resource, 'm_bAlive', player) ~= 1 then is_alive = false end
                if is_alive then table_insert(result, player) end
            end
        end
    
        return result
    end
    
    local generate_flags = function(e, on_fire_data)
        return {
            e.refined and 'R' or '',
            e.expired and 'X' or '',
            e.noaccept and 'N' or '',
            cl_data.tick_shifted and 'S' or '',
            on_fire_data.teleported and 'T' or '',
            on_fire_data.interpolated and 'I' or '',
            on_fire_data.extrapolated and 'E' or '',
            on_fire_data.boosted and 'B' or '',
            on_fire_data.high_priority and 'H' or ''
        }
    end
    
    local hitgroup_names = { 'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear' }
    local weapon_to_verb = { knife = 'Knifed', hegrenade = 'Naded', inferno = 'Burned' }
    
    
    local function g_net_update()
        local me = entity_get_local_player()
        local players = get_entities(true, true)
        local m_tick_base = entity_get_prop(me, 'm_nTickBase')
        
        cl_data.tick_shifted = false
        
        if m_tick_base ~= nil then
            if cl_data.tick_base ~= 0 and m_tick_base < cl_data.tick_base then
                cl_data.tick_shifted = true
            end
        
            cl_data.tick_base = m_tick_base
        end
    
        for i=1, #players do
            local idx = players[i]
            local prev_tick = g_sim_ticks[idx]
            
            if entity_is_dormant(idx) or not entity_is_alive(idx) then
                g_sim_ticks[idx] = nil
                g_net_data[idx] = nil
            else
                local player_origin = { entity_get_origin(idx) }
                local simulation_time = time_to_ticks(entity_get_prop(idx, 'm_flSimulationTime'))
        
                if prev_tick ~= nil then
                    local delta = simulation_time - prev_tick.tick
    
                    if delta < 0 or delta > 0 and delta <= 64 then
                        local m_fFlags = entity_get_prop(idx, 'm_fFlags')
    
                        local diff_origin = vec_substract(player_origin, prev_tick.origin)
                        local teleport_distance = vec_lenght(diff_origin[1], diff_origin[2])
    
                        g_net_data[idx] = {
                            tick = delta-1,
    
                            origin = player_origin,
                            tickbase = delta < 0,
                            lagcomp = teleport_distance > 4096,
                        }
                    end
                end
    
                g_sim_ticks[idx] = {
                    tick = simulation_time,
                    origin = player_origin,
                }
            end
        end
    end
    
    
    local function g_aim_fire(e)
        local data = e
    
    
        local plist_sp = plist.get(e.target, 'Override safe point')
        local plist_fa = plist.get(e.target, 'Correction active')
        local checkbox = ui.get(force_safe_point)
    
        if g_net_data[e.target] == nil then
            g_net_data[e.target] = { }
        end
    
        data.tick = e.tick
    
        data.eye = vector(client.eye_position)
        data.shot = vector(e.x, e.y, e.z)
    
        data.teleported = g_net_data[e.target].lagcomp or false
        data.choke = g_net_data[e.target].tick or '?'
        data.self_choke = globals.chokedcommands()
        data.correction = plist_fa and 1 or 0
        data.safe_point = ({
            ['Off'] = 'off',
            ['On'] = true,
            ['-'] = checkbox
        })[plist_sp]
    
        g_aimbot_data[e.id] = data
    end
    
    local function g_aim_hit(e)
        if not ui.get(master_switch) or g_aimbot_data[e.id] == nil then
            return
        end
    
        local on_fire_data = g_aimbot_data[e.id]
        local name = string.lower(entity.get_player_name(e.target))
        local hgroup = hitgroup_names[e.hitgroup + 1] or '?'
        local aimed_hgroup = hitgroup_names[on_fire_data.hitgroup + 1] or '?'
        
        local hitchance = math_floor(on_fire_data.hit_chance + 0.5) .. '%'
        local health = entity_get_prop(e.target, 'm_iHealth')
    
        local flags = generate_flags(e, on_fire_data)
    
        print(string.format(
            'Hit %s\'s %s for %i(%d) (%i remaining) aimed=%s(%s) sp=%s (%s) LC=%s TC=%s', 
            name, hgroup, e.damage, on_fire_data.damage, health, aimed_hgroup, hitchance, on_fire_data.safe_point,
            table.concat(flags), on_fire_data.self_choke, on_fire_data.choke
        ))
    
    end
    
    local function g_aim_miss(e)
        if not ui.get(master_switch) or g_aimbot_data[e.id] == nil then
            return
        end
    
        local on_fire_data = g_aimbot_data[e.id]
        local name = string.lower(entity.get_player_name(e.target))
    
        local hgroup = hitgroup_names[e.hitgroup + 1] or '?'
        local hitchance = math_floor(on_fire_data.hit_chance + 0.5) .. '%'
    
        local flags = generate_flags(e, on_fire_data)
        local reason = e.reason == '?' and 'unknown' or e.reason
    
        local inaccuracy = 0
        for i=#g_impact, 1, -1 do
            local impact = g_impact[i]
    
            if impact and impact.tick == globals.tickcount() then
                local aim, shot = 
                    (impact.origin-on_fire_data.shot):angles(),
                    (impact.origin-impact.shot):angles()
    
                inaccuracy = vector(aim-shot):length2d()
                break
            end
        end
    
        print(string.format(
            'Missed %s\'s %s(%i)(%s) due to %s:%.2f°, sp=%s (%s) LC=%s TC=%s', 
            name, hgroup, on_fire_data.damage, hitchance, reason, inaccuracy, on_fire_data.safe_point, 
            table.concat(flags), on_fire_data.self_choke, on_fire_data.choke
        ))
    end
    
    local function g_player_hurt(e)
        local attacker_id = client.userid_to_entindex(e.attacker)
        
        if not ui.get(master_switch) or attacker_id == nil or attacker_id ~= entity.get_local_player() then
            return
        end
    
        local group = hitgroup_names[e.hitgroup + 1] or "?"
        
        if group == "generic" and weapon_to_verb[e.weapon] ~= nil then
            local target_id = client.userid_to_entindex(e.userid)
            local target_name = entity.get_player_name(target_id)
    
            print(string.format("%s %s for %i damage (%i remaining)", weapon_to_verb[e.weapon], string.lower(target_name), e.dmg_health, e.health))
        end
    end
    
    local function g_bullet_impact(e)
        local tick = globals.tickcount()
        local me = entity.get_local_player()
        local user = client.userid_to_entindex(e.userid)
        
        if user ~= me then
            return
        end
    
        if #g_impact > 150 and g_impact[#g_impact].tick ~= tick then
            g_impact = { }
        end
    
        g_impact[#g_impact+1] = 
        {
            tick = tick,
            origin = vector(client.eye_position()), 
            shot = vector(e.x, e.y, e.z)
        }
    end
    
    client.set_event_callback('aim_fire', g_aim_fire)
    client.set_event_callback('aim_hit', g_aim_hit)
    client.set_event_callback('aim_miss', g_aim_miss)
    client.set_event_callback('net_update_end', g_net_update)
    
    client.set_event_callback('player_hurt', g_player_hurt)
    client.set_event_callback('bullet_impact', g_bullet_impact)
    
    client.set_event_callback('aim_hit', g_aim_hit)
    client.set_event_callback('aim_miss', g_aim_miss)
    client.set_event_callback('player_hurt', g_player_hurt)
    
    client.set_event_callback('shutdown', function()
        ui.set_visible(reference.pitch[1], true)
        ui.set_visible(reference.yaw_base, true)
        ui.set_visible(reference.yaw[1], true)
        ui.set_visible(reference.body_yaw[1], true)
        ui.set_visible(reference.edge_yaw, true)
        ui.set_visible(reference.freestanding[1], true)
        ui.set_visible(reference.freestanding[2], true)
        ui.set_visible(reference.roll, true)
    
        ui.set(reference.pitch[1], 'Off')
        ui.set(reference.pitch[2], 0)
        ui.set(reference.yaw_base, 'Local view')
        ui.set(reference.yaw[1], 'Off')
        ui.set(reference.yaw[2], 0)
        ui.set(reference.yaw_jitter[1], 'Off')
        ui.set(reference.yaw_jitter[2], 0)
        ui.set(reference.body_yaw[1], 'Off')
        ui.set(reference.body_yaw[2], 0)
        ui.set(reference.freestanding_body_yaw, false)
        ui.set(reference.edge_yaw, false)
        ui.set(reference.freestanding[1], false)
        ui.set(reference.freestanding[2], 'On hotkey')
        ui.set(reference.roll, 0)
    end)
    
    local IsNewClientAvailable = panorama.loadstring([[
        var oldClientStatus = NewsAPI.IsNewClientAvailable;
    
        return {
            disable: function(){
                NewsAPI.IsNewClientAvailable = function(){ return false };
            },
            restore: function(){
                NewsAPI.IsNewClientAvailable = oldClientStatus;
            }
        }
    ]])()
    
    IsNewClientAvailable.disable()
    
    client.set_event_callback("shutdown", function()
        IsNewClientAvailable.restore()
    end)

    legslider = function()
        local localplayer = entity.get_local_player()
        if not entity.is_alive(localplayer) then
            return
        end
        local m_flDuckAmount = entity.get_prop(localplayer, "m_flDuckAmount") > 0.5
        local is_dt = ui.get(reference.double_tap[1]) and ui.get(reference.double_tap[2])
        local is_os = ui.get(reference.on_shot_anti_aim[1]) and ui.get(reference.on_shot_anti_aim[2])
        local timing = globals.tickcount() % 69
        local lp_vel = helpers.get_velocity(entity.get_local_player())
        local b_yaw = entity.get_prop(entity.get_local_player(), "m_flPoseParameter", 11) * 120 - 60
        local side = b_yaw > 0 and 1 or -1

        if ui.get(anim_breakerx) == "Legbreaker" and not helpers.in_air(localplayer) and timing > 1 and lp_vel > 50 then
            entity.set_prop(localplayer, "m_flPoseParameter", client.random_float(0.75, 1), 0)
            ui.set(reference.lm, client.random_int(1, 3) == 1 and "Off" or "Always slide")
        end

        if not is_dt and not is_os and not m_flDuckAmount then
            if vars.p_state == 2 then
                entity.set_prop(localplayer, "m_flPoseParameter", 50 and 0.5 or 0, 14)
            elseif vars.p_state == 4 then
                entity.set_prop(localplayer, "m_flPoseParameter", 5 and 50 * 0.01 or 0, 10)
            else
                entity.set_prop(localplayer, "m_flPoseParameter", 5 and 0.8 or 0, 8)
            end
        end
    end;

    
    menuToggle = function(state, reference)
        for i, v in pairs(reference) do
            if type(v) == "table" then
                for i2, v2 in pairs(v) do
                    ui.set_visible(v2, state)
                end
            else
                ui.set_visible(v, state)
            end
        end
    end;    
end 
main()
    

    

