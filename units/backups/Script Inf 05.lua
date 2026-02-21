-----------------------------------------------------------------------------------
---adjust these values to set labels, and minimum/maximum values on the counters---
-----------------------------------------------------------------------------------
nameColor = 'White' --what color do you want the piece Name to be?

unitScale = self.getScale()

createCounter3 = true
counter3 = "Strength" --what you want to track on Counter #3
ctr3Color = 'White' --what color do you want the counter text to be?
ctr3MIN = 0 --minimum amount allowed for Counter #3
ctr3MAX = 25 --maximum amount allowed for Counter #3
--### or you might end up with undesired results ----------------------------------
STR_sml = 6 --maximum value for a small block
STR_med = 12 --maximum value for a medium block
STR_big = 20 --maximum value for an oversized block

direction = 0 --left = 0, right = 1
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

meshURL = nil
formationVal = 1

name = "Unit Name"
ctr1 = '0'
ctr2 = '0'
ctr3 = '20'

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
	} --We use this command to convert the table into a string
    saved_data = JSON.encode(data_to_save) --And this inserts the string into the save information for this script.
    return saved_data --Data is now saved.
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
    end

	--add the context menu items
	self.addContextMenuItem("Gun Smoke", spawnSmoke, true)
	self.addContextMenuItem(">Battle Line", setLine, true)
	self.addContextMenuItem(">Attack Column", setAttack, true)
	self.addContextMenuItem(">Marching Column", setMarching, true)
	self.addContextMenuItem(">Square", setSquare, true)
	self.addContextMenuItem(">Detach Skirmishers", spawnSkirmisher, true)
	self.addContextMenuItem("+ Strength", ctr3Up, true)
	self.addContextMenuItem("- Strength", ctr3Down, true)
	self.addContextMenuItem("Change Faction", changeFaction, true)

	if formationVal == nil then formationVal = 1 end
	
	CreateButtons()
	setFormation()
	setCohesion()
	checkFrontage()
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
	  label = cohesionLabel3, position = {0, 0.26, 20}, rotation = {0, 0, 0}, scale = {25, 25, 25}, width = 180,
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

formAdvanceR = {index = 3, click_function = "nullFunction", function_owner = self, label = "                                      →", position = {0, 0.1, 5}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}
formAdvanceL = {index = 3, click_function = "nullFunction", function_owner = self, label = "←                                      ", position = {0, 0.1, 5}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}
formAdvance = formAdvanceR

formAttack = {index = 3, click_function = "nullFunction", function_owner = self, label = "↑A↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {45, 1, 45}, width = 0, height = 0, font_size = 200, font_color = {1,0,0,1}, color = {0,0,0,1}}

self.createButton(formHalt)

end --end button creation

-----------------
--- functions ---
-----------------

function printDebug()
	print("formationVal = "..formationVal)
	print("FormationOverlay = " .. (FormationModel and 'true' or 'false'))
	print("----------")
end

function toggleAdvance()
	advancing = not advancing
end

function changeDirection()
	direction = 1-direction
end

function setLine()
	if formationVal == 1 then toggleAdvance() end
	formationVal = 1
	setFormation()
end

function setAttack()
	if formationVal == 2 then toggleAdvance() end
	formationVal = 2
	setFormation()
end

function setMarching()
	if not advancing then formAdvance = formAdvanceR else formAdvance = formAdvanceL end
	if formationVal == 3 then toggleAdvance() end
	formationVal = 3
	setFormation()
end

function setSquare()
	advancing = false
	formationVal = 4
	setFormation()
end

function changeFaction()
	if faction == "red" then faction = "blue" else faction = "red" end
	setFormation()
end

function setFormation()
	-- print("Starting setFormation...")
	-- printDebug()
	self.destroyAttachments()
	self.editButton(formHalt)
	
	myColorTint = self.getColorTint()

	paramsFormation = {
		type = "Custom_Model",
		position		= self.positionToWorld(Vector(0, 0.01, 0)), -- float just above tile
		rotation		= self.getRotation() + Vector(0, 0, 0),   -- flat, face-up
		scale			= Vector(1.45, 1, 1.45),
		snap_to_grid	= false
	}

	if formationVal == 1 then -- Battle Line
		meshURL = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693391/0943345DA6F3BD247B7073EF24B54579EA3126F0/"
		if advancing then self.editButton(formAttack) end
	elseif formationVal == 2 then -- Attack Column
		meshURL = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693331/C0DEFCF73A79541D4756A93BBF4B8E922982F429/"
		if advancing then self.editButton(formAttack) end
	elseif formationVal == 3 then -- Marching Column
		meshURL = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693391/0943345DA6F3BD247B7073EF24B54579EA3126F0/"
		if advancing then self.editButton(formAdvance) end
	elseif formationVal == 4 then -- Square
		meshURL = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693356/0D82CF6ED5B1B76EEF16C340F01B6838BC5BECB3/"
	end

	FormationModel = spawnObject(paramsFormation)
	
	if faction == "red" then
		formationData = {
			mesh = meshURL,
			diffuse = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_inf-red.png",
			material = 3,
		}
	elseif faction == "blue" then
		formationData = {
			mesh = meshURL,
			diffuse = "file:///T:/Games/StrategyGames/Kriegsspiel/Assets/units/img/img_inf-blue.png",
			material = 3,
		}
	elseif faction == "white" then
		formationData = {
			mesh = meshURL,
			diffuse = "https://steamusercontent-a.akamaihd.net/ugc/2452864250438903222/C38DE48E7A7E348C6BF49F1D44168150F789E36B/",
			material = 3,
		}
	end
	
	FormationModel.setCustomObject(formationData)
	FormationModel.setColorTint(myColorTint)
	self.addAttachment(FormationModel)

	editName()

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
	print("Strength = " .. ctr3)
	self.editButton({index=2, label=ctr3})
	checkFrontage()
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
    paramsSkirmisher = {
		mesh = "https://steamusercontent-a.akamaihd.net/ugc/11918420978341380/CD5B3972295FF47DC14A66D1AD15A4DB88F90841/",
		diffuse = "https://steamusercontent-a.akamaihd.net/ugc/11917605550997817/FB8A12C82608DA5A09CF2911CC4BCDE20E45544C/",
		material = 3,
    }
	object.setCustomObject(paramsSkirmisher)
	object.setName(name)
	-- object.setColorTint(myColorTint)
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