--------------------------------------------------------------
--- script by SlappyMoose, for his "D6 Kriegsspiel" system ---
--------------------------------------------------------------
-- tag all units with "D6KS Shared Script", and "D6KS Infantry" (or Cavalry or Artillery)
function onLoad()
	loadSharedScripts()
end

function loadSharedScripts()
	for _, obj in ipairs(getAllObjects()) do
		if obj.hasTag("D6KS Infantry") or obj.hasTag("D6KS Cavalry") or obj.hasTag("D6KS Artillery") then -- or obj.hasTag("D6KS Skirmisher") then
			loadUnitScript(obj)
		end
	end
end

unitLUA = [[
if self.hasTag("D6KS Infantry") then unitScript = 1
elseif self.hasTag("D6KS Cavalry") then unitScript = 2
elseif self.hasTag("D6KS Artillery") then unitScript = 3
elseif self.hasTag("D6KS Skirmisher") then unitScript = 4 end

-------------------
--- LOAD / SAVE ---
-------------------
function onSave() --We make a table of data we want to save. WE CAN ONLY SAVE 1 TABLE.
	local data_to_save = {
		strVal=strVal,
		formationVal=formationVal,
		cohesion=cohesion,
		advancing=advancing,
		direction=direction,
		hasTurned=hasTurned,
		faction=faction,
		unitType=unitType,
	} --We use this command to convert the table into a string
    saved_data = JSON.encode(data_to_save) --And this inserts the string into the save information for this script.
    return saved_data --Data is now saved.
end

function onload(saved_data)
	loadDefaults()
    if saved_data ~= "" then --First we check if there was information saved in this script yet
        local loaded_data = JSON.decode(saved_data) --If there is save data, we convert the string back to a table, and pull the data out
        strVal = loaded_data.strVal
        formationVal = loaded_data.formationVal
        cohesion = loaded_data.cohesion
		advancing = loaded_data.advancing
		direction = loaded_data.direction
		hasTurned = loaded_data.hasTurned
		faction = loaded_data.faction
		unitType = loaded_data.unitType
    end

	varFix()
	updateContextMenu()
	CreateButtons()
	strUpdate()
	setFormation()
	setCohesion()
	-- printDebug()

	Wait.time(updateCheck, 5, -1) -- call every 0.5 seconds
end

function loadDefaults()
	name = self.getName()

	strTooltip = "Strength" --what you want to track on Counter #3
	strColor = 'White' --what color do you want the counter text to be?
	str_MIN = 0 --minimum amount allowed for Counter #3
	strVal = 6
	unitSize = 0 -- 0 = full, -1 = reduced, -2 = depleted, 1 = over strength

	if unitScript == 1 then 
		str_MAX = 6 --maximum amount allowed for Counter #3
		str_sml = 0 --maximum value for a small block
		str_med = 3 --maximum value for a medium block
		str_big = 6 --maximum value for an oversized block
	elseif unitScript == 4 then
		str_MAX = 3 --maximum amount allowed for Counter #3
		str_sml = 0 --maximum value for a small block
		str_med = 1 --maximum value for a medium block
		str_big = 3 --maximum value for an oversized block
	elseif unitScript == 2 then
		str_MAX = 3 --maximum amount allowed for Counter #3
		str_sml = 0 --maximum value for a small block
		str_med = 1 --maximum value for a medium block
		str_big = 3 --maximum value for an oversized block
	elseif unitScript == 3 then
		str_MAX = 8 --maximum amount allowed for Counter #3
		str_sml = 2 --maximum value for a small block
		str_med = 4 --maximum value for a medium block
		str_big = 8 --maximum value for an oversized block
	end

	direction = 0 --left = 0, right = 1
	advancing = false
	hasTurned = false
	cohesion = 2
	cohesionMIN = 0
	cohesionMAX = 2
	cohesionTooltip2 = "Cohesive"
	cohesionTooltip1 = "Disordered"
	cohesionTooltip0 = "BROKEN"
	cohesionLabel2 = "++"
	cohesionLabel1 = "∼~"
	cohesionLabel0 = "BROKEN"
	cohesionColor2 = {255, 255, 255, 127}
	cohesionColor1 = {255, 255, 0, 127}
	cohesionColor0 = {255, 0, 0, 127}

	nameColor = 'White' --what color do you want the piece Name to be?
	faction = "red"
	unitType = 1 -- 1 = hussar, 2 = dragoons, 3 = lancer, 4 = cuirassier
	unitTypeCount = 4

	formationVal = 1
	unitScale = self.getScale()
	meshUrl = nil
end

function varFix()
	if strVal == nil then strVal = str_MAX end
	if unitType == nil then unitType = 1 end
	if formationVal == nil then formationVal = 1 end
	
	if cohesion > cohesionMAX then cohesion = cohesionMAX
	elseif cohesion < cohesionMIN then cohesion = cohesionMIN end
	
	-- limit formation range to unit
	if unitScript == 2 then
		if formationVal < 2 then formationVal = 2 end
		if formationVal > 3 then formationVal = 3 end
	elseif unitScript == 3 then
		if formationVal > 3 then formationVal = 3 end
	end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

function CreateButtons()
----------------------------------
----- front/counter displays -----
----------------------------------

--Unit Name front display
self.createButton({index = 0, click_function = "nullFunction", function_owner = self,
  label = name, position = {0, 0.26, 8}, scale = {25, 25, 25}, width = 0,
  height = 0, font_size = 225, font_color = nameColor})

--Cohesion display on the front
if name ~= nil and name ~= "" then createCohesion = true
else createCohesion = false
end
	
if createCohesion then
	self.createButton({click_function = "clickCohesion", function_owner = self,
	  label = cohesionLabel3, position = {0, 0.26, 20}, rotation = {0, 0, 0}, scale = {25, 25, 25}, width = 180,
	  height = 110, font_size = 150, color = {0,0,0,0}, font_color = cohesionColor3, tooltip = cohesionTooltip3})
else
	self.createButton({click_function = "nullFunction", function_owner = self,
	  label = cohesionLabel3, position = {0, 0.26, 20}, rotation = {0, 0, 0}, scale = {25, 25, 25}, width = 180,
	  height = 0, font_size = 0, color = {0,0,0,0}, font_color = {0,0,0,0}, tooltip = cohesionTooltip3})
end

-- Unit Name input box
-- self.createInput({value = name, input_function = "editName", label = "Unit", function_owner = self,
    -- alignment = 3, position = {0, -0.05, -10}, rotation = {0, 0, 180}, width = 400, height = 110,
    -- font_size = 70, scale={x=15, y=15, z=15}, font_color= {1,1,1,1}, color = {0.1,0.1,0.1,1}})

--Strength Counter on the back
self.createButton({index = 2, click_function = "nullFunction", function_owner = self,
  label = strVal, position = {0, -0.05, -5}, rotation = {0, 0, 0}, scale = {25, 25, 25}, width = 180,
  height = 160, font_size = 160, font_color = strColor, color = {0, 0, 0}, tooltip = strTooltip})

--formation overlays
formHalt = {index = 3, click_function = "nullFunction", function_owner = self, label = "", position = {1, 0.25, 0.25},	rotation = {0, 0, 0}, scale = {2, 2, 2}, width = 0, height = 0, font_size = 160, font_color = {1, 1, 1, 1}}

formInfAdvance = {index = 3, click_function = "nullFunction", function_owner = self, label = "                                        →", position = {0, 0.1, 5}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}
-- formInfAdvanceL = {index = 3, click_function = "nullFunction", function_owner = self, label = "←                                      ", position = {0, 0.1, 5}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}

formAttack = {index = 3, click_function = "nullFunction", function_owner = self, label = "↑A↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {45, 1, 45}, width = 0, height = 0, font_size = 200, font_color = {1,0,0,1}, color = {0,0,0,1}}

formCavAdvance = {index = 3, click_function = "nullFunction", function_owner = self, label = "↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}

self.createButton(formHalt)

end --end button creation

-----------------
--- functions ---
-----------------

function printDebug()
	print("unitScript = " .. unitScript)
	print("unitSize = " .. unitSize)
	print("formationVal = "..formationVal)
	print("advancing, direction, hasTurned = " .. (advancing and 'true' or 'false') .. ", " .. direction .. ", " .. (hasTurned and 'true' or 'false'))
	-- print("FormationOverlay = " .. (formationModel and 'true' or 'false'))
	-- print("faction = " .. faction)
	-- print("unitType = " .. unitType)
	print("----------")
end

function setLine()
	if formationVal == 1 then
		toggleAdvance()
	else
		formationVal = 1
		advancing = false
	end
	if advancing then self.editButton(formAttack) end

	setFormation()
end

function setAttack()
	if formationVal == 2 then
		toggleAdvance()
	else
		formationVal = 2
		advancing = false
	end
	if advancing then self.editButton(formAttack) end

	setFormation()
end

function setMarch()
	-- print ("starting setMarch...")
	-- printDebug()
	if formationVal == 3 and not hasTurned then
		advancing = true
	else
		formationVal = 3
		advancing = false
		direction = 1
		hasTurned = false
	end
	if advancing then
		if unitScript == 1 and direction == 0
			then hasTurned = true
		end
		changeDirection()
		if unitScript == 2 then 
			hasTurned = true
		end
	end
	
	setFormation()
	-- print ("Finished setMarch.")
	-- printDebug()
end

function setSquare()
	advancing = false
	formationVal = 4
	setFormation()
end

function setUnlimbered()
	advancing = false
	formationVal = 1
	setFormation()
end

function setLimbered()
	if formationVal == 3 then toggleAdvance() end
	formationVal = 3
	setFormation()
end

function setDefeated()
	advancing = false
	formationVal = 4
	setFormation()
end


function toggleAdvance()
	advancing = not advancing
end

function changeDirection()
	direction = 1-direction
end

function checkAdvance()
	if not advancing then
		self.editButton(formHalt)
	else
		if unitScript == 1 then
			if formationVal == 3 then
				self.editButton(formInfAdvance)
				if direction == 0 then self.editButton({index = 3, rotation = {0,0,180}}) end
				if unitSize == -1 then
					self.editButton({index = 3, label = "                                →"})
				elseif unitSize == -2 then
					self.editButton({index = 3, label = "                           →"})
				end
			else
				self.editButton(formAttack)
			end
		else
			if formationVal == 3  then
				self.editButton(formCavAdvance)
			else 
				self.editButton(formAttack)
			end
		end
	end
end

function updateUnitData()
	formPosOffset = Vector(0,0,0)
	formScale = {1, 1, 1}

	-- INFANTRY --
	if unitScript == 1 then
		if faction == "red" then
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_inf-red.png"
		else 
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_inf-blue.png"
		end
		if formationVal == 1 or formationVal == 3 then
			meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693391/0943345DA6F3BD247B7073EF24B54579EA3126F0/" -- mesh infantry line / open column
		elseif formationVal == 2 then
			meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693331/C0DEFCF73A79541D4756A93BBF4B8E922982F429/" -- mesh infantry close columns
		elseif formationVal == 4 then
			meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693356/0D82CF6ED5B1B76EEF16C340F01B6838BC5BECB3/"
		end
		
		if unitSize < -1 then formScale = {0.64, 1, 1}
		elseif unitSize == -1 then formScale = {0.8, 1, 1}
		elseif unitSize > 0 then formScale = {1.25, 1, 1}
		end

	-- CAVALRY --
	elseif unitScript == 2 then
		if faction == "red" then
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cavalry-red.png"
			imgUrlRider = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_rider-red.png"
			if unitType == 1 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-red-hussar.png" -- red hussars
			elseif unitType == 2 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-red-dragoon.png" -- red dragoons
			elseif unitType == 3 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-red-lancer.png" -- red lancers
			elseif unitType == 4 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-red-cuirassier.png" -- red cuirassiers
			end
		else 
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cavalry-blue.png"
			imgUrlRider = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_rider-blue.png"
			if unitType == 1 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-blue-hussar.png" -- blue hussars
			elseif unitType == 2 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-blue-dragoon.png" -- blue dragoons
			elseif unitType == 3 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-blue-lancer.png" -- blue lancers
			elseif unitType == 4 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_cav-blue-cuirassier.png" -- blue cuirassiers
			end
		end
		if formationVal == 2 then
			if strVal > str_med then
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2403326468915464363/2FBFCF70F18CD4DAB53A66CDB856A505606CF92D/" -- mesh cavalry ranks full
			else
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2403326468915464384/EE65186B36AEBDB572D517522EBCD26B5F548BFE/" -- mesh cavalry ranks half
			end
			formPosOffset = Vector(0,0,8)
		elseif formationVal == 3 then
			if unitSize >= 0 then
				meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/obj/squadron_columnF.obj" -- mesh cavalry open column full
				formPosOffset = Vector(0,0,40)
			else
				meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/obj/squadron_columnF-half.obj" -- mesh cavalry open column half
				formPosOffset = Vector(0,0,20)
			end		
		end	

	-- ARTILLERY --
	elseif unitScript == 3 then
		imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_artillery.png"
		meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2458494928524557226/2DEA1DEA81B2888FB3018EB1B1CE83AB27A6BC57/" -- Unlimbered Artillery
		if formationVal == 3 then
			meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/obj/guns_limbered-reverse.obj" -- Limbered Artillery
		elseif formationVal == 4 then
			meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2458494928524555366/B831637B713DE74870220D2EACD8CEBE99E540ED/" -- Defeated Artillery
		end
	end
end

function setFormation()
	-- print("Starting setFormation...")
	-- printDebug()

	updateUnitData()
	self.destroyAttachments()
	checkAdvance()
	
	myColorTint = self.getColorTint()

	self.setScale(unitScale)

	paramsFormation = {
		type = "Custom_Model",
		position		= self.positionToWorld(Vector(0, 0.01, 0)+formPosOffset),
		rotation		= self.getRotation(),   -- flat, face-up
		scale			= Vector(1.45, 1, 1.45),
		snap_to_grid	= false
	}

	formationModel = spawnObject(paramsFormation)
	
	formationData = {
		mesh = meshUrl,
		diffuse = imgUrl,
		material = 3,
	}
	
	formationModel.setCustomObject(formationData)
	formationModel.scale(formScale)
	formationModel.setColorTint(myColorTint)
	self.addAttachment(formationModel)

	-- UNIT TYPE MARKER
	if unitScript == 2 then
		unitData = {
			image = img2Url,
			thickness = 0.02,
		}
	
		paramsUnit = {
			type = "Custom_Tile",
			position		= self.positionToWorld(Vector(0, 0.1, 25)), -- float just above tile
			rotation		= self.getRotation() + Vector(0, 0, 0),   -- flat, face-up
			scale			= Vector(0.2, 1, 0.2),
			snap_to_grid	= false,
		}

		UnitModel = spawnObject(paramsUnit)
		UnitModel.setCustomObject(unitData)
		UnitModel.setColorTint(myColorTint)
		self.addAttachment(UnitModel)
	end

	-- print("Finished setFormation.")
	-- printDebug()
end

function clickCohesion(obj, color, alt_click)
	cohesionLast = cohesion
	if not alt_click then cohesion=cohesion-1 else cohesion=cohesion+1 end

	if cohesion < cohesionMIN then cohesion=cohesionMIN
	elseif cohesion > cohesionMAX then cohesion=cohesionMAX
	end
	
	print(name .. " from " .. cohesionLast .. " to " .. cohesion)
	
	setCohesion()
end

function setCohesion()
	if cohesion == 3 then
		self.editButton({index = 1, label = cohesionLabel3, font_color = cohesionColor3, tooltip = cohesionTooltip3})
	elseif cohesion == 2 then
		self.editButton({index = 1, label = cohesionLabel2, font_color = cohesionColor2, tooltip = cohesionTooltip2})
	elseif cohesion == 1 then
		self.editButton({index = 1, label = cohesionLabel1, font_color = cohesionColor1, tooltip = cohesionTooltip1})
	elseif cohesion == 0 then
		self.editButton({index = 1, label = cohesionLabel0, font_color = cohesionColor0, tooltip = cohesionTooltip0})
	else print("Cohesion value is fucked up")
	end
end

-- function unitReduce(objToScale)
	-- objToScale.scale({0.8, 1, 1})
-- end

-- function unitIncrease()
	-- objToScale.scale({1.25, 1, 1})
-- end

function strButton(alt_click)
	if alt_click then strUp() else strDown() end
end

function strUp()
	strInc(1)
end

function strDown()
	strInc(-1)
end

function strInc(val)
	strValLast = strVal
	strVal=strVal+val
	strUpdate()
	print(name .. " Strength: " .. strValLast .. ">" .. strVal)
end

function strUpdate()
	if strVal < str_MIN then strVal = str_MIN
	elseif strVal > str_MAX then strVal = str_MAX end
	
	unitSize = 0
	if strVal <= str_sml then unitSize = -2
	elseif strVal <= str_med then unitSize = -1
	elseif strVal > str_big then unitSize = 1 end
	
	self.editButton({index=2, label=strVal})
	setFormation()
end

function spawnSmoke() --spawns smoke token
	if not unitScript == 3 then
		local myPosition = tokenPosition()
	else
		local myPosition = tokenPosition()+Vector(0,0,2)
	end
	local myRotation = self.getRotation()
	params1 = {
	  type = 'Custom_Token',
	  position          = myPosition,
	  rotation          = myRotation,
	  scale             = {x=0.28, y=1, z=0.28},
	  snap_to_grid      = false,
	}
	object = spawnObject(params1)
	
	if unitScript == 3 then
		imgSmoke = "https://steamusercontent-a.akamaihd.net/ugc/2458494928525602813/A3F95BBF84FA2EB974D86AEEC015BAF04EA2875F/"
	else
		imgSmoke = "https://steamusercontent-a.akamaihd.net/ugc/1481075842950556808/2DE0FF15A0E6E6BFF9D51A3743309F97A030D5E3/"
	end

	params2 = {
	  image = imgSmoke,
	  thickness = 0.1,
	}
	object.setCustomObject(params2)
end

function spawnSkirmisher() --spawns skirmisher
	local myPosition = tokenPosition()
	local myRotation = self.getRotation()
	local myColorTint = self.getColorTint()
	local params1 = {
		type = 'Custom_Model',
		position          = myPosition,
		rotation          = myRotation,
		scale             = Vector(0.75, 1, 0.75),
		snap_to_grid      = false,
	}
	object = spawnObject(params1)
	
	if faction == "red" then
		local imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_inf-red.png"
	else
		local imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/img/img_inf-blue.png"
	end
	
    paramsSkirmisher = {
		mesh = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/D6KS/units/obj/skirmisher-zug2.obj",
		diffuse = imgUrl,
		material = 3,
    }
	object.setCustomObject(paramsSkirmisher)
	object.setName(name)
	object.addTag("D6KS Skirmisher")
    -- object.setLuaScript(unitLUA)
    -- object.reload()
	-- object.setColorTint(myColorTint)
end

function spawnRider() --spawn rider
	local myPosition = tokenPosition()
	local myRotation = self.getRotation()
	local myColorTint = self.getColorTint()
	spawnparams = {
	  type = 'Custom_Tile',
	  position          = myPosition,
	  rotation          = myRotation,
	  colortint         = myColorTint,
	  scale             = Vector(0.1, 1, 0.1),
	  snap_to_grid      = false,
	}
	object = spawnObject(spawnparams)

	params = {
	  image = imgUrlRider,
	  thickness = 0.1,
	}
	object.setName(name)
	-- object.setColorTint(myColorTint)
	object.setCustomObject(params)
end

function changeFaction()
	if faction == "red" then faction = "blue" else faction = "red" end
	setFormation()
end

function changeUnitType()
	if unitType < unitTypeCount then unitType=unitType+1 else unitType=1 end
	setFormation()
end

function updateContextMenu()
	clearContextMenu()
	if unitScript == 1 then 
		self.addContextMenuItem("Gun Smoke", spawnSmoke, true)
		self.addContextMenuItem(">Battle Line", setLine, true)
		self.addContextMenuItem(">Attack Column", setAttack, true)
		self.addContextMenuItem(">Open Column", setMarch, true)
		self.addContextMenuItem(">Square", setSquare, true)
		self.addContextMenuItem(">Detach Skirmishers", spawnSkirmisher, true)
	elseif unitScript == 2 then
		self.addContextMenuItem(">Attack Ranks", setAttack, true)
		self.addContextMenuItem(">Open Column", setMarch, true)
		self.addContextMenuItem(">Detach Rider", spawnRider, true)
		if unitType == 2 then self.addContextMenuItem(">Detach Skirmishers", spawnSkirmisher, true) end
	elseif unitScript == 3 then
		self.addContextMenuItem("Gun Smoke", spawnSmoke, true)
        self.addContextMenuItem(">Unlimbered", setUnlimbered, true)
        self.addContextMenuItem(">Limbered", setLimbered, true)
        self.addContextMenuItem(">Defeated!", setDefeated, true)
        self.addContextMenuItem("Toggle Rangefinder", toggleRange, true)
	end
	self.addContextMenuItem("+ Strength", strUp, true)
	self.addContextMenuItem("- Strength", strDown, true)
	if unitScript == 2 then
		self.addContextMenuItem("Cavalry Type", changeUnitType, true)
	end
	self.addContextMenuItem("Change Faction", changeFaction, true)
end

function toggleRange()
  if visible == nil then visible = false end
	if visible == false then
	  color_1 = {0, 1, 0, 1}
	  color_2 = {1, 1, 0, 1}
	  color_3 = {1, 0, 0, 1}
	  visible = true
	  print("Range Finder ON")
	elseif visible == true then
	  color_1 = {0, 1, 0, 0}
	  color_2 = {1, 1, 0, 0}
	  color_3 = {1, 0, 0, 0}
	  visible = false
	  print("Range Finder OFF")
  end
  createMultipleArcs()
end

function createMultipleArcs()
	-- Define parameters for each arc
	local arc1 = { color = color_1, radius = 6.2, steps = 32, thickness = 0.15, vertical_position = 0.2, startAngle = 247.5, endAngle = 292.5 }
	local arc2 = { color = color_2, radius = 14.6, steps = 32, thickness = 0.15, vertical_position = 0.2, startAngle = 247.5, endAngle = 292.5 }
	local arc3 = { color = color_3, radius = 28.75, steps = 32, thickness = 0.15, vertical_position = 0.2, startAngle = 247.5, endAngle = 292.5 }

	-- Create vector lines for each arc
	self.setVectorLines({
		{
			points    = getArcVectorPoints(arc1.radius, arc1.steps, arc1.vertical_position, arc1.startAngle, arc1.endAngle),
			color     = arc1.color,
			thickness = arc1.thickness,
			rotation  = {0, 0, 0},
		},
		{
			points    = getArcVectorPoints(arc2.radius, arc2.steps, arc2.vertical_position, arc2.startAngle, arc2.endAngle),
			color     = arc2.color,
			thickness = arc2.thickness,
			rotation  = {0, 0, 0},
		},
		{
			points    = getArcVectorPoints(arc3.radius, arc3.steps, arc3.vertical_position, arc3.startAngle, arc3.endAngle),
			color     = arc3.color,
			thickness = arc3.thickness,
			rotation  = {0, 0, 0},
		}
	})
end

function getArcVectorPoints(radius, steps, y, startAngle, endAngle)
	local points = {}
	local angleStep = (endAngle - startAngle) / steps
	for i = 0, steps do
		local angle = startAngle + angleStep * i
		local x = math.cos(math.rad(angle)) * radius
		local z = math.sin(math.rad(angle)) * radius
		table.insert(points, {x, y, z})
	end
	return points
end

function tokenPosition()
  local x = 0
  local y = -0.25
  local z = -14
  return self.positionToWorld({x,y,z})
end

function updateCheck()
	-- update name
	name = self.getName()
	self.editButton({index=0, label=name})
end

function nullFunction()
--does nothing
end
]]

function loadUnitScript(obj)
	if obj == nil then return end
    obj.setLuaScript(unitLUA)
    obj.reload()  -- reloads the script so onLoad runs immediately
end