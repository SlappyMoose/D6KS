--- script by SlappyMoose, for his "D6 Kriegsspiel" system, v1.0
--- copy paste all this code into the table's Global LUA, then tag units with "D6KS Infantry" / Cavalry / Artillery
debug_global, debug_unitInit, debug_unitState = false, true, false
FORCE_GLOBAL_LOAD, SCRIPT_VERSION = false, 4
UNIT_LUA = [[
UNIT_VERSION = 4
debug_unitInit = Global.getVar("debug_unitInit")
debug_unitState = Global.getVar("debug_unitState")
force_global_load = Global.getVar("FORCE_GLOBAL_LOAD")

local guid = self.getGUID()

if self.hasTag("D6KS Infantry") then unitScript = 1
elseif self.hasTag("D6KS Cavalry") then unitScript = 2
elseif self.hasTag("D6KS Artillery") then unitScript = 3
elseif self.hasTag("D6KS Skirmisher") then unitScript = 4 end

-------------------
--- LOAD / SAVE ---
-------------------
function onload(data)
	if data then
		local_data = data
	else
		local_data = ""		
	end
	Wait.frames(updateScript, 1)
end

function updateScript()
	local script = Global.getVar("UNIT_LUA")
	local latest = Global.getVar("SCRIPT_VERSION")
	if not script then
		if debug_unitInit then print("Error updating unit script from global!") end
		return
	end

	if UNIT_VERSION == latest then
		if debug_unitInit then print("Unit version matches.") end
		init()
	else
		if debug_unitInit then print("Unit script mismatch, updating...") end
		self.setLuaScript(script)
		self.reload()
	end
end

function init()
	if debug_unitInit then print("Initializing...") end
	loadDefaults()

	loadData()
	
	varFix()
	self.setScale(baseScale)
	CreateButtons()
	setState()
	updateContextMenu()
	--self.unlock()
	-- printDebug()
	
	Wait.time(nameCheck, 5, -1) -- update displayed name to object name
	--Wait.time(hoverCheck, 0.05, -1) -- show buttons on hover
end

function loadData()
	if debug_unitInit then print("Loading unit data for " .. guid .. "...") end
	local myData = {}
	
	local global_data = Global.call("getUnitData", guid)
	if global_data ~= "" or force_global_load then
		if debug_unitInit then print("Loaded saved_data from GLOBAL!") end
		myData = global_data
	else
		if debug_unitInit then print("No global saved_data, trying locally...") end
		if local_data then
			if debug_unitInit then print("Loaded saved_data from LOCAL!") end
			myData = local_data
		else
			if debug_unitInit then print("No local saved_data.") end
		end
	end

	if myData == nil or myData == "" then
		print("No saved_data!")
	else	
		faction = myData.faction
		unitType = myData.unitType
		str = myData.str
		formationVal = myData.formationVal
		cohesion = myData.cohesion
		stamina = myData.stamina
		fatigue = myData.fatigue
		maneuver = myData.maneuver
		direction = myData.direction
		moving = myData.moving
		veterancy = myData.veterancy
	end
end

function onSave()
	local save_data = saveData()
	return JSON.encode({ saved_data = saved_data })
end

function saveData()
	saved_data = {
		faction=faction,
		unitType=unitType,
		str=str,
		formationVal=formationVal,
		cohesion=cohesion,
		stamina=stamina,
		fatigue=fatigue,
		maneuver=maneuver,
		direction=direction,
		moving=moving,
		veterancy=veterancy
	}
	
	Global.call("storeUnitData", {
		guid = guid,
		data = saved_data
	})
	-- print("Stored unit data for " .. guid .. ".") end
	
	return saved_data
end

function setState()
	if debug_unitState then print("Starting setState...") end
	writeUnitData()
	writeFormations()
	setVeterancy()
	setCohesion()
	setStrength()
	setFormation()
	setFatigue()
	if debug_unitState then print("Finished setState.") end
end

function loadDefaults()
	if debug_unitInit or debug_unitState then print("Starting loadDefaults...") end
	name = self.getName()
	
	rgb = 127
	colors = {
		norm = {
			white	= {1, 1, 1, 1},
			yellow	= {1, 1, 0, 1},
			orange	= {1, 0.5, 0, 1}, --same as Yellow?
			red		= {1, 0, 0, 1},
			green	= {0, 1, 0, 1},
			blue	= {0, 1, 1, 1},
			grey	= {0.5, 0.5, 0.5, 1}
		},
		byte = {
			white	= {1, 1, 1, rgb},
			yellow	= {1, 1, 0, rgb},
			orange	= {1, 0.5, 0, rgb},
			red		= {1, 0, 0, rgb},
			green	= {0, 1, 0, rgb},
			blue	= {0, 1, 1, rgb},
			grey	= {0.5, 0.5, 0.5, rgb}
		},
		none = {0,0,0,0}
	}
	overlayAlpha = 0.6
	strengthColor = colors.byte.white
	staminaColor = colors.byte.green
	fatigueColor = colors.byte.blue
	fatigueColor2 = colors.byte.grey
	statScaleNormal = {25, 25, 25}
	statScaleBig = {35, 35, 35}

	strTooltip = "Strength"
	strMIN = 0 --minimum amount allowed
	unitLosses = 0
	isReduced = false

	formationVal = 1
	maneuvers = {
		halt		= { "", {0,0,0}, colors.none },
		march		= { "←", {-60, 0.1, 2}, colors.norm.white },
		attack		= { "↑A↑", {0, 0.1, -18}, colors.norm.red },
		advance3		= { "↑ ↑ ↑", {0, 0.1, -18}, colors.norm.white },
		advance2	= { "↑ ↑", {0, 0.1, -18}, colors.norm.white },
		advance1	= { "↑", {0, 0.1, -18}, colors.norm.white },
		moveup3		= { "halt", "advance3", "attack" },
		moveup2		= { "halt", "advance2", "attack" },
		moveup2b	= { "halt", "advance2" },
		moveup1b	= { "halt", "advance1" },
		moveside	= { "halt", "march", "march", "halt" }
	}
	maneuver = "halt"
	direction = "moveup1b"
	moving = 1
	--- http://xahlee.info/comp/unicode_arrows.html
	
	cohesion = 3 -- 3 = Cohesive, 2 = Disordered, 1 = Broken, 0 = Shattered
	cohesionMIN = 0
	cohesionMAX = 3
	disorder = cohesionMAX-cohesion
	cohesionTooltips = { "Cohesive", "Disordered", "BROKEN", "SHATTERED" }
	cohesionLabels = {"⬛", "⬛", "⬜", "⬚"}
	cohesionColors = { colors.byte.white, colors.byte.yellow, colors.byte.yellow, colors.byte.red }
	cohesionScales = { statScaleNormal, statScaleNormal, statScaleNormal, statScaleBig }
	
	blockStrength = "full"
	blockCohesion = "cohesive"

	stamina = 2
	staminaMIN = 0
	staminaMAX = 2
	fatigue = 3
	fatigueMIN = 0
	fatigueMAX = 3
	ballLabelXof1 = {"○", "●"}
	ballLabelXof2 = {"○○", "○●", "●●"}
	ballLabelXof3 = {"○○○", "○○●", "○●●", "●●●"}
	ballLabelXof4 = {"○○○○", "○○○●", "○○●●", "○●●●", "●●●●"}
	fatigueTooltips = {"Exhausted", "Tired", "Fresh"}
	local strLabels6 = {"◇◇◇", "◇◇⬗", "◇◇◆", "◇⬗◆", "◇◆◆", "⬗◆◆", "◆◆◆"}
	local strLabels8 = {"◇◇◇◇", "◇◇◇⬗", "◇◇◇◆", "◇◇⬗◆", "◇◇◆◆", "◇⬗◆◆", "◇◆◆◆", "⬗◆◆◆", "◆◆◆◆"}
	local strLabels12 = {"◇◇◇\n◇◇◇", "◇◇◇\n◇◇⬗", "◇◇◇\n◇◇◆", "◇◇◇\n◇⬗◆", "◇◇◇\n◇◆◆", "◇◇◇\n⬗◆◆", "◇◇◇\n◆◆◆", "◇◇⬗\n◆◆◆", "◇◇◆\n◆◆◆", "◇⬗◆\n◆◆◆", "◇◆◆\n◆◆◆", "⬗◆◆\n◆◆◆", "◆◆◆\n◆◆◆"}
	
	if unitScript == 1 then --inf
		strMAX = 12
		strLabels = strLabels12
		losspoints = {3,6,9}
	elseif unitScript == 2 then --cav
		strMAX = 6
		strLabels = strLabels6
		losspoints = {1,3,5}
		staminaMAX = 1
		fatigueMAX = 2
	elseif unitScript == 3 then --art
		strMAX = 8
		strLabels = strLabels8
		losspoints = {0,0,0}
	elseif unitScript == 4 then --skrm
		strMAX = 6
		strLabels = strLabels6
		losspoints = {0,0,0}
		strpos = {5, 0.26, 16}
		strSize = 70
		cohesionpos = {-8, 0.26, 16}
	end
	
	URLD6KS = "file:///T:/Games/StrategyGames/Kriegsspiel/D6KS/"
	imgFolder = URLD6KS .."units/img/"
	objFolder = URLD6KS .. "units/obj/"
	meshURLsInf = {
		full = {
			cohesive = {
			objFolder .. "inf_Section_Full.obj",
			objFolder .. "inf_Section_Full1a.obj",
			objFolder .. "inf_Section_Full1b.obj",
			objFolder .. "inf_Section_Full2a.obj",
			objFolder .. "inf_Section_Full2b.obj"
			},
			broken = {
			objFolder .. "inf_Section_Full-Br.obj",
			objFolder .. "inf_Section_Full1a-Br.obj",
			objFolder .. "inf_Section_Full2b-Br.obj"
			},
			shattered = {
			objFolder .. "inf_Section_Full-Sh.obj"
			}
		},
		reduced = {
			cohesive = {
			objFolder .. "inf_Section_Reduced.obj",
			objFolder .. "inf_Section_Reduced1a.obj",
			objFolder .. "inf_Section_Reduced1b.obj",
			},
			broken = {
			objFolder .. "inf_Section_Reduced-Br.obj",
			objFolder .. "inf_Section_Reduced1b-Br.obj"
			},
			shattered = {
			objFolder .. "inf_Section_Reduced-Sh.obj",
			objFolder .. "inf_Section_Reduced1b-Sh.obj"
			}
		},
		depleted = {
			cohesive = {
			objFolder .. "inf_Section_Reduced2a.obj",
			objFolder .. "inf_Section_Reduced2b.obj",
			objFolder .. "inf_Section_Reduced3a.obj"
			},
			broken = {
			objFolder .. "inf_Section_Reduced2a-Br.obj",
			objFolder .. "inf_Section_Reduced3a-Br.obj"
			},
			shattered = {
			objFolder .. "inf_Section_Reduced2a-Sh.obj",
			objFolder .. "inf_Section_Reduced3a-Sh.obj"
			}
		}
	}
	meshURLsCav = {
		full = {
			cohesive = {
			objFolder .. "cav_squad_full-co-0a.obj",
			objFolder .. "cav_squad_full-co-1a.obj",
			objFolder .. "cav_squad_full-co-1b.obj"
			},
			broken = {
			objFolder .. "cav_squad_full-br-0a.obj",
			objFolder .. "cav_squad_full-br-0b.obj",
			objFolder .. "cav_squad_full-br-1a.obj"
			},
			shattered = {
			objFolder .. "cav_squad_full-sh-0a.obj",
			objFolder .. "cav_squad_full-sh-0b.obj",
			objFolder .. "cav_squad_full-sh-1a.obj",
			objFolder .. "cav_squad_full-sh-1b.obj"
			}
		},
		reduced = {
			cohesive = {
			objFolder .. "cav_squad_loss-co-0a.obj",
			objFolder .. "cav_squad_loss-co-1a.obj",
			objFolder .. "cav_squad_loss-co-1b.obj"
			},
			broken = {
			objFolder .. "cav_squad_loss-br-0a.obj",
			objFolder .. "cav_squad_loss-br-0b.obj",
			objFolder .. "cav_squad_loss-br-1a.obj",
			objFolder .. "cav_squad_loss-br-1b.obj"
			},
			shattered = {
			objFolder .. "cav_squad_loss-sh-0a.obj",
			objFolder .. "cav_squad_loss-sh-0b.obj",
			objFolder .. "cav_squad_loss-sh-1a.obj",
			objFolder .. "cav_squad_loss-sh-1b.obj"
			}
		},
		depleted = {
			cohesive = {
			objFolder .. "cav_squad_loss-co-1a.obj",
			objFolder .. "cav_squad_loss-co-2a.obj",
			objFolder .. "cav_squad_loss-co-2b.obj"
			},
			broken = {
			objFolder .. "cav_squad_loss-br-1a.obj",
			objFolder .. "cav_squad_loss-br-1b.obj",
			objFolder .. "cav_squad_loss-br-2a.obj",
			objFolder .. "cav_squad_loss-br-2b.obj"
			},
			shattered = {
			objFolder .. "cav_squad_loss-sh-1a.obj",
			objFolder .. "cav_squad_loss-sh-1b.obj",
			objFolder .. "cav_squad_loss-sh-2a.obj"
			}
		}
	}
	meshURLsArt = {
		objFolder .. "guns_unlimbered.obj",
		objFolder .. "guns_limbered.obj",
		objFolder .. "guns_defeated.obj"
	}
	meshUrlsSkirm = {
		objFolder .. "skirmisher-zug.obj"
	}

	colorName = {1,1,1,1} --what color do you want the piece Name to be?
	faction = "red"

	veterancyMIN = 1
	veterancyMAX = 3
	veterancy = 2

	unitType = 1 -- cav: hussar, dragoons, lancer, cuirassier. art: foot, horse.
	unitTypeCount = 1
	baseScale = {0.03, 1, 0.03}
	baseURL = imgFolder .. "base-blank.png"
	meshURL = nil
	
	hideButtons = false
	if debug_unitInit or debug_unitState then print("Finished loadDefaults.") end
end

function varFix()
	if faction == nil then faction = "red" end
	
	if str == nil then str = strMAX end
	if strLast == nil then strLast = str end
	if unitLossesLast == nil then unitLossesLast = unitLosses end
	if unitType == nil then unitType = 1 end
	if formationVal == nil then formationVal = 1 end
	if not maneuvers[maneuver] then maneuver = "halt" end
	if not maneuvers[direction] then direction = "moveup1b" end
	
	if moving == nil or moving < 1 then moving = 1 end
	
	if cohesion == nil then cohesion = cohesionMAX end
	cohesion = math.max(math.min(cohesion, cohesionMAX), cohesionMIN)

	if stamina == nil then stamina = staminaMAX end
	stamina = math.max(math.min(stamina, staminaMAX), staminaMIN)
	if fatigue == nil then fatigue = fatigueMAX end
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

local posName = {0, 0.26, 0}
local posStrength = {0, 0.26, 15}
local posCohesion = {-14, 0.26, 15}
local posStamina = {16, 0.26, 15}
local posFatigue = {28, 0.26, 15}
local nameScale = 25
local fontSize = 100
local fontSize2 = 130
if unitScript == 4 then nameScale = 15 end

--Unit Name front display (index 0)
self.createButton({click_function = "nullFunction", function_owner = self, label = name, position = posName, scale = {nameScale,nameScale,nameScale}, width = 0, height = 0, font_size = 225, font_color = colorName})

--movement overlay (index 1)
self.createButton({click_function = "nullFunction", function_owner = self, label = "", position = {0, 0.25, 0},	rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 0, height = 0, font_size = 200, font_color = colors.byte.white})

--strength (index 2) / cohesion (index 3) / stamina (index 4) / fatigue (index 5)
local createStrength = false
local createCohesion = false
local createFatigue = false

if name ~= nil and name ~= "" then
	createStrength = true
	createCohesion = true
	if unitScript < 3 then
		createFatigue = true
	end
end

if createStrength then
	self.createButton({click_function = "clickStrength", function_owner = self, label = strLabel, position = posStrength, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 250, height = 100, font_size = fontSize, color = colors.none, font_color = strengthColor, tooltip = "Strength"})
else
	createEmptyButton()
end
	
if createCohesion then
	self.createButton({click_function = "clickCohesion", function_owner = self, label = cohesionLabels[1], position = posCohesion, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 180, height = 180, font_size = fontSize, color = colors.none, font_color = colors.byte.white, tooltip = cohesionTooltips[1]})
else
	createEmptyButton()
end

if createFatigue then
	self.createButton({click_function = "clickFatigue", function_owner = self, label = ballLabel2of2, position = posStamina, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 200, height = 120, font_size = fontSize2, color = colors.none, font_color = staminaColor, tooltip = ballLabelHigh})
	
	self.createButton({click_function = "clickFatigue", function_owner = self, label = ballLabel3of3, position = posFatigue, rotation = {0, 0, 0}, scale = {40, 1, 40}, width = 300, height = 120, font_size = fontSize2, color = colors.none, font_color = fatigueColor, tooltip = ballLabelHigh})
else
	createEmptyButton()
	createEmptyButton()
end

end --end button creation

-----------------
--- functions ---
-----------------
function writeUnitData()
	if debug_unitState then print("Starting writeUnitData...") end
	imgURL = ""
	factionURLs = ""
	myColorTint = self.getColorTint()
	
	--- FACTION TEXTURES
	if faction == "red" then
		factionURLs = {
		imgFolder .. "img_inf-red.png",
		imgFolder .. "img_cavalry-red.png",
		imgFolder .. "img_artillery-red.png",
		imgFolder .. "img_inf-red.png",
		imgFolder .. "img_rider-red.png",
		type = {
			imgFolder .. "img_cav-hussar-red.png",
			imgFolder .. "img_cav-dragoon-red.png",
			imgFolder .. "img_cav-lancer-red.png",
			imgFolder .. "img_cav-cuirassier-red.png"
			}
		}
	elseif faction == "blue" then
		factionURLs = {
		imgFolder .. "img_inf-blue.png",
		imgFolder .. "img_cavalry-blue.png",
		imgFolder .. "img_artillery-blue.png",
		imgFolder .. "img_inf-blue.png",
		imgFolder .. "img_rider-blue.png",
		type = {
			imgFolder .. "img_cav-hussar-blue.png",
			imgFolder .. "img_cav-dragoon-blue.png",
			imgFolder .. "img_cav-lancer-blue.png",
			imgFolder .. "img_cav-cuirassier-blue.png"
			}
		}
	else
		print("No faction assigned!")
	end
	imgURL = factionURLs[unitScript]
	img2URL = factionURLs.type[unitType]

	blockScale = Vector(1.45, 1, 1.45)
	if unitScript == 1 then --- INFANTRY BATTALION
		flagURL = objFolder .. "inf_Flag.obj"
		blockCount = 8
		meshURLs = meshURLsInf
	elseif unitScript == 2 then --- CAVALRY SQUADRON
		flagURL = objFolder .. "cav_flag.obj"
		blockCount = 3
		unitTypeCount = 4
		meshURLs = meshURLsCav
	elseif unitScript == 3 then --- ARTILLERY SECTION
		blockCount = 1
		meshURLs = meshURLsArt
	elseif unitScript == 4 then --- SKIRMISHER ZUG
		blockCount = 1
		meshURLs = meshUrlsSkirm
	end

	if debug_unitState then print("Finished writeUnitData.") end
end

function writeFormations()
	if debug_unitState then print("Starting writeFormations...") end
	--- INFANTRY FORMATIONS ---
	local blockOffset = 10
	local distX = 16.6
	local distZ = 14
	local shift = distX*0.2
	local squareDistZ = 17
	local x = blockOffset
	local z = 0
	
	local noshift	= Vector(0,0,0)
	
	local shiftL	= Vector(shift,0,0)
	local shiftR	= shiftL*-1
	local shiftU	= Vector(0,0,-shift)
	local shiftD	= shiftU*-1

	local shiftZ = distZ*0.2
	local shiftLZ	= Vector(shiftZ,0,0)
	local shiftRZ	= shiftLZ*-1
	local shiftUZ	= Vector(0,0,-shiftZ)
	local shiftDZ	= shiftUZ*-1

	infLine = {}
	infAttack = {}
	infMarch = {}
	infSquare = {}

	for i = 1,blockCount*0.5,1 do
		local inc = i-1
		x = blockOffset+distX*inc
		z = 0
		table.insert(infLine, {pos = Vector(x,0,0), rot = 0, reduced = shiftR*(inc+0.5)})
		table.insert(infLine, {pos = Vector(-x,0,0), rot = 0, reduced = shiftL*(inc+0.5)})
		
		x = distZ*(inc+0.5)
		table.insert(infMarch, {pos = Vector(x,0,0), rot = -90, reduced = noshift})
		table.insert(infMarch, {pos = Vector(-x,0,0), rot = -90, reduced = noshift})
		
		x = blockOffset-shift*0.5
		z = distZ*inc
		table.insert(infAttack, { pos = Vector(x,0,z), rot = 0, reduced = shiftR*0.5})
		table.insert(infAttack, { pos = Vector(-x,0,z), rot = 0, reduced = shiftL*0.5})
	end
	
	x = blockOffset-shift/2
	z = squareDistZ
	infSquare = {
		{ pos = Vector(x,0,-z),		rot = 0, reduced = shiftR+shiftD },
		{ pos = Vector(-x,0,-z),	rot = 0, reduced = shiftL+shiftD },
		{ pos = Vector(z,0,-x),		rot = -90, reduced = shiftD+shiftR },
		{ pos = Vector(z,0,x),		rot = -90, reduced = shiftU+shiftR },
		{ pos = Vector(x,0,z),		rot = -180, reduced = shiftR+shiftU },
		{ pos = Vector(-x,0,z),		rot = -180, reduced = shiftL+shiftU },
		{ pos = Vector(-z,0,x),		rot = -270, reduced = shiftU+shiftL },
		{ pos = Vector(-z,0,-x),	rot = -270, reduced = shiftD+shiftL }
	}
	
	--- CAVALRY FORMATIONS ---
	distX = 23
	distZ = 21
	shift = distX*0.2
	shiftL	= Vector(shift,0,0)
	shiftR	= shiftL*-1
	shiftU	= Vector(0,0,-shift)
	shiftD	= shiftU*-1
	
	local cavAttack = {
		{ pos = Vector(0,0,0),		rot = 0, reduced = Vector(0,0,0)},
		{ pos = Vector(distX,0,0),	rot = 0, reduced = shiftR },
		{ pos = Vector(-distX,0,0),	rot = 0, reduced = shiftL }
	}
	local cavMarch = {
		{ pos = Vector(0,0,0),		rot = 0, reduced = Vector(0,0,0)},
		{ pos = Vector(0,0,distZ),	rot = 0, reduced = shiftR },
		{ pos = Vector(0,0,distZ*2),rot = 0, reduced = shiftL }
	}
	
	local art_unlimbered = {
		{ pos = Vector(0,0,10), rot = 0, reduced = Vector(0,0,0 ) } }
	
	local art_limbered = {
		{ pos = Vector(0,0,30), rot = 180, reduced = Vector(0,0,0 ) } }
	
	local center = {
		{ pos = Vector(0,0,0), rot = 0, reduced = Vector(0,0,0) }
	}
	
	blocksFormations = {
		{ infLine, infAttack, infMarch, infSquare },
		{ cavAttack, cavAttack, cavMarch },
		{ art_unlimbered, art_limbered, art_unlimbered },
		{ center } 
	}

	if debug_unitState then print("Finished writeFormations.") end
end

function formLine()
	direction = "moveup3"
	if formationVal == 1 then
		moving = cycle(moving, maneuvers[direction])
	else
		formationVal = 1
		moving = 1
	end

	setFormation()
end

function formAttack()
	direction = "moveup2"
	if formationVal == 2 then
		moving = cycle(moving, maneuvers[direction])
	else
		formationVal = 2
		moving = 1
	end

	setFormation()
end

function formMarch()
	if unitScript == 1 then
		direction = "moveside"
	elseif unitScript == 2 then
		direction = "moveup2b"
	else
		direction = "moveup1b"
	end
	
	if formationVal == 3 then
		moving = cycle(moving, maneuvers[direction])
	else
		formationVal = 3
		moving = 1
	end
	
	setFormation()
end

function formSquare()
	direction = "moveup2b"
	moving = 1
	formationVal = 4
	
	setFormation()
end

function setUnlimbered()
	direction = "moveup1b"
	moving = 1
	formationVal = 1
	
	setFormation()
end

function setLimbered()
	direction = "moveup1b"
	if formationVal == 2 then
		moving = cycle(moving, maneuvers[direction])
	else
		formationVal = 2
		moving = 1
	end

	setFormation()
end

function setDefeated()
	direction = "moveup1b"
	moving = 1
	formationVal = 3
	
	setFormation()
end

function setMovement()
	if debug_unitState then print("maneuver, direction, moving,  = " .. maneuver .. ", " .. direction .. ", " .. moving) end
	maneuver = maneuvers[direction][moving]
	
	local btnIndex = 1
	local btnLabel = maneuvers[maneuver][1]
	local btnPos = Vector(maneuvers[maneuver][2])
	local btnRot = Vector(0,0,0)
	if direction == "moveside" and moving > 2 then
		btnPos[1] = -btnPos[1]
		btnRot.y = (btnRot.y + 180) % 360
	end
	
	local btnColor = maneuvers[maneuver][3]
	self.editButton({index = btnIndex, label = btnLabel, position = btnPos, rotation = btnRot, font_color = btnColor})
end

function setFormation()
	if debug_unitState then print("Starting setFormation...") end
	-- printDebug()
	
	setMovement()
	local blockInfo = blocksFormations[unitScript][formationVal]
	
	local blockURLs
	local myRot = myRot()
	local randPos = 0
	local randRot = 0
	local blockRankMod = 0
	local posOffset, formOffset, rotOffset = Vector(0,0,0), Vector(0,0,0), 0
	
	--- COHESION & STRENGTH DETERMINES UNIT BLOCKS
	if unitScript > 2 then
		blockURLs = meshURLs
	else
		blockURLs = meshURLs[blockStrength][blockCohesion]
	end
	
	--- MARCHING DIRECTION
	if direction == "moveside" then
		if moving > 2 then
			rotOffset = 180
		end
	end
	
	--- PLACE NEW BLOCKS
	self.destroyAttachments()

	for i = 1,blockCount,1 do
		local inc = i-1
		local pair = math.floor(inc/2)
		
		local disorderPos = Vector(0,0,0)
		local disorderRot = 0
		local disorderMod = Vector(0,0,0)
		if isDisordered and unitScript ~= 3 then
			randPos = math.random(disorder+1)
			if coinflip() then
				randPos = -randPos
			end
			randRot = math.random(disorder+3)
			if coinflip() then
				randRot = -randRot
			end
			disorderPos = Vector(0,0,randPos)
			disorderRot = randRot
		end
		
		local vetRot = 0
		local vetPos = Vector(0,0,0)
		if veterancy < 2 then
			vetPos = Vector(0,0,math.random(0,1))
			vetRot = math.random(0,2)
		end
		
		if isReduced then posOffset = blockInfo[i].reduced end
		local pos = blockInfo[i].pos + posOffset + disorderPos + formOffset + vetPos
		local rotY = blockInfo[i].rot + rotOffset + disorderRot + vetRot
		local flipX = Vector(1, 1, 1)
		if unitLosses > 0 or disorder > 0 then
			if coinflip() then flipX = Vector(-1, 1, 1) end
		end
		
		---- unitLosses sets the range of possible blocks
		if unitScript < 3 then
			if unitLosses == 0 then
				blockIndex = 1
			elseif unitLosses == 1 then
				blockIndex = math.random(#blockURLs)
			else
				blockIndex = math.random(#blockURLs)			
			end
		else
			blockIndex = formationVal
		end
		blockMesh = blockURLs[blockIndex]
		
		blockModelData = {
			mesh = blockMesh,
			diffuse = imgURL,
			material = 3,
		}
		
		upright()
		
		newBlock = spawnObject({
			type = "Custom_Model",
			position		= self.positionToWorld(pos),
			rotation		= Vector(0, (myRot.y + rotY) % 360, 0),
			scale			= blockScale*flipX,
			snap_to_grid	= false,
		})
		
		newBlock.setCustomObject(blockModelData)
		newBlock.setColorTint(myColorTint)
		self.addAttachment(newBlock)
	end

	--- FLAG BEARER
	-- if unitScript < 3 then 
		-- flagModel = spawnObject({
			-- type = "Custom_Model",
			-- position		= self.positionToWorld(Vector(0, 0, -3)),
			-- rotation		= Vector(0, (myRot.y) % 360, 0),
			-- scale			= Vector(1.2, 1, 1.2),
			-- snap_to_grid	= false
		-- })
		
		-- local flagData = self.getCustomObject()
		-- flagData.mesh = flagURL
		-- flagData.diffuse = factionURLs[1]
		
		-- flagModel.setCustomObject(flagData)
		-- flagModel.setColorTint(myColorTint)
		-- self.addAttachment(flagModel)
	-- end

	-- UNIT TYPE MARKER
	if unitScript == 2 then
		unitParams = {
			type = "Custom_Tile",
			position		= self.positionToWorld(Vector(0, 0.2, 25)), -- float just above tile
			rotation		= Vector(0, (myRot.y) % 360, 0),
			scale			= Vector(0.2, 0.2, 0.2),
			snap_to_grid	= false,
		}
		
		unitData = {
			image = img2URL,
			thickness = 0.02,
		}

		UnitModel = spawnObject(unitParams)
		UnitModel.setCustomObject(unitData)
		UnitModel.setColorTint(myColorTint)
		self.addAttachment(UnitModel)
	end

	if debug_unitState then print("Finished setFormation.") end
	-- printDebug()
end

function clickStrength(obj, color, alt_click)
	if alt_click then strDown() else strUp() end
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
	if debug_unitState then print("Starting setStrength...") end
	local btnIndex = 2
	str = math.min(math.max(str, strMIN), strMAX)

	local i = str+1
	strLabel = strLabels[i]
	
	-- EFFECT OF LOSSES & CASUALTIES
	if str <= losspoints[1] then
		unitLosses = 3
		blockStrength = "depleted"
	elseif str <= losspoints[2] then
		unitLosses = 2
		blockStrength = "reduced"
	elseif str <= losspoints[3] then
		unitLosses = 1
		blockStrength = "full"
	else
		unitLosses = 0
		blockStrength = "full"
	end

	if unitLosses < 2 then
		isReduced = false
	else
		isReduced = true
	end
	
	if unitLosses ~= unitLossesLast then
		print(name .. " Strength: " .. strLast .. " > " .. str .. ", " .. blockStrength)
		setFormation()
	elseif strLast ~= nil and str ~= strLast then
		print(name .. " Strength: " .. strLast .. " > " .. str)
	end
	
	self.editButton({index = btnIndex, label = strLabel})
	
	strLast = str
	unitLossesLast = unitLosses
	if debug_unitState then print("Finished setStrength.") end
end

function clickCohesion(obj, color, alt_click)
	local cohesionLast = cohesion
	
	if alt_click then cohesion=cohesion-1 else cohesion=cohesion+1 end

	cohesion = math.max(math.min(cohesion, cohesionMAX), cohesionMIN)
	
	print(name .. " Cohesion: " .. cohesionLast .. " > " .. cohesion)

	if cohesionLast ~= cohesion then
		setCohesion()
		setFormation()
	end
end

function setCohesion()
	local btnIndex = 3
	disorder = cohesionMAX-cohesion
	local i = disorder+1
	self.editButton({index = btnIndex, label = cohesionLabels[i], scale = cohesionScales[i], font_color = cohesionColors[i], tooltip = cohesionTooltips[i]})
	if cohesion == 3 then -- Cohesive
		blockCohesion = "cohesive"
		isDisordered = false
	elseif cohesion == 2 then -- Disordered
		blockCohesion = "cohesive"
		isDisordered = true
	elseif cohesion == 1 then -- Broken
		blockCohesion = "broken"
		isDisordered = true
	elseif cohesion == 0 then -- Shattered
		blockCohesion = "shattered"
		isDisordered = true
	else
		print("Cohesion value is fucked up")
	end
end

function clickFatigue(obj, color, alt_click)
	local staminaLast = stamina
	local fatigueLast = fatigue
	if staminaBuffer == nil then staminaBuffer = false end
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
	
	if stamina ~= staminaLast then
		print(name .. " Stamina: " .. staminaLast .. " > " .. stamina .. ", Fatigue: " .. fatigueLast .. " > " .. fatigue)
	end
	
	setFatigue()
end

function setFatigue()
	local btnIndex = 4
	local fatigueCAP = fatigueMAX + fatigueBonus
	local fatigueFont

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

	if fatigueCAP == 4 then
		fatigueLabel = ballLabelXof4[fatigue+1]
	elseif fatigueCAP == 3 then
		fatigueLabel = ballLabelXof3[fatigue+1]
	else
		fatigueLabel = ballLabelXof2[fatigue+1]
	end
	
	if fatigue > 0 then
		fatigueFont = fatigueColor
	else
		fatigueFont = fatigueColor2
	end

	self.editButton({index = btnIndex, label = staminaLabel, scale = statScaleNormal, font_color = staminaColor, tooltip = fatigueTooltip})
	
	btnIndex = btnIndex+1
	self.editButton({index = btnIndex, label = fatigueLabel, scale = statScaleNormal, font_color = fatigueFont, tooltip = fatigueTooltip})
end

function clickVeterancy()
	veterancyLast = veterancy
	veterancy = veterancy+1
	if veterancy > veterancyMAX then veterancy = veterancyMIN end
	
	print(name .. " veterancy: " .. veterancyLast .. " > " .. veterancy)
	
	setVeterancy()
	setFormation()
end

function setVeterancy()
	if veterancy >= veterancyMAX then
		fatigueBonus = 1
	else
		fatigueBonus = 0
	end
	setFatigue()
end

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
	local myRot = myRot()
	params1 = {
	  type = 'Custom_Token',
	  position          = spawnPos,
	  rotation          = Vector(0, myRot.y % 360, 0),
	  scale             = {x=0.25, y=1, z=0.25},
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
	local pos = getSpawnPos(1.2)
	local rot = myRot()
	local myColorTint = self.getColorTint()
	local spawnparams = {
		type 			= 'Custom_Tile',
		position		= pos,
		rotation		= rot,
		colortint		= myColorTint,
		scale			= baseScale,
	}
	object = spawnObject(spawnparams)

	local params = {
		image 			= baseURL,
		thickness		= 0.1,
	}
	object.setCustomObject(params)

	object.setName("("..name..")")
	object.addTag("D6KS Skirmisher")
	Global.setVar("spawnFaction",faction)
	unitLUA = Global.getVar("UNIT_LUA")
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
	local pos = getSpawnPos(1.2)
	local rot = myRot()
	spawnparams = {
	  type = 'Custom_Tile',
	  position          = pos,
	  rotation          = rot,
	  colortint         = myColorTint,
	  scale             = Vector(0.1, 1, 0.1),
	  snap_to_grid      = false,
	}
	object = spawnObject(spawnparams)

	local imgURL = factionURLs[5]
	params = {
	  image = imgURL,
	  thickness = 0.1,
	}
	object.setCustomObject(params)

	object.setName(name)
	-- object.setColorTint(myColorTint)
end

function changeFaction()
	if faction == "red" then faction = "blue" else faction = "red" end
	setState()
end

function changeUnitType()
	if unitType < unitTypeCount then unitType=unitType+1 else unitType=1 end
	setState()
end

--- BUTTON HOVER STUFF ---
-- local isHovered, wasHovered = false, false
-- function hoverCheck()
	-- isHovered = (Player.getPointerHoverObject() == self)
	
	-- if isHovered and not wasHovered then
		-- print("Start hover. is, was = (" .. (isHovered and "true" or "false") .. ", " .. (wasHovered and "true" or "false") .. ")")
		-- showButtons()
	-- elseif not isHovered and wasHovered then
		-- print("Stop hover")
		-- showButtons()
	-- end
	
	-- wasHovered = isHovered
-- end

-- local alphaMIN = 255*0.1
-- local alphaMAX = 255*0.8
-- local alpha = alphaMAX
-- local fade = false
-- local fadeSpeed = alpha/10
-- function showButtons()
	-- --print("Start showButtons...")
	
	-- if isHovered then
		-- print("showButtons isHovered")
		-- alpha = alphaMAX
		-- fade = false
	-- elseif alpha > alphaMIN then
		-- --print("showButtons alpha > alphaMIN")
		-- alpha = math.max(alpha-fadeSpeed,alphaMIN)
		-- fade = true
	-- else
		-- print("showButtons else")
		-- fade = false
	-- end
	
	-- for _, btn in ipairs(myButtons) do
		-- if btn.index == 1 then
			-- --print("Changing name")
			-- btn.font_color[4] = alpha/255
		-- else
			-- btn.font_color[4] = alpha
			-- self.editButton(btn)
		-- end
	-- end

	-- if fade then
		-- if fade then print ("Waiting...") end
		-- Wait.time(showButtons, 0.05)
	-- end
	-- print("End showButtons.")
-- end

local hideButtons = false
function toggleButtons()
	local globalHide = Global.getVar("GLOBAL_HIDE")
	local globalSet = Global.getVar("GLOBAL_SET")
	local myButtons = self.getButtons()
	if globalSet then
		hideButtons = globalHide
	else
		hideButtons = not hideButtons
	end
	--print("hideButtons = " ..(hideButtons and "true" or "false"))
	local alpha = rgb
	
	if hideButtons then
		alpha = 0
	end
	for i, btn in ipairs(myButtons) do
		btn.font_color = btn.font_color or {1,1,1,1}
		if i == 1 then --name
			local x = math.max((alpha/rgb), 0.8)
			btn.font_color[4] = x
		elseif i > 2 then --skip movement overlay
			local x = alpha
			btn.font_color[4] = x
		end
		self.editButton(btn)
	end
end

function updateContextMenu()
	clearContextMenu()
	--self.addContextMenuItem("TOGGLE UI", toggleButtons, true)
	if unitScript == 1 or (unitScript == 1 and unitType == 2) or unitScript == 4 then
		self.addContextMenuItem("Gun Smoke", spawnSmoke, true)
	end
	if unitScript == 1 then
		self.addContextMenuItem(">Battle Line", formLine, true)
		self.addContextMenuItem(">Attack Column", formAttack, true)
		self.addContextMenuItem(">Marching Column", formMarch, true)
		self.addContextMenuItem(">Square", formSquare, true)
		self.addContextMenuItem(">Detach Skirmishers", spawnSkirmisher, true)
	elseif unitScript == 2 then
		self.addContextMenuItem(">Attack Ranks", formAttack, true)
		self.addContextMenuItem(">Marching Column", formMarch, true)
		self.addContextMenuItem(">Detach Rider", spawnRider, true)
		if unitType == 2 then self.addContextMenuItem(">Detach Skirmishers", spawnSkirmisher, true) end
	elseif unitScript == 3 then
		self.addContextMenuItem("Gun Smoke", spawnSmoke, true)
        self.addContextMenuItem(">Unlimbered", setUnlimbered, true)
        self.addContextMenuItem(">Limbered", setLimbered, true)
        self.addContextMenuItem(">Defeated!", setDefeated, true)
        --self.addContextMenuItem("Toggle Rangefinder", toggleRange, true)
	elseif unitScript == 4 then
		self.addContextMenuItem(">Advance", formLine, true)
	end
	--self.addContextMenuItem("+ Strength", strUp, true)
	--self.addContextMenuItem("- Strength", strDown, true)
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
	
function myRot()
	local r = self.getRotation()
	return Vector(r.x, r.y, r.z)
end

function upright()
	local y = self.getRotation().y
	self.setRotation({0, y, 0})
end

function cycle(index, seq)
	if not seq or #seq == 0 then
		return 1
	end
	index = index or 0
	--print("cycling index to: " .. index)
	return (index % #seq)+1
end

function isEven(n)
    return n % 2 == 0
end

function isOdd(n)
    return n % 2 == 1
end

function coinflip()
	return math.random(2) == 1
end

function normalize(c)
    if c[1] > 1 then
        return {c[1]/255, c[2]/255, c[3]/255, (c[4] or 255)/255}
    end
    return c
end

function nameCheck()
	if name == self.getName() then return end
	name = self.getName()
	self.editButton({index = 0, label=name})
end

function createEmptyButton()
	self.createButton( {click_function = "nullFunction", function_owner = self, label = "", position = {0, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0, height = 0, font_size = 0, color = {0,0,0,0}, font_color = {0,0,0,0}, tooltip = ""} )
end

function printDebug()
	print("unitScript = " .. unitScript)
	print("formationVal = "..formationVal)
	-- print("advancing, direction, hasTurned = " .. (advancing and 'true' or 'false') .. ", " .. direction .. ", " .. (hasTurned and 'true' or 'false'))
	-- print("FormationOverlay = " .. (blockModel and 'true' or 'false'))
	-- print("faction = " .. faction)
	-- print("unitType = " .. unitType)
	print("----------")
end

function nullFunction()
--does nothing
end
]]

function onSave()
	return JSON.encode({
		unitData = unitData
	})
end

function onLoad(saved)
	print("Loading D6KS...")
	
	GLOBAL_HIDE, GLOBAL_TOGGLE = false, false
	
	if saved ~= "" then
		data = JSON.decode(saved)
		unitData = data.unitData or {}
	else
		unitData = {}
	end
	
	loadSharedScripts()
	loadUnits()
	
	print("D6KS loaded.")
end

function loadSharedScripts()
	for _, obj in ipairs(getAllObjects()) do
		if obj.hasTag("D6KS Infantry") or obj.hasTag("D6KS Cavalry") or obj.hasTag("D6KS Artillery") or obj.hasTag("D6KS Skirmisher") then
			loadUnitScript(obj)
		end
	end
	--print("Finished loadSharedScripts.")
end

function loadUnitScript(obj)
	if obj == nil then return end
    obj.setLuaScript(UNIT_LUA)
    obj.reload()  -- NECESSARY for script changes to run properly on save / load
	-- print("Script for " .. obj.getName() .. " updated.")
end

function storeUnitData(params)
	if debug_global then print("Storing unit data for " .. params.guid .. "...") end
    unitData[params.guid] = params.data
end

function getUnitData(guid)
	if debug_global then print("Getting unit data for " .. guid .. "...") end
    return unitData[guid]
end

-- function clearUnitData(guid)
	-- if debug_global then print("Clearing unit data for " .. guid .. "...") end
    -- unitData[guid] = nil
-- end

-- function pruneUnits()
    -- for guid in pairs(unitData) do
        -- if not getObjectFromGUID(guid) then
            -- unitData[guid] = nil
        -- end
    -- end
-- end

function loadUnits()
	allUnits = {}
	for _, obj in ipairs(getAllObjects()) do
		if obj.hasTag("D6KS Infantry") or obj.hasTag("D6KS Cavalry") or obj.hasTag("D6KS Artillery") or obj.hasTag("D6KS Skirmisher") then
			table.insert(allUnits, obj)
		end
	end
	--print("Finished loadUnits.")
end

-- TTS Scripting Hotkey Buttons
function onScriptingButtonDown(index, player_color) --function ran anytime player presses one of the bound scripting buttons
    local selectedObjects = Player[player_color].getSelectedObjects() --get all selected objects for player
    local hoveredObject = Player[player_color].getHoverObject()

	if index == 10 then 
		GLOBAL_HIDE = not GLOBAL_HIDE
		GLOBAL_SET = true
		print("Toggling all buttons = " .. (GLOBAL_HIDE and "hidden" or "visible"))
		if allUnits[1] ~= nil then --if there are objects in the table then
			for i in ipairs(allUnits) do --for every item in the table
				loadUnits()
				allUnits[i].call('toggleButtons') --if the function exists then we can call it
			end
		GLOBAL_SET = false
		else print("allUnits is empty!")
		end
	elseif index == 1 then
		if selectedObjects[1] ~= nil then --if there are objects in the table then
			for i in ipairs(selectedObjects) do --for every item in the table
				if selectedObjects[i].getVar("unitScript") ~= 3 then
					selectedObjects[i].call('formLine') --if the function exists then we can call it
				else selectedObjects[i].call('setUnlimbered')
				end						
			end
		else --if there are no selected objects, then we run the hover function
			if hoveredObject ~= nil and hoveredObject.getVar("formLine") ~= nil then hoveredObject.call('formLine') end --check there is a hovered object and that it has the appropriate function
		end
   elseif index == 2 then
		if selectedObjects[1] ~= nil then
			for i in ipairs(selectedObjects) do
				if selectedObjects[i].getVar("unitScript") ~= 3 then
					selectedObjects[i].call('formAttack')
				else selectedObjects[i].call('setUnlimbered')
				end
			end
		else
			if hoveredObject ~= nil and hoveredObject.getVar("formAttack") ~= nil then hoveredObject.call('formAttack') end
		end
	elseif index == 3 then
		if selectedObjects[1] ~= nil then
			for i in ipairs(selectedObjects) do
				if selectedObjects[i].getVar("unitScript") ~= 3 then
					selectedObjects[i].call('formMarch')
				else selectedObjects[i].call('setLimbered')
				end
			end
		else
			if hoveredObject ~= nil and hoveredObject.getVar("formMarch") ~= nil then hoveredObject.call('formMarch') end
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
			if hoveredObject ~= nil and hoveredObject.getVar("formSquare") ~= nil then hoveredObject.call('formSquare') end
		end
	end
end