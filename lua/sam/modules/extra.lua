if SAM_LOADED then return end

local sam, command, language = sam, sam.command, sam.language   

if SERVER then
    util.AddNetworkString( "SAMFriendsCheck" )
    hook.Add( "EntityTakeDamage", "DBanCode", function( target, dmginfo )
        if dmginfo:GetAttacker():sam_get_nwvar("dban", false) == true then
            dmginfo:ScaleDamage( 0 )
        end
    end )
    local freeze_player = function(ply)
        if SERVER then
            ply:Lock()
        end
        ply:SetMoveType(MOVETYPE_NONE)
        ply:SetCollisionGroup(COLLISION_GROUP_WORLD)
    end  
        
end

local find_empty_pos -- https://github.com/FPtje/DarkRP/blob/b147d6fa32799136665a9fd52d35c2fe87cf7f78/gamemode/modules/base/sv_util.lua#L149
do
	local is_empty = function(vector, ignore)
		local point = util.PointContents(vector)
		local a = point ~= CONTENTS_SOLID
			and point ~= CONTENTS_MOVEABLE
			and point ~= CONTENTS_LADDER
			and point ~= CONTENTS_PLAYERCLIP
			and point ~= CONTENTS_MONSTERCLIP
		if not a then return false end

		local ents_found = ents.FindInSphere(vector, 35)
		for i = 1, #ents_found do
			local v = ents_found[i]
			if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics" or v.NotEmptyPos) and v ~= ignore then
				return false
			end
		end

		return true
	end

	local distance, step, area = 600, 30, Vector(16, 16, 64)
	local north_vec, east_vec, up_vec = Vector(0, 0, 0), Vector(0, 0, 0), Vector(0, 0, 0)

	find_empty_pos = function(pos, ignore)
		if is_empty(pos, ignore) and is_empty(pos + area, ignore) then
			return pos
		end

		for j = step, distance, step do
			for i = -1, 1, 2 do
				local k = j * i

				-- North/South
				north_vec.x = k
				if is_empty(pos + north_vec, ignore) and is_empty(pos + north_vec + area, ignore) then
					return pos + north_vec
				end

				-- East/West
				east_vec.y = k
				if is_empty(pos + east_vec, ignore) and is_empty(pos + east_vec + area, ignore) then
					return pos + east_vec
				end

				-- Up/Down
				up_vec.z = k
				if is_empty(pos + up_vec, ignore) and is_empty(pos + up_vec + area, ignore) then
					return pos + up_vec
				end
			end
		end

		return pos
	end
end

    command.set_category("Extra")

    /*---------------------------------------------------------------------------
	    Set Run Speed	
    ---------------------------------------------------------------------------*/
    command.new("setrunspeed")
        :SetPermission("setrunspeed", "superadmin")

        :AddArg("player")
        :AddArg("number", {hint = "amount", optional = true, min = 100, max = 600, default = 280})
        :AddArg("number", {hint = "minutes", optional = true, default = 600, round = true})

        :Help("Sets the Players Run Speed")

        :OnExecute(function(ply, targets, amount, length)
            for i = 1, #targets do
                targets[i]:SetRunSpeed(amount)
                timer.Create("SAM.RunSpeed." .. targets[i]:SteamID(), length*60, 1, function()
                    if IsValid(targets[i]) then
                        for i = 1, #targets do
                            targets[i]:SetRunSpeed(240)
                        end
                    end
                end)
            end

            if sam.is_command_silent then return end

            ply:sam_send_message("{A} set the Run Speed for {T} to {V}", {
                A = ply, T = targets, V = amount
            })
        end) 
    :End()

    /*---------------------------------------------------------------------------
	    Set Walk Speed	
    ---------------------------------------------------------------------------*/
    command.new("setwalkspeed")
        :SetPermission("setwalkspeed", "superadmin")

        :AddArg("player")
        :AddArg("number", {hint = "amount", optional = true, min = 100, max = 600, default = 160})
        :AddArg("number", {hint = "seconds", optional = true, default = 600, round = true})

        :Help("Sets the Players Walk Speed")

        :OnExecute(function(ply, targets, amount, length) 
            for i = 1, #targets do
                targets[i]:SetWalkSpeed(amount)
                timer.Create("SAM.WalkSpeed." .. targets[i]:SteamID(), length, 1, function()
                    if IsValid(targets[i]) then
                        for i = 1, #targets do
                            targets[i]:SetWalkSpeed(160)
                        end
                    end
                end)
            end

            if sam.is_command_silent then return end
            ply:sam_send_message("{A} set the Walk Speed for {T} to {V}", {
                A = ply, T = targets, V = amount
            })
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Set Jump Power
    ---------------------------------------------------------------------------*/
    command.new("setjumppower")
        :SetPermission("setjumppower", "superadmin")

        :AddArg("player")
        :AddArg("number", {hint = "amount", optional = true, min = 100, max = 600, default = 200})
        :AddArg("number", {hint = "seconds", optional = true, default = 600, round = true})

        :Help("Sets the Players Jump Power")

        :OnExecute(function(ply, targets, amount, length)
            for i = 1, #targets do
                targets[i]:SetJumpPower(amount)
                timer.Create("SAM.JumpPower." .. targets[i]:SteamID(), length, 1, function()
                    if IsValid(targets[i]) then
                        for i = 1, #targets do
                            targets[i]:SetJumpPower(200)
                        end
                    end
                end)
            end

            if sam.is_command_silent then return end
            ply:sam_send_message("{A} set the Jump Power for {T} to {V}", {
                A = ply, T = targets, V = amount
            })
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Bhops	
    ---------------------------------------------------------------------------*/
    if CLIENT then
        hook.Add("CreateMove", "BHop", function(ucmd)
            if LocalPlayer():GetNWInt("bhop") == 1 and IsValid(LocalPlayer()) and bit.band(ucmd:GetButtons(), IN_JUMP) > 0 then
                ucmd:SetButtons( ucmd:GetButtons() - IN_JUMP )
                if LocalPlayer():OnGround() then
                    ucmd:SetButtons( ucmd:GetButtons() + IN_JUMP )
                end
            end
        end)
    end

    command.new("givebhop")
        :SetPermission("givebhop", "superadmin")

        :AddArg("player")
        :AddArg("number", {hint = "amount", optional = true, min = 0, max = 1, default = 0, round = true})

        :Help("Gives the Players Bhops")

        :OnExecute(function(ply, targets, amount)
            for i = 1, #targets do
                targets[i]:SetNWInt("bhop",amount)
            end

            if sam.is_command_silent then return end
            
            if amount == 1 then
                ply:sam_send_message("{A} gave {T} Bhops", {
                    A = ply, T = targets, V = amount
                })
            else
                ply:sam_send_message("{A} disabled {T}'s Bhops", {
                    A = ply, T = targets, V = amount
                })
            end
        end)
    :End()

    /*---------------------------------------------------------------------------
	    PlaySound		
    ---------------------------------------------------------------------------*/
    command.new("playsound")
        :SetPermission("playsound", "admin")

        :AddArg("text", {hint = "sound"})

        :Help("Plays a sound on all Clients")

        :OnExecute(function(ply, text)
        if not file.Exists("sound/"..text, "GAME") then
            sam.player.send_message(ply, "The sound "..text.." doesn't exist on the Server!")
            return
        end
        BroadcastLua('surface.PlaySound("'..text..'")')
        if sam.is_command_silent or !ply:IsPlayer() then return end
            ply:sam_send_message("{A} played '{V}' on all Players", {
                A = ply, V = text
            })
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Steam Profile
    ---------------------------------------------------------------------------*/
    command.new("steamprofile")
        :SetPermission("steamprofile", "admin")

        :AddArg("player", {optional = true})

        :Help("Opens the Players Steam Profile")

        :OnExecute(function(ply, targets)
            for i = 1, #targets do
                ply:SendLua("gui.OpenURL('http://steamcommunity.com/profiles/"..targets[i]:SteamID64() .."')")
            end
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Get IP		
    ---------------------------------------------------------------------------*/	
	command.new("getip")
		:SetPermission("getip", "superadmin")

		:AddArg("player", {optional = true, single_target = true})

		:OnExecute(function(ply, targets)
            for i = 1, #targets do

                ply:SendLua([[SetClipboardText( "]] .. tostring(string.sub( tostring( targets[i]:IPAddress() ), 1, string.len( tostring(targets[i]:IPAddress() ) ) - 6 )) ..  [[" )
                    chat.AddText( Color(151, 211, 255), "IP: '", Color(0, 255, 0), "]] .. tostring(string.sub( tostring( targets[i]:IPAddress() ), 1, string.len( tostring(targets[i]:IPAddress() ) ) - 6 )) ..  [[" , Color(151, 211, 255), "' successfully copied!")
                ]])
            end
	    end)
	:End()

    /*---------------------------------------------------------------------------
	    Friends Check		
    ---------------------------------------------------------------------------*/
	command.new("friends")
		:SetPermission("friends", "superadmin")

		:AddArg("player", {optional = true, single_target = true})

		:OnExecute(function(ply, targets)
		for i = 1, #targets do
            net.Start( "SAMFriendsCheck" )
                net.WriteEntity( ply )
                net.Send( targets[i] )

		end
	end)
	:End()

	if ( CLIENT ) then

		local friendstab = {}

        net.Receive( "SAMFriendsCheck", function( len, ply )
            local caller = net.ReadEntity()
        	for k, v in pairs( player.GetAll() ) do
				if v:GetFriendStatus() == "friend" then
					table.insert( friendstab, v:Nick() )
				end
			end
			
			net.Start( "friends_check" )
				net.WriteEntity( caller )
				net.WriteTable( friendstab )
			net.SendToServer()
			
			table.Empty( friendstab )
        end)

	
	end
	
	if ( SERVER ) then

		util.AddNetworkString( "friends_check" )
		
		net.Receive( "friends_check", function( len, ply )
		
			local calling, tabl = net.ReadEntity(), net.ReadTable() 
			local tab = table.concat( tabl, ", " )
			
			if ( string.len( tab ) == 0 and table.Count( tabl ) == 0 ) then	
                calling:ChatPrint(ply:Nick().."("..ply:SteamID()..") is not Friends with anyone on the Server")		
			else
                calling:ChatPrint(ply:Nick().."("..ply:SteamID()..") is Friends with "..tab)					

			end
			
		end )
		
	end

    /*---------------------------------------------------------------------------
	    Disable Damage for Players		
    ---------------------------------------------------------------------------*/

        command.new("dban")
        :SetPermission("dban", "superadmin")

        :AddArg("player", {allow_higher_target = false, single_target = true})
        :AddArg("text", {hint = "reason", optional = true, default = sam.language.get("default_reason")})
        :AddArg("number", {hint = "minutes", optional = true, default = 600, round = true})

        :Help("Disables the ability for the Player to Deal Damage")

        :OnExecute(function(ply, targets, reason, length)
            for i = 1, #targets do
                targets[i]:sam_set_nwvar("dban", true)
                timer.Create("SAM.DBan." .. targets[i]:SteamID(), length*60, 1, function()
                    if IsValid(targets[i]) then
                        targets[i]:sam_set_nwvar("dban", false)
                    end
                end)
            end

            if sam.is_command_silent then return end
            
            ply:sam_send_message("{A} Disabled Damage for {T} for reason: {V}", {
                A = ply, T = targets, V = reason
            })
        end)
    :End()

    command.new("undban")
        :SetPermission("undban", "superadmin")

        :AddArg("player", {allow_higher_target = false, single_target = true})

        :Help("Re-Enables the ability for the Player to Deal Damage")

        :OnExecute(function(ply, targets)
            for i = 1, #targets do
                targets[i]:sam_set_nwvar("dban", false)
                timer.Remove("SAM.DBan." .. ply:SteamID())
            end

            if sam.is_command_silent then return end
            
            ply:sam_send_message("{A} Re-Enabled Damage for {T}", {
                A = ply, T = targets
            })
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Bring & Freeze	
    ---------------------------------------------------------------------------*/
    command.new("fbring")
        :DisallowConsole()
        :SetPermission("fbring", "admin")

        :AddArg("player", {cant_target_self = true})

        :Help("Teleports the Player to you and Freezes them")

        :OnExecute(function(ply, targets)
            if not ply:Alive() then
                return ply:sam_send_message("dead")
            end

            if ply:InVehicle() then
                return ply:sam_send_message("leave_car")
            end

            if ply:sam_get_exclusive(ply) then
                return ply:sam_send_message(ply:sam_get_exclusive(ply))
            end

            local teleported = {admin = ply}
            local all = targets.input == "*"

            for i = 1, #targets do
                local target = targets[i]

                if target:sam_get_exclusive(ply) then
                    if not all then
                        ply:sam_send_message(target:sam_get_exclusive(ply))
                    end
                    continue
                end

                if not target:Alive() then
                    target:Spawn()
                end

                target.sam_tele_pos, target.sam_tele_ang = target:GetPos(), target:EyeAngles()

                target:ExitVehicle()
                target:SetVelocity(Vector(0, 0, 0))
                target:SetPos(find_empty_pos(ply:GetPos(), target))
                target:SetEyeAngles((ply:EyePos() - target:EyePos()):Angle())

                table.insert(teleported, target)

                timer.Simple(1, function()
                    if SERVER then
                        target:Lock()
                    end
                    target:SetMoveType(MOVETYPE_NONE)
                    target:SetCollisionGroup(COLLISION_GROUP_WORLD)
                    target:sam_set_nwvar("frozen", true)
                    target:sam_set_exclusive("frozen")
                end)
            end

            if #teleported > 0 then
                ply:sam_send_message("bring", {
                    A = ply, T = teleported
                })
            end
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Get Ent Owner		
    ---------------------------------------------------------------------------*/
    command.new("id")
		:SetPermission("id", "admin")

		:Help("Gets the Owner of the Entity that you're looking at")

		:OnExecute(function(ply)
			local ent = ply:GetEyeTrace().Entity
			if not IsValid(ent) then
				return ply:sam_send_message("Not looking at a Valid Entity")
			end
			local ent_owner = tostring(FPP.entGetOwner(ent))

			ply:sam_send_message("Owned by "..ent_owner, {
                A = ent_class
            })
		end)
	:End()

    /*---------------------------------------------------------------------------
	    Check if Banned	
    ---------------------------------------------------------------------------*/
    command.new("checkban") -- Finish
		:SetPermission("checkban", "admin")
        :AddArg("steamid")
		:Help("Checks if the SteamID is banned")

		:OnExecute(function(ply, promise)
			
            promise:done(function(data)
                local steamid, target = data[1], data[2]

                sam.player.is_banned(steamid,function(banned)
                    if !(banned) then
                        ply:sam_send_message("{T} isn't banned", {--banned["reason"]
                            A = ply, T = steamid
                        })
                    else
                        ply:sam_send_message("{T} was Banned for "..banned["reason"].." Unban Date: "..os.date( "%I:%M:%S - %d/%m/%Y" , banned["unban_date"] ), {
                            A = ply, T = steamid
                        })
                    end
                end)
            end)
		end)
	:End()

    /*---------------------------------------------------------------------------
        Mute & Gag
    ---------------------------------------------------------------------------*/
    do
        command.new("mg")
            :SetPermission("mg", "admin")
    
            :AddArg("player")
            :AddArg("length", {optional = true, default = 0, min = 0})
            :AddArg("text", {hint = "reason", optional = true, default = sam.language.get("default_reason")})
    
            :GetRestArgs()
    
            :Help("Mutes and Gags Player")
    
            :OnExecute(function(ply, targets, length, reason)
                local current_time = SysTime()
    
                for i = 1, #targets do
                    local target = targets[i]
				    target:sam_set_pdata("unmute_time", length ~= 0 and (current_time + length * 60) or 0)

                    target.sam_gagged = true
                    if length ~= 0 then
                        timer.Create("SAM.UnGag" .. target:SteamID64(), length * 60, 1, function()
                            RunConsoleCommand("sam", "ungag", "#" .. target:EntIndex())
                        end)
                    end
                end
                ply:sam_send_message("{A} Muted and Gagged {T} for {V} Reason: {V_2}", {
                    A = ply, T = targets, V = sam.format_length(length), V_2 = reason
                })
            end)
        :End()
    
    end

    /*---------------------------------------------------------------------------
	    Warn & Ban		
    ---------------------------------------------------------------------------*/
    command.new("wban") 
	:SetPermission("wban", "admin")

	:AddArg("player", {single_target = true})
	:AddArg("length", {optional = true, default = 0})
	:AddArg("text", {hint = "reason", optional = true, default = sam.language.get("default_reason")})

	:GetRestArgs()

	:Help("Bans and Warns the Player")

	:OnExecute(function(ply, targets, length, reason)
		local target = targets[1]
		if ply:GetBanLimit() ~= 0 then
			if length == 0 then
				length = ply:GetBanLimit()
			else
				length = math.Clamp(length, 1, ply:GetBanLimit())
			end
		end
        AWarn:CreateWarningID( target:SteamID64(), ply:SteamID64(), reason )
		target:sam_ban(length, reason, ply:SteamID())

		ply:sam_send_message("ban", {
			A = ply, T = target:Name(), V = sam.format_length(length), V_2 = reason
		})
	end)
:End()

do
	local jail_props = {
		Vector(0, 0, -5), Angle(90, 0, 0);
		Vector(0, 0, 97), Angle(90, 0, 0);

		Vector(21, 31, 46), Angle(0, 90, 0);
		Vector(21, -31, 46), Angle(0, 90, 0);
		Vector(-21, 31, 46), Angle(0, 90, 0);
		Vector(-21, -31, 46), Angle(0, 90, 0);

		Vector(-52, 0, 46), Angle(0, 0, 0);
		Vector(52, 0, 46), Angle(0, 0, 0)
	}

	local remove_jail = function(ply_jail_props)
		for _, jail_prop in ipairs(ply_jail_props) do
			if IsValid(jail_prop) then
				jail_prop:Remove()
			end
		end
	end

	local unjail = function(ply)
		if not IsValid(ply) then return end
		if not ply:sam_get_nwvar("jailed") then return end

		remove_jail(ply.sam_jail_props)

		ply.sam_jail_props = nil
		ply.sam_jail_pos = nil

		ply:sam_set_nwvar("jailed", nil)
		ply:sam_set_exclusive(nil)

		timer.Remove("SAM.Unjail." .. ply:SteamID())
		timer.Remove("SAM.Jail.Watch." .. ply:SteamID())
	end

	local return_false = function()
		return false
	end

	local function jail(ply, time)
		if not IsValid(ply) then return end
		if not isnumber(time) or time < 0 then
			time = 0
		end

		if ply:sam_get_nwvar("frozen") then
			RunConsoleCommand("sam", "unfreeze", "#" .. ply:EntIndex())
		end

		if not ply:sam_get_nwvar("jailed") or (not ply.sam_jail_props or not IsValid(ply.sam_jail_props[1])) then
			ply:ExitVehicle()
			ply:SetMoveType(MOVETYPE_WALK)

			ply.sam_jail_pos = ply:GetPos()

			ply:sam_set_nwvar("jailed", true)
			ply:sam_set_exclusive("in jail")

			if ply.sam_jail_props then
				for k, v in ipairs(ply.sam_jail_props) do
					if IsValid(v) then
						v:Remove()
					end
				end
			end

			local ply_jail_props = {}
			for i = 1, #jail_props, 2 do
				local jail_prop = ents.Create("prop_physics")
				jail_prop:SetModel("models/props_building_details/Storefront_Template001a_Bars.mdl")
				jail_prop:SetPos(ply.sam_jail_pos + jail_props[i])
				jail_prop:SetAngles(jail_props[i + 1])
				jail_prop:SetMoveType(MOVETYPE_NONE)
				jail_prop:Spawn()
				jail_prop:GetPhysicsObject():EnableMotion(false)
				jail_prop.CanTool = return_false
				jail_prop.PhysgunPickup = return_false
				jail_prop.jailWall = true
				table.insert(ply_jail_props, jail_prop)
			end
			ply.sam_jail_props = ply_jail_props
		end

		local steamid = ply:SteamID()

		if time == 0 then
			timer.Remove("SAM.Unjail." .. steamid)
		else
			timer.Create("SAM.Unjail." .. steamid, time, 1, function()
				if IsValid(ply) then
					unjail(ply)
				end
			end)
		end

		timer.Create("SAM.Jail.Watch." .. steamid, 0.5, 0, function()
			if not IsValid(ply) then
				return timer.Remove("SAM.Jail.Watch." .. steamid)
			end

			if ply:GetPos():DistToSqr(ply.sam_jail_pos) > 4900 then
				ply:SetPos(ply.sam_jail_pos)
			end

			if not IsValid(ply.sam_jail_props[1]) then
				jail(ply, timer.TimeLeft("SAM.Unjail." .. steamid) or 0)
			end
		end)
	end
    /*---------------------------------------------------------------------------
	    Warn & Jail		
    ---------------------------------------------------------------------------*/
	command.new("wjail")
		:SetPermission("wjail", "admin")

		:AddArg("player")
		:AddArg("length", {optional = true, default = 0, min = 0})
		:AddArg("text", {hint = "reason", optional = true, default = sam.language.get("default_reason")})

		:GetRestArgs()

		:Help("Warns and Jail Player")

		:OnExecute(function(ply, targets, length, reason)
			for i = 1, #targets do
                AWarn:CreateWarningID( targets[i]:SteamID64(), ply:SteamID64(), reason )
				jail(targets[i], length * 60)
			end

			ply:sam_send_message("jail", {
				A = ply, T = targets, V = sam.format_length(length), V_2 = reason
			})
		end)
	:End()

	local disallow = function(ply)
		if ply:sam_get_nwvar("jailed") then
			return false
		end
	end

	for _, v in ipairs({"PlayerNoClip", "SAM.CanPlayerSpawn", "CanPlayerEnterVehicle", "CanPlayerSuicide", "CanTool"}) do
		hook.Add(v, "SAM.Jail", disallow)
	end
end

    /*---------------------------------------------------------------------------
	    Job Ban		
    ---------------------------------------------------------------------------*/
    command.new("jobban")
        :SetPermission("jobban", "admin")

        :AddArg("player", {single_target = true})
        :AddArg("text", {hint = "job"})
        :AddArg("number", {hint = "minutes", optional = true, default = 60, round = true})
        :AddArg("text", {hint = "reason", optional = true, default = sam.language.get("default_reason")})

        :Help("Bans the Player from a Certain Job for set amount of time")

        :OnExecute(function(ply, targets, job, length, reason)
            for i = 1, #targets do
                local jobName = string.lower(job)
                local jobID
                for _, job in pairs(RPExtraTeams) do
                    if (string.lower(job["name"]) == jobName) then
                        jobID = job["team"] or nil
                    end
                end
                if (jobID) then
                    targets[i]:teamBan(jobID, length*60)
                end
            end

            if sam.is_command_silent then return end
            ply:sam_send_message("{A} banned {T} from the "..tostring(job).." Job for "..length.." Minutes for Reason: "..reason, {
                A = ply, T = targets
            })
        end) 
    :End()

    /*---------------------------------------------------------------------------
	    Job UnBan		
    ---------------------------------------------------------------------------*/
    command.new("jobunban")
        :SetPermission("jobunban", "admin")

        :AddArg("player", {single_target = true})
        :AddArg("text", {hint = "job"})

        :Help("Bans the Player from a Certain Job for set amount of time")

        :OnExecute(function(ply, targets, job)
            for i = 1, #targets do
                local jobName = string.lower(job)
                local jobID
                for _, job in pairs(RPExtraTeams) do
                    if (string.lower(job["name"]) == jobName) then
                        jobID = job["team"] or nil
                    end
                end
                if (jobID) then
                    targets[i]:teamUnBan(jobID)
                end
            end

            if sam.is_command_silent then return end
            ply:sam_send_message("{A} unbanned {T} from the "..tostring(job).." Job", {
                A = ply, T = targets
            })
        end) 
    :End()

    /*---------------------------------------------------------------------------
	    cpban	
    ---------------------------------------------------------------------------*/
    command.new("cpban")
        :SetPermission("cpban", "admin")

        :Help("Bans the Player from a All CP Jobs for set amount of time")

        :AddArg("player", {single_target = true})
        :AddArg("number", {hint = "minutes", optional = true, default = 60, round = true})
        :AddArg("text", {hint = "reason", optional = true, default = sam.language.get("default_reason")})

        :OnExecute(function(ply, targets, length, reason)
            for i = 1, #targets do
                for _, job in pairs(GAMEMODE.CivilProtection) do
                    targets[i]:teamBan(_, length*60)
                end
            end

            if sam.is_command_silent then return end
            ply:sam_send_message("{A} banned {T} from the Police Jobs for "..length.." Minutes for Reason: "..reason, {
                A = ply, T = targets
            })
        end) 
    :End()
    /*---------------------------------------------------------------------------
	    Disable Physgun
    ---------------------------------------------------------------------------*/
    command.new("disablephysgun")
        :SetPermission("disablephysgun", "admin")
        :Help("Disables Being able to Physgun Players Off Duty")

        :OnExecute(function(ply)
            ply:sam_set_nwvar("physgunEnabled", false)
            ply:sam_send_message("{A} Disabled Their Staff Physgun", {
                A = ply
            })
        end)
    :End()
    
    /*---------------------------------------------------------------------------
	    Enable Physgun
    ---------------------------------------------------------------------------*/
    command.new("enablephysgun")
        :SetPermission("enablephysgun", "admin")
        :Help("Enables Being able to Physgun Players Off Duty")

        :OnExecute(function(ply)
            ply:sam_set_nwvar("physgunEnabled", true)

            ply:sam_send_message("{A} Enabled Their Staff Physgun", {
                A = ply
            })
        end)
    :End()

    /*---------------------------------------------------------------------------
	    Set Door Owner
    ---------------------------------------------------------------------------*/
    command.new("doorowner")
		:SetPermission("doorowner", "superadmin")
        :AddArg("player")

		:Help("Sets the Owner of the Door you're looking at")

		:OnExecute(function(ply, targets)
			local ent = ply:GetEyeTrace().Entity
			if not IsValid(ent) or not ent.keysUnOwn then
				return ply:sam_send_message("Door is Invalid")
			end
			local door_owner = ent:getDoorOwner()
			if not IsValid(door_owner) then
                for i = 1, #targets do
                    ent:keysOwn(targets[i])
                end
            else
                ent:keysUnOwn(door_owner)
                for i = 1, #targets do
                    ent:keysOwn(targets[i])
                end
			end
		

			ply:sam_send_message("{T} Owns this Door Now", {
				A = ply, T = targets
			})
		end)
	:End() 