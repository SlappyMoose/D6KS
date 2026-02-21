--------------------------------------------------------------
--- script by SlappyMoose, for his "D6 Kriegsspiel" system ---
--------------------------------------------------------------
-- copy paste all this code into the table's Global LUA
-- tag all units with "D6KS Shared Script", and "D6KS Infantry" (or Cavalry or Artillery)
function onLoad()
	print("Loading D6KS...")
	spawnFaction = nil
	loadSharedScripts()
	print("D6KS loaded.")
end

function loadSharedScripts()
	for _, obj in ipairs(getAllObjects()) do
		if obj.hasTag("D6KS Infantry") or obj.hasTag("D6KS Cavalry") or obj.hasTag("D6KS Artillery") or obj.hasTag("D6KS Skirmisher") then
			loadUnitScript(obj)
		end
	end
	print("Finished loadSharedScripts.")
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
		str=str,
		formationVal=formationVal,
		cohesion=cohesion,
		stamina=stamina,
		fatigue=fatigue,
		advancing=advancing,
		direction=direction,
		hasTurned=hasTurned,
		faction=faction,
		unitType=unitType,
		cavType=cavType,
		artType=artType,
		veterancy=veterancy,
	} --We use this command to convert the table into a string
	saved_data = JSON.encode(data_to_save) --And this inserts the string into the save information for this script.
	return saved_data --Data is now saved.
end

function onload(saved_data)
	loadDefaults()
	if saved_data ~= "" then --First we check if there was information saved in this script yet
		local loaded_data = JSON.decode(saved_data) --If there is save data, we convert the string back to a table, and pull the data out
		str = loaded_data.str
		formationVal = loaded_data.formationVal
		cohesion = loaded_data.cohesion
		stamina = loaded_data.stamina
		fatigue = loaded_data.fatigue
		advancing = loaded_data.advancing
		direction = loaded_data.direction
		hasTurned = loaded_data.hasTurned
		faction = loaded_data.faction
		unitType = loaded_data.unitType
		artType = loaded_data.artType
		veterancy = loaded_data.veterancy
	end

	varFix()
	updateContextMenu()
	CreateButtons()
	setState()
	-- printDebug()

	Wait.time(updateCheck, 5, -1) -- call every 5 seconds
end

function setState()
	setVeterancy()
	setStrength()
	setFormation()
	setCohesion()
	setFatigue()
end

function loadDefaults()
	name = self.getName()

	strTooltip = "Strength"
	strMIN = 0 --minimum amount allowed
	unitSize = 0 -- 0 = full, -1 = reduced, -2 = depleted, 1 = over strength
	strPos = {0, 0.26, 20}
	strWidth = 250
	strSize = 100

	direction = 0 --left = 0, right = 1
	advancing = false
	hasTurned = false
	cohesion = 2
	cohesionMIN = -1
	cohesionMAX = 2
	cohesionTooltip2 = "Cohesive"
	cohesionTooltip1 = "Disordered"
	cohesionTooltip0 = "BROKEN"
	cohesionTooltipNeg = "SHATTERED"
	cohesionLabel2 = "⬛"
	cohesionLabel1 = "⬛"
	cohesionLabel0 = "⬜"
	cohesionLabelNeg = "⬚"
	cohesionPos = {-14, 0.26, 20}

	statScaleNormal = {25, 25, 25}
	statScaleBig = {35, 35, 35}
	stamina = 2
	staminaMIN = 0
	staminaMAXBase = 2
	staminaMAX = staminaMAXBase
	fatigue = 3
	fatigueMIN = 0
	fatigueMAXBase = 3
	fatigueMAX = fatigueMAXBase
	ballLabelXof1 = {"○", "●"}
	ballLabelXof2 = {"○○", "○●", "●●"}
	ballLabelXof3 = {"○○○", "○○●", "○●●", "●●●"}
	ballLabelXof4 = {"○○○○", "○○○●", "○○●●", "○●●●", "●●●●"}
	staminaPos = {16, 0.26, 20}
	fatiguePos = {28, 0.26, 20}
	fatigueTooltips = {"Exhausted", "Tired", "Fresh"}
	urlBallFull = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_full.png"
	urlBall5of6 = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_5of6.png"
	urlBall4of6 = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_4of6.png"
	urlBallHalf = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_half.png"
	urlBall2of6 = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_2of6.png"
	urlBall1of6 = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_1of6.png"
	urlBallEmpty = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/indicators/ball_empty.png"
	
	if unitScript == 1 then --inf
		strLabels = {"◇◇◇\n◇◇◇", "◇◇◇\n◇◇⬗", "◇◇◇\n◇◇◆", "◇◇◇\n◇⬗◆", "◇◇◇\n◇◆◆", "◇◇◇\n⬗◆◆", "◇◇◇\n◆◆◆", "◇◇⬗\n◆◆◆", "◇◇◆\n◆◆◆", "◇⬗◆\n◆◆◆", "◇◆◆\n◆◆◆", "⬗◆◆\n◆◆◆", "◆◆◆\n◆◆◆"}
		strMAX = 12
		str_sml = 0 --maximum value for a small block
		str_med = 6 --maximum value for a medium block
		str_big = 12 --maximum value for an oversized block
	elseif unitScript == 2 then --cav
		strLabels = {"◇◇◇", "◇◇◆", "◇◆◆", "◆◆◆"}
		strMAX = 6
		str_sml = 0 --maximum value for a small block
		str_med = 2 --maximum value for a medium block
		str_big = 6 --maximum value for an oversized block
		staminaMAXBase = 1
		fatigueMAXBase = 2
	elseif unitScript == 3 then --art
		strMAX = 8
		strLabels = {"◇◇◇◇", "◇◇◇⬗", "◇◇◇◆", "◇◇⬗◆", "◇◇◆◆", "◇⬗◆◆", "◇◆◆◆", "⬗◆◆◆", "◆◆◆◆"}
		str_sml = 2 --maximum value for a small block
		str_med = 4 --maximum value for a medium block
		str_big = 8 --maximum value for an oversized block
	elseif unitScript == 4 then --skrm
		strMAX = 6
		strLabel3 = "◆◆◆"
		strLabel2 = "◇◆◆"
		strLabel1 = "◇◇◆"
		strLabel0 = "◇◇◇"
		str_sml = 0 --maximum value for a small block
		str_med = 2 --maximum value for a medium block
		str_big = 6 --maximum value for an oversized block
		strPos = {5, 0.26, 16}
		strSize = 70
		cohesionPos = {-8, 0.26, 16}
	end

	rgbOpacity = 50
	rgbWhite = {255, 255, 255, rgbOpacity} --127 alpha is "normal"
	rgbYellow = {255, 255, 0, rgbOpacity}
	rgbOrange = {255, 65, 0, 127} --same as Yellow
	rgbRed = {255, 0, 0, rgbOpacity}
	rgbGreen = {0, 255, 0, rgbOpacity}
	rgbBlue = {0, 255, 255, rgbOpacity}
	rgbGrey = {120, 120, 120, rgbOpacity}
	colorStrength = rgbWhite
	colorCohesion2 = rgbWhite
	colorCohesion1 = rgbYellow
	colorCohesion0 = rgbYellow
	colorCohesionNeg = rgbRed
	staminaColor = rgbGreen
	fatigueColor = rgbBlue

	nameColor = 'White' --what color do you want the piece Name to be?
	spawnFaction = Global.getVar("spawnFaction")
	if spawnFaction ~= nil then faction = spawnFaction end
	cavType = 1 -- 1 = hussar, 2 = dragoons, 3 = lancer, 4 = cuirassier
	cavTypeCount = 4
	artType = 1 -- 1 = foot, 2 = horse
	artTypeCount = 2

	veterancyMIN = 1
	veterancyMAX = 3
	veterancy = 2

	formationVal = 1
	baseScale = {0.03, 1, 0.03}
	baseUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/base-square.jpg"
	unitScale = self.getScale()
	meshUrl = nil
end

function varFix()
	if str == nil then str = strMAX end
	if unitType == nil then unitType = 1 end
	if formationVal == nil then formationVal = 1 end
	
	if cohesion == nil then cohesion = 2 end
	
	cohesion = math.max(math.min(cohesion, cohesionMAX), cohesionMIN)

	if stamina == nil then stamina = 2 end
	if fatigue == nil then fatigue = 3 end
	fatigue = math.max(math.min(fatigue, fatigueMAX), fatigueMIN)
	
	if veterancy == nil then veterancy = 2 end
	
	-- limit formation range to unit
	if unitScript == 2 then
		formationVal = math.max(math.min(formationVal, 3), 2)
	elseif unitScript == 3 then
		formationVal = math.min(formationVal, 4)
	end
end

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------

function CreateButtons()
----------------------------------
----- front/counter displays -----
----------------------------------

--Unit Name front display (index 0)
nameScale = {25,25,25}
nameScaleSkrm = {15,15,15}
self.createButton({click_function = "nullFunction", function_owner = self,
  label = name, position = {0, 0.26, 8}, scale = {25, 25, 25}, width = 0,
  height = 0, font_size = 225, font_color = nameColor})
if unitScript == 4 then
	self.editButton({index = 0, scale = nameScaleSkrm})
end

-- Unit Name input box
-- self.createInput({value = name, input_function = "editName", label = "Unit", function_owner = self,
    -- alignment = 3, position = {0, -0.05, -10}, rotation = {0, 0, 180}, width = 400, height = 110,
    -- font_size = 70, scale={x=15, y=15, z=15}, font_color= {1,1,1,1}, color = {0.1,0.1,0.1,1}})

--Strength Counter on the back (index 1)
self.createButton({click_function = "nullFunction", function_owner = self,
  label = str, position = {0, -0.05, -5}, rotation = {0, 0, 0}, scale = {25, 25, 25}, width = 180, height = 160, font_size = 160, font_color = rgbWhite, color = {0, 0, 0}, tooltip = strTooltip})

--formation overlays (index 2)
formHalt = {index = 2, click_function = "nullFunction", function_owner = self, label = "", position = {1, 0.25, 0.25},	rotation = {0, 0, 0}, scale = {2, 2, 2}, width = 0, height = 0, font_size = 160, font_color = {1, 1, 1, 1}}

formInfAdvance = {index = 2, click_function = "nullFunction", function_owner = self, label = "                                        →", position = {0, 0.1, 5}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}
-- formInfAdvanceL = {index = 2, click_function = "nullFunction", function_owner = self, label = "←                                      ", position = {0, 0.1, 5}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}

formAttack = {index = 2, click_function = "nullFunction", function_owner = self, label = "↑A↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {45, 1, 45}, width = 0, height = 0, font_size = 200, font_color = {1,0,0,1}, color = {0,0,0,1}}

formCavAdvance = {index = 2, click_function = "nullFunction", function_owner = self, label = "↑", position = {0, 0.1, -12}, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}

self.createButton(formHalt)

--Strength (index 3) / Cohesion (index 4) / Fatigue (index 5)  displays
if name ~= nil and name ~= "" then
	createStrength = true
	createCohesion = true
	if unitScript ~= 4 then
		createFatigue = true
	end
else
	createStrength = false
	createCohesion = false
	createFatigue = false
end

if createStrength then
	self.createButton({click_function = "clickStrength", function_owner = self,
	  label = strLabel3, position = strPos, rotation = {0, 0, 0}, scale = {40, 40, 40}, width = strWidth, height = 100, font_size = strSize, color = {0,0,0,0}, font_color = colorStrength, tooltip = "Strength"})
else
	self.createButton({click_function = "nullFunction", function_owner = self,
	  label = "", position = {0, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0, height = 0, font_size = 0, color = {0,0,0,0}, font_color = {0,0,0,0}, tooltip = ""})
end
	
if createCohesion then
	self.createButton({click_function = "clickCohesion", function_owner = self,
	  label = cohesionLabel3, position = cohesionPos, rotation = {0, 0, 0}, scale = {40, 40, 40}, width = 180, height = 180, font_size = strSize, color = {0,0,0,0}, font_color = colorCohesion3, tooltip = cohesionTooltip3})
else
	self.createButton({click_function = "nullFunction", function_owner = self,
	  label = "", position = {0, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0, height = 0, font_size = 0, color = {0,0,0,0}, font_color = {0,0,0,0}, tooltip = ""})
end

if createFatigue then
	self.createButton({click_function = "clickFatigue", function_owner = self,
	  label = ballLabel2of2, position = staminaPos, rotation = {0, 0, 0}, scale = {40, 40, 40}, width = 200, height = 120, font_size = 130, color = {0,0,0,0}, font_color = staminaColor, tooltip = ballLabelHigh})
	self.createButton({click_function = "clickFatigue", function_owner = self,
	  label = ballLabel3of3, position = fatiguePos, rotation = {0, 0, 0}, scale = {40, 40, 40}, width = 300, height = 120, font_size = 130, color = {0,0,0,0}, font_color = fatigueColor, tooltip = ballLabelHigh})
else
	self.createButton({click_function = "nullFunction", function_owner = self,
	  label = "", position = {0, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0, height = 0, font_size = 0, color = {0,0,0,0}, font_color = {0,0,0,0}, tooltip = ""})
	self.createButton({click_function = "nullFunction", function_owner = self,
	  label = "", position = {0, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0, height = 0, font_size = 0, color = {0,0,0,0}, font_color = {0,0,0,0}, tooltip = ""})
end

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
				if direction == 0 then self.editButton({index = 2, rotation = {0,0,180}}) end
				if unitSize == -1 then
					self.editButton({index = 2, label = "                                →"})
				elseif unitSize == -2 then
					self.editButton({index = 2, label = "                           →"})
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
	if unitScript == 1 or unitScript == 4 then
		if faction == "red" then
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_inf-red.png"
		else 
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_inf-blue.png"
		end
		if unitScript == 1 then
			if formationVal == 1 then --battle line
				meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/obj/battalion_line.obj"
			elseif formationVal == 2 then --attack column
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693331/C0DEFCF73A79541D4756A93BBF4B8E922982F429/"
			elseif formationVal == 3 then --marching column
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693391/0943345DA6F3BD247B7073EF24B54579EA3126F0/" -- mesh infantry open column
			elseif formationVal == 4 then --square
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693356/0D82CF6ED5B1B76EEF16C340F01B6838BC5BECB3/"
			end
			
			if unitSize < -1 then formScale = {0.64, 1, 1}
			elseif unitSize == -1 then formScale = {0.8, 1, 1}
			elseif unitSize > 0 then formScale = {1.25, 1, 1}
			end
		elseif unitScript == 4 then
			meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/obj/skirmisher-zug2.obj"
			formScale = {0.5, 1, 0.5}
		end

	-- CAVALRY --
	elseif unitScript == 2 then
		if faction == "red" then
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cavalry-red.png"
			imgUrlRider = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_rider-red.png"
			if unitType == 1 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-red-hussar.png" -- red hussars
			elseif unitType == 2 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-red-dragoon.png" -- red dragoons
			elseif unitType == 3 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-red-lancer.png" -- red lancers
			elseif unitType == 4 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-red-cuirassier.png" -- red cuirassiers
			end
		else 
			imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cavalry-blue.png"
			imgUrlRider = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_rider-blue.png"
			if unitType == 1 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-blue-hussar.png" -- blue hussars
			elseif unitType == 2 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-blue-dragoon.png" -- blue dragoons
			elseif unitType == 3 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-blue-lancer.png" -- blue lancers
			elseif unitType == 4 then
				img2Url = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_cav-blue-cuirassier.png" -- blue cuirassiers
			end
		end
		if formationVal == 2 then
			if str > str_med then
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2403326468915464363/2FBFCF70F18CD4DAB53A66CDB856A505606CF92D/" -- mesh cavalry ranks full
			else
				meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2403326468915464384/EE65186B36AEBDB572D517522EBCD26B5F548BFE/" -- mesh cavalry ranks half
			end
			formPosOffset = Vector(0,0,8)
		elseif formationVal == 3 then
			if unitSize >= 0 then
				meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/obj/squadron_columnF.obj" -- mesh cavalry open column full
				formPosOffset = Vector(0,0,40)
			else
				meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/obj/squadron_columnF-half.obj" -- mesh cavalry open column half
				formPosOffset = Vector(0,0,20)
			end		
		end	

	-- ARTILLERY --
	elseif unitScript == 3 then
		imgUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/img_artillery.png"
		meshUrl = "https://steamusercontent-a.akamaihd.net/ugc/2458494928524557226/2DEA1DEA81B2888FB3018EB1B1CE83AB27A6BC57/" -- Unlimbered Artillery
		if formationVal == 3 then
			meshUrl = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/obj/guns_limbered-reverse.obj" -- Limbered Artillery
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
		unitParams = {
			type = "Custom_Tile",
			position		= self.positionToWorld(Vector(0, 0.1, 25)), -- float just above tile
			rotation		= self.getRotation() + Vector(0, 0, 0),   -- flat, face-up
			scale			= Vector(0.2, 1, 0.2),
			snap_to_grid	= false,
		}
		
		unitData = {
			image = img2Url,
			thickness = 0.02,
		}

		UnitModel = spawnObject(unitParams)
		UnitModel.setCustomObject(unitData)
		UnitModel.setColorTint(myColorTint)
		self.addAttachment(UnitModel)
	end

	-- print("Finished setFormation.")
	-- printDebug()
end

function clickStrength(obj, color, alt_click)
	if alt_click then strInc(-1) else strInc(1) end
end

function strButton(alt_click)
	if not alt_click then strUp() else strDown() end
end

function strUp()
	strInc(1)
end

function strDown()
	strInc(-1)
end

function strInc(val)
	strLast = str
	str=str+val
	setStrength()
end

function setStrength()
	if strLast == nil then strLast = str end
	if str < strMIN then str = strMIN
	elseif str > strMAX then str = strMAX end
	
	unitSize = 0
	if str <= str_sml then unitSize = -2
	elseif str <= str_med then unitSize = -1
	elseif str > str_big then unitSize = 1 end
	
	local i = str+1
	strLabel = strLabels[i]

	self.editButton({index = 3, label = strLabel})
	
	self.editButton({index = 2, label=str})
	setFormation()
	if strLast ~= str then
		print(name .. " Strength: " .. strLast .. " > " .. str)
	end
end

function clickCohesion(obj, color, alt_click)
	cohesionLast = cohesion
	if alt_click then cohesion=cohesion-1 else cohesion=cohesion+1 end

	if cohesion < cohesionMIN then cohesion=cohesionMIN
	elseif cohesion > cohesionMAX then cohesion=cohesionMAX
	end
	
	print(name .. " Cohesion: " .. cohesionLast .. " > " .. cohesion)
	
	setCohesion()
end

function setCohesion()
	if cohesion == 3 then
		self.editButton({index = 4, label = cohesionLabel3, scale = statScaleNormal, font_color = colorCohesion2, tooltip = cohesionTooltip3})
	elseif cohesion == 2 then
		self.editButton({index = 4, label = cohesionLabel2, scale = statScaleNormal, font_color = colorCohesion2, tooltip = cohesionTooltip2})
	elseif cohesion == 1 then
		self.editButton({index = 4, label = cohesionLabel1, scale = statScaleNormal, font_color = colorCohesion1, tooltip = cohesionTooltip1})
	elseif cohesion == 0 then
		self.editButton({index = 4, label = cohesionLabel0, scale = statScaleNormal, font_color = colorCohesion0, tooltip = cohesionTooltip0})
	elseif cohesion == -1 then
		self.editButton({index = 4, label = cohesionLabelNeg, scale = statScaleBig, font_color = colorCohesionNeg, tooltip = cohesionTooltipNeg})
	else print("Cohesion value is fucked up")
	end
end

function clickFatigue(obj, color, alt_click)
	local staminaLast = stamina
	local fatigueLast = fatigue
	local staminaBuffer = false
	if alt_click then
		staminaBuffer = false
		if stamina > staminaMIN then
			stamina = stamina-1
		else
			fatigue = fatigue-1
		end
	else
		if stamina < staminaMAX then
			stamina = stamina+1
		elseif staminaBuffer then
			fatigue = fatigue+1
		else
			staminaBuffer = true
		end
		if fatigue >= fatigueMAX then staminaBuffer = false end
	end

	stamina = math.max(math.min(stamina, staminaMAX), staminaMIN)
	fatigue = math.max(math.min(fatigue, fatigueMAX), fatigueMIN)
	
	print(name .. " Stamina: " .. staminaLast .. " > " .. stamina .. ", Fatigue: " .. fatigueLast .. " > " .. fatigue)
	
	setFatigue()
end

function setFatigue()
	fatigueMAX = fatigueMAXBase + fatigueBonus

	if staminaMAX == 2 then
		staminaLabel = ballLabelXof2[stamina+1]
	else
		staminaLabel = ballLabelXof1[stamina+1]
	end

	if stamina > 1 then
		fatigueTooltip = fatigueTooltips[3]
	elseif stamina == 1 then
		fatigueTooltip = fatigueTooltips[2]
	else
		fatigueTooltip = fatigueTooltips[1]
	end

	if fatigueMAX == 4 then
		fatigueLabel = ballLabelXof4[fatigue+1]
	elseif fatigueMAX == 3 then
		fatigueLabel = ballLabelXof3[fatigue+1]
	else
		fatigueLabel = ballLabelXof2[fatigue+1]
	end
	
	if fatigue > 0 then
		fatigueColor = rgbBlue
	else
		fatigueColor = rgbGrey
	end

	self.editButton({index = 5, label = staminaLabel, scale = statScaleNormal, font_color = staminaColor, tooltip = fatigueTooltip})
	
	self.editButton({index = 6, label = fatigueLabel, scale = statScaleNormal, font_color = fatigueColor, tooltip = fatigueTooltip})
end

function clickVeterancy()
	veterancyLast = veterancy
	veterancy = veterancy+1
	if veterancy > veterancyMAX then veterancy = veterancyMIN end
	
	print(name .. " veterancy: " .. veterancyLast .. " > " .. veterancy)
	
	setState()
end

function setVeterancy()
	if veterancy >= veterancyMAX then
		fatigueBonus = 1
	else
		fatigueBonus = 0
	end
end

-- function unitReduce(objToScale)
	-- objToScale.scale({0.8, 1, 1})
-- end

-- function unitIncrease()
	-- objToScale.scale({1.25, 1, 1})
-- end

function getSpawnPos(offset)
	if offset == nil then offset = 0 end
	local pos = self.getPosition()
	local forward = self.getTransformForward()
	local spawnPos = pos - forward * offset
	return spawnPos
end

function spawnSmoke() --spawns smoke token
	if unitScript ~= 3 then
		spawnPos = getSpawnPos(0.5)
	else
		spawnPos = getSpawnPos(1.3)
	end
	local myRotation = self.getRotation()
	params1 = {
	  type = 'Custom_Token',
	  position          = spawnPos,
	  rotation          = myRotation,
	  scale             = {x=0.28, y=1, z=0.28},
	  snap_to_grid      = false,
	}
	object = spawnObject(params1)
	
	if unitScript ~= 3 then
		imgSmoke = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/smoke_inf1.png"
	else
		imgSmoke = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/units/img/smoke_art2b.png"
	end

	params2 = {
	  image = imgSmoke,
	  thickness = 0.1,
	}
	object.setCustomObject(params2)
end

function spawnSkirmisher() --spawns skirmisher
	local spawnPos = getSpawnPos(1.2)
	local myRotation = self.getRotation()
	local myColorTint = self.getColorTint()
	local spawnparams = {
		type 			= 'Custom_Tile',
		position		= spawnPos,
		rotation		= myRotation,
		colortint		= myColorTint,
		scale			= baseScale,
	}
	object = spawnObject(spawnparams)

	local params = {
		image 			= baseUrl,
		thickness		= 0.1,
	}
	object.setCustomObject(params)

	object.setName("("..name..")")
	object.addTag("D6KS Skirmisher")
	Global.setVar("spawnFaction",faction)
	unitLUA = Global.getVar("unitLUA")
	Global.call("loadUnitScript",object)
	-- object.setColorTint(myColorTint)
end

function skirmisherRejoin()
	local roll = math.random(6)+str
	local pass = "LOST"
	if roll >= 3 then pass = "REJOINED" end
	print(name .. " skirmishers rejoining with " .. str .. ", rolled " .. roll .. "," .. pass .. "")
	self.destroyObject()
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
	object.setCustomObject(params)

	object.setName(name)
	-- object.setColorTint(myColorTint)
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
	if unitScript == 1 or (unitScript == 1 and unitType == 2) or unitScript == 4 then
		self.addContextMenuItem("Gun Smoke", spawnSmoke, true)
	end
	if unitScript == 1 then
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
	if unitScript == 4 then
		self.addContextMenuItem(">Rejoin Battalion", skirmisherRejoin)
	end
	self.addContextMenuItem("Change Faction", changeFaction, true)
	self.addContextMenuItem("Cycle Veterancy", clickVeterancy, true)
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
	self.editButton({index = 0, label=name})
end

function nullFunction()
--does nothing
end
]]

function loadUnitScript(obj)
	if obj == nil then return end
    obj.setLuaScript(unitLUA)
    obj.reload()  -- reloads the script so onLoad runs immediately
	-- print("Script for " .. obj.getName() .. " updated.")
end


-- TTS Scripting Hotkey Buttons
function onScriptingButtonDown(index, player_color) --function ran anytime player presses one of the bound scripting buttons
    local selectedObjects = Player[player_color].getSelectedObjects() --get all selected objects for player
    local hoveredObject = Player[player_color].getHoverObject()
        if index == 1 then
            if selectedObjects[1] ~= nil then --if there are objects in the table then
                for i in ipairs(selectedObjects) do --for every item in the table
                    if selectedObjects[i].getVar("unitScript") ~= 3 then
						selectedObjects[i].call('setLine') --if the function exists then we can call it
					else selectedObjects[i].call('setUnlimbered')
					end						
                end
            else --if there are no selected objects, then we run the hover function
                if hoveredObject ~= nil and hoveredObject.getVar("setLine") ~= nil then hoveredObject.call('setLine') end --check there is a hovered object and that it has the appropriate function
            end
       elseif index == 2 then
            if selectedObjects[1] ~= nil then
                for i in ipairs(selectedObjects) do
                    if selectedObjects[i].getVar("unitScript") ~= 3 then
						selectedObjects[i].call('setAttack')
					else selectedObjects[i].call('setUnlimbered')
					end
                end
            else
                if hoveredObject ~= nil and hoveredObject.getVar("setAttack") ~= nil then hoveredObject.call('setAttack') end
            end
        elseif index == 3 then
            if selectedObjects[1] ~= nil then
                for i in ipairs(selectedObjects) do
                    if selectedObjects[i].getVar("unitScript") ~= 3 then
						selectedObjects[i].call('setMarch')
					else selectedObjects[i].call('setLimbered')
					end
                end
            else
                if hoveredObject ~= nil and hoveredObject.getVar("setMarch") ~= nil then hoveredObject.call('setMarch') end
            end
        elseif index == 4 then
            if selectedObjects[1] ~= nil then
                for i in ipairs(selectedObjects) do
                    if selectedObjects[i].getVar("unitScript") ~= 3 then
						selectedObjects[i].call('setSqiare')
					else selectedObjects[i].call('setDefeated')
					end
                end
            else
                if hoveredObject ~= nil and hoveredObject.getVar("setSquare") ~= nil then hoveredObject.call('setSquare') end
            end
        end
end