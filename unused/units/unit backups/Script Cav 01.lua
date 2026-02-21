-----------------------------------------------------------------------------------
---adjust these values to set labels, and minimum/maximum values on the counters---
-----------------------------------------------------------------------------------
nameColor = 'White' --what color do you want the piece Name to be?

unitScale = self.getScale()

createCounter3 = true
counter3 = "Strength" --what you want to track on Counter #3
ctr3Color = 'White' --what color do you want the counter text to be?
ctr3MIN = 0 --minimum amount allowed for Counter #3
ctr3MAX = 12 --maximum amount allowed for Counter #3
--### or you might end up with undesired results ----------------------------------
STR_sml = 3 --maximum value for a small block
STR_med = 5 --maximum value for a medium block
STR_big = 10 --maximum value for an oversized block

advancing = false

createCohesion = true
cohesion = 3
cohesionMIN = 0
cohesionMAX = 3
cohesionTooltip3 = "Orderly"
cohesionTooltip2 = "Disordered"
cohesionTooltip1 = "Fixed"
cohesionTooltip0 = "BROKEN"
cohesionLabel3 = "..."
cohesionLabel2 = ".."
cohesionLabel1 = "x"
cohesionLabel0 = "BROKEN"
cohesionColor3 = {255, 255, 255, 127}
cohesionColor2 = {255, 255, 0, 127}
cohesionColor1 = {255, 0, 0, 127}
cohesionColor0 = {255, 0, 0, 127}

faction = "red"
unitType = 1
unitTypeCount = 4

meshURL = nil
formationVal = 1

name = "Unit Name"
ctr1 = '0'
ctr2 = '0'
ctr3 = '1'

---------------------------------------------------------------------------
---don't mess with this section---
---------------------------------------------------------------------------
function onSave() --We make a table of data we want to save. WE CAN ONLY SAVE 1 TABLE.
    local data_to_save = {
		name=name,
		ctr3=ctr3,
		formationVal=formationVal,
		cohesion=cohesion,
		advancing=advancing,
		faction=faction,
		unitType=unitType,}
    --We use this command to convert the table into a string
    saved_data = JSON.encode(data_to_save)
    --And this inserts the string into the save information for this script.
    return saved_data
    --Data is now saved.
end

function onload(saved_data) --Runs when the map is first loaded
    if saved_data ~= "" then --First we check if there was information saved in this script yet
        local loaded_data = JSON.decode(saved_data) --If there is save data, we convert the string back to a table, and pull the data out
        name = loaded_data.name
        ctr3 = loaded_data.ctr3
        formationVal = loaded_data.formationVal
        cohesion = loaded_data.cohesion
		advancing = loaded_data.advancing
		faction = loaded_data.faction
		unitType = loaded_data.unitType
    end

	--add the context menu items
	self.addContextMenuItem(">In Ranks", setAttack, true)
	self.addContextMenuItem(">In Column", setColumn, true)
	self.addContextMenuItem(">Detach Rider", spawnRider, true)
	self.addContextMenuItem("+ Strength", ctr3Up, true)
	self.addContextMenuItem("- Strength", ctr3Down, true)
	self.addContextMenuItem("Change Faction", changeFaction, true)
	self.addContextMenuItem("Cavalry Type", changeUnitType, true)

	
	if unitType == nil then unitType = 1 end
	if formationVal == nil then formationVal = 1 end
	
	CreateButtons()
	setFormation()
	setCohesion()
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
if createCohesion then
	self.createButton({click_function = "clickCohesion", function_owner = self,
	  label = cohesionLabel3, position = {0, 0.26, 15}, rotation = {0, 0, 0}, scale = {25, 25, 25}, width = 180,
	  height = 110, font_size = 150, color = {0,0,0,0}, font_color = cohesionColor3, tooltip = cohesionTooltip3})
end

-- Unit Name input box
-- self.createInput({value = name, input_function = "editName", label = "Unit", function_owner = self,
    -- alignment = 3, position = {0, -0.05, -10}, rotation = {0, 0, 180}, width = 400, height = 110,
    -- font_size = 70, scale={x=15, y=15, z=15}, font_color= {1,1,1,1}, color = {0.1,0.1,0.1,1}})

--Strength Counter on the back
if createCounter3 then
	self.createButton({index = 2, click_function = "ctr3Button", function_owner = self,
	  label = ctr3, position = {0, -0.05, 20}, rotation = {0, 0, 180}, scale = {25, 25, 25}, width = 180,
	  height = 160, font_size = 160, font_color = ctr3Color, color = {0, 0, 0}, tooltip = counter3})
end

formHalt = {index = 3, click_function = "nullFunction", function_owner = self, label = "", position = {1, 0.25, 0.25},	rotation = {0, 0, 0}, scale = {2, 2, 2}, width = 0, height = 0, font_size = 160, font_color = {1, 1, 1, 1}}

formAttack = {index = 3, click_function = "nullFunction", function_owner = self, label = "↑A↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {45, 1, 45}, width = 0, height = 0, font_size = 200, font_color = {1,0,0,1}, color = {0,0,0,1}}

formAdvance = {index = 3, click_function = "nullFunction", function_owner = self, label = "↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}

self.createButton(formHalt)

end --end button creation

-----------------
--- functions ---
-----------------

function printDebug()
	print("formationVal = "..formationVal)
	print("FormationOverlay = " .. (FormationModel and 'true' or 'false'))
	print("faction = " .. faction)
	print("unitType = " .. unitType)
	print("----------")
end

function toggleAdvance()
	advancing = not advancing
end

function changeDirection()
	direction = 1-direction
end

function setAttack()
	if formationVal == 1 then toggleAdvance() end
	formationVal = 1
	setFormation()
end

function setColumn()
	if formationVal == 3 then toggleAdvance() end
	formationVal = 3
	setFormation()
end

function changeFaction()
	if faction == "red" then faction = "blue" else faction = "red" end
	setFormation()
end

function changeUnitType()
	if unitType < unitTypeCount then unitType=unitType+1 else unitType=1 end
	setFormation()
end

function setFormation()
	-- print("Starting setFormation...")
	-- printDebug()
	self.destroyAttachments()
	self.editButton(formHalt)
	
	myColorTint = self.getColorTint()

	-- FORMATION MODEL
	if formationVal == 1 then -- Ranks
		posFormation = Vector(0, 0.01, 8)
		if ctr3 > STR_med then
			meshURL = "https://steamusercontent-a.akamaihd.net/ugc/2403326468915464363/2FBFCF70F18CD4DAB53A66CDB856A505606CF92D/" --Ranks, Full
		else
			meshURL = "https://steamusercontent-a.akamaihd.net/ugc/2403326468915464384/EE65186B36AEBDB572D517522EBCD26B5F548BFE/" -- Ranks, Half
		end
		if advancing then self.editButton(formAttack) end
	elseif formationVal == 3 then
		if ctr3 > STR_med then
			meshURL = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/obj/squadron_columnF.obj" -- Column, Full
			posFormation = Vector(0, 0.01, 40)
		else
			meshURL = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/obj/squadron_columnF-half.obj" -- Column, Half
			posFormation = Vector(0, 0.01, 20)
		end
		
		paramsFormation = {
			type = "Custom_Model",
			position		= self.positionToWorld(posFormation), -- float just above tile
			rotation		= Vector(self.getRotation()) + Vector(0, 0, 0),   -- flat, face-up
			scale			= Vector(1.45, 1, 1.45),
			snap_to_grid	= false
		}
		
		if advancing then self.editButton(formAdvance) end
	end
	
	paramsFormation = {
		type = "Custom_Model",
		position		= self.positionToWorld(posFormation), -- float just above tile
		rotation		= Vector(self.getRotation()) + Vector(0, 0, 0),   -- flat, face-up
		scale			= Vector(1.45, 1, 1.45),
		snap_to_grid	= false
	}
	
	if faction == "red" then
		formationData = {
			mesh = meshURL,
			diffuse = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cavalry-red.png",
			material = 3,
		}
		if unitType == 1 then -- Hussar
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-red-hussar.png",
				thickness = 0.02,
			}
		elseif unitType == 2 then -- Dragoon
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-red-dragoon.png",
				thickness = 0.02,
			}
		elseif unitType == 3 then -- Lancer
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-red-lancer.png",
				thickness = 0.02,
			}
		else --Cuirassier
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-red-cuirassier.png",
				thickness = 0.02,
			}
		end
	elseif faction == "blue" then
		formationData = {
			mesh = meshURL,
			diffuse = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cavalry-blue.png",
			material = 3,
		}
		if unitType == 1 then -- Hussar
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-blue-hussar.png",
				thickness = 0.02,
			}
		elseif unitType == 2 then -- Dragoon
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-blue-dragoon.png",
				thickness = 0.02,
			}
		elseif unitType == 3 then -- Lancer
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-blue-lancer.png",
				thickness = 0.02,
			}
		else --Cuirassier
			unitData = {
				image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-blue-cuirassier.png",
				thickness = 0.02,
			}
		end
	else
		formationData = {
			mesh = meshURL,
			diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2458494293773387012/6C5FDECF7BF2AADC1510364D77AF69D2AFF4AE5A/",
			material = 3,
		}
		unitData = {
			image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_cav-red-hussar.png",
			thickness = 0.02,
		}
	end
	
	FormationModel = spawnObject(paramsFormation)
	FormationModel.setCustomObject(formationData)
	FormationModel.setColorTint(myColorTint)
	self.addAttachment(FormationModel)

	editName()
	
	-- UNIT TYPE MARKER
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

	-- print("Finished setFormation.")
	-- printDebug()
end

function clickCohesion(obj, color, alt_click)	
	if not alt_click then cohesion=cohesion-1 else cohesion=cohesion+1 end

	if cohesion < cohesionMIN then cohesion=cohesionMIN
	elseif cohesion > cohesionMAX then cohesion=cohesionMAX
	end
	
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

function editName(_obj, _string, value)
    name = self.getName(),
    self.editButton({index=0, label=name})
end

function unitReduce()
	self.scale({0.8, 1, 1})
end

function unitIncrease()
	self.scale({1.25, 1, 1})
end

function checkFrontage()
	if unitScript ~= 1 then return
	self.setScale(unitScale)
	if ctr3 <= STR_sml then unitReduce() end
	if ctr3 <= STR_med then unitReduce() end
	if ctr3 > STR_big then unitIncrease() end
end

function ctr3Down()
	ctr3=ctr3-1
	ctr3Update()
end

function ctr3Up()
	ctr3=ctr3+1
	ctr3Update()
end

function ctr3Button(alt_click)
	if not alt_click then ctr3down() else ctr3up() end
end

function ctr3Update()
	if ctr3 < ctr3MIN then ctr3 = ctr3MIN
	elseif ctr3 > ctr3MAX then ctr3 = ctr3MAX end
	print(name .. " Strength = " .. ctr3)
	self.editButton({index=2, label=ctr3})
	setFormation()
	-- checkFrontage()
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
	if faction == "red" then
		params = {
		  image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_rider-red.png",
		  thickness = 0.1,
		}
	else
		params = {
		  image = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_rider-blue.png",
		  thickness = 0.1,
		}
	end
	object.setName(name)
	-- object.setColorTint(myColorTint)
	object.setCustomObject(params)
end

function spawnSmoke() --spawns smoke token
	local myPosition = tokenPosition()
	local myRotation = self.getRotation()
	params1 = {
	  type = 'Custom_Token',
	  position          = myPosition,
	  rotation          = myRotation,
	  scale             = {x=0.28, y=1, z=0.28},
	  snap_to_grid      = false,
	}
	object = spawnObject(params1)
	params2 = {
	  image = "https://steamusercontent-a.akamaihd.net/ugc/1481075842950556808/2DE0FF15A0E6E6BFF9D51A3743309F97A030D5E3/",
	  thickness = 0.1,
	}
	object.setCustomObject(params2)
end

function tokenPosition()
  local x = 0
  local y = -0.25
  local z = -14
  return self.positionToWorld({x,y,z})
end

function nullFunction()
--does nothing
end