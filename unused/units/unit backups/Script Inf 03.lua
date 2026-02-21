-----------------------------------------------------------------------------------
---adjust these values to set labels, and minimum/maximum values on the counters---
-----------------------------------------------------------------------------------
nameColor = 'White' --what color do you want the piece Name to be?

createCounter1 = false
counter1 = "Ammo" --what you want to track on Counter #1
ctr1Color = 'White' --what color do you want the counter text to be?
MIN_CTR1 = 0 --minimum amount allowed for Counter #1
MAX_CTR1 = 10 --maximum amount allowed for Counter #1
spawnButton1 = true --do you want to spawn SMOKE token when pressed? true/false

createCounter2 = false
counter2 = "Morale" --what you want to track on Counter #2
ctr2Color = 'White' --what color do you want the counter text to be?
MIN_CTR2 = 0 --minimum amount allowed for Counter #2
MAX_CTR2 = 2 --maximum amount allowed for Counter #2						 

createCounter3 = true
counter3 = "Strength" --what you want to track on Counter #3
ctr3Color = 'White' --what color do you want the counter text to be?
MIN_CTR3 = 0 --minimum amount allowed for Counter #3
MAX_CTR3 = 25 --maximum amount allowed for Counter #3
--### adjust counter3 to smallest size in TTS before editing SMALL_CTR3 or MED_CTR3
--### or you might end up with undesired results ----------------------------------
SMALL_CTR3 = 6 --maximum value for a small block
MEDIUM_CTR3 = 12 --maximum value for a medium block
BIG_CTR3 = 20 --maximum value for an oversized block
spawnButton3 = true --do you want to spawn SKIRMISH token when pressed? true/false
lineSmoke = true --do you want the Line formation button to also spawn SMOKE?

createCohesion = true
cohesion = ''
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

formLine = {index = 4, click_function = "nullFunction", function_owner = self, label = "", position = {1, 0.25, 0.25},	rotation = {0, 0, 0}, scale = {2, 2, 2}, width = 0, height = 0, font_size = 160, font_color = {1, 1, 1, 1}}

formSquare = {index = 4, click_function = "nullFunction", function_owner = self, label = "■", positiofn = {0, 0.26, 0.1}, rotation = {0, 0, 0}, scale = {3, 3, 3}, width = 150, height = 150, font_size = 250, font_color = {1,1,1,127}, color = {0,0,0,0}}

formMarchL = {index = 4, click_function = "nullFunction", function_owner = self, label = "◄         ◄◄◄", position = {1.2, 0.23, 0.25},	rotation = {0, 0, 0}, scale = {4, 4, 4}, width = 0, height = 0, font_size = 160, font_color = {1,1,1,1}, color = {0,0,0,1}}
formMarchR = {index = 4, click_function = "nullFunction", function_owner = self, label = "◄         ◄◄◄", position = {-1.2, 0.23, 0.25}, rotation = {0, 180, 0}, scale = {4, 4, 4}, width = 0, height = 0, font_size = 160, font_color = {1,1,1,1}, color = {0,0,0,1}}

formAssaultL = {index = 4, click_function = "nullFunction", function_owner = self, label = "↑A↑", position = {-2, 0.25, 0.25}, rotation = {0, -90, 0}, scale = {2, 2, 2}, width = 0, height = 0, font_size = 200, font_color = {1,0,0,1}, color = {0,0,0,1}}
formAssaultR = {index = 4, click_function = "nullFunction", function_owner = self, label = "↑A↑", position = {2, 0.25, 0.25}, rotation = {0, 90, 0}, scale = {2, 2, 2}, width = 0, height = 0, font_size = 200, font_color = {1,0,0,1}, color = {0,0,0,1}}

---------------------------------------------------------------------------
---------------------------------------------------------------------------
---######### altering any code below this is at your own risk! #########---
---------------------------------------------------------------------------
---------------------------------------------------------------------------

---initial values---ignore these---
name = "Unit Name"
ctr1 = '0'
ctr2 = '0'
ctr3 = '1'
formON = {1, 0, 0, 1}
formOFF = {0, 0, 0, 1}
function nullFunction() --does nothing. Exists merely as a background for counters
end
---------------------------------------------------------------------------


---------------------------------------------------------------------------
---don't mess with this section---
---------------------------------------------------------------------------
function onSave()
    --We make a table of data we want to save. WE CAN ONLY SAVE 1 TABLE.
    local data_to_save = {
      name=name,
      ctr1=ctr1,
      ctr2=ctr2,
      ctr3=ctr3,
	  cohesion=cohesion;
      currentForm=currentForm,}
    --We use this command to convert the table into a string
    saved_data = JSON.encode(data_to_save)
    --And this inserts the string into the save information for this script.
    return saved_data
    --Data is now saved.
end

--Runs when the map is first loaded
function onload(saved_data)
    --First we check if there was information saved in this script yet
    if saved_data ~= "" then
        --If there is save data, first we convert the string back to a table
        local loaded_data = JSON.decode(saved_data)
        --Then we pull out data out of the table
        ctr1 = loaded_data.ctr1
        ctr2 = loaded_data.ctr2
        ctr3 = loaded_data.ctr3
        cohesion = loaded_data.cohesion
        name = loaded_data.name
        currentForm = loaded_data.currentForm
    end
  CheckButtons()
  CreateButtons()
  updateForm()
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
function CheckButtons()
	btnLine = formOFF
	btnSquare = formOFF
	btnColumn = formOFF
	btnAssault = formOFF
	if currentForm == nil then currentForm = 1 end
	if cohesion == nil then cohesion = 3 end
	if currentForm == 1 then btnLine = 'Red'
		elseif currentForm == 2 then btnSquare = 'Red'
		elseif currentForm == 3 then btnColumn = 'Red'
		elseif currentForm == 4 then btnAssault = 'Red'
	end
end

function CreateButtons()
----------------------------------
----- front/counter displays -----
----------------------------------

--Unit Name front display
self.createButton({index = 0, click_function = "nullFunction", function_owner = self,
  label = name, position = {0, 0.26, -0.7}, scale = {1, 1, 1}, width = 0,
  height = 0, font_size = 225, font_color = nameColor})

--- adjusts the Unit Name input box ---
self.createInput({value = name, input_function = "editName", label = "Unit", function_owner = self,
    alignment = 3, position = {0,0,-0.7}, rotation = {0, 0, 180}, width = 600, height = 110,
    font_size = 85, scale={x=1.5, y=1.5, z=1.5}, font_color= {1,1,1,1}, color = {0.1,0.1,0.1,1}})

--Counter #1 display on the back
if createCounter1 then
	self.createButton({index = 1, click_function = "spawnSmoke", function_owner = self,
	  label = ctr1, position = {1, 0, 0}, rotation = {0, 0, 180}, scale = {2.5, 2.5, 2.5}, width = 180,
	  height = 160, font_size = 160, font_color = ctr1Color, color = {0, 0, 0}, tooltip = counter1})
else
	self.createButton({index = 1, click_function = "nullFunction", function_owner = self,
	  label = ctr1, position = {1, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0,
	  height = 0, font_size = 0, font_color = ctr1Color, color = {0, 0, 0}, tooltip = counter1})
end

--Counter #2 display on the back
if createCounter2 then
	self.createButton({index = 2, click_function = "nullFunction", function_owner = self,
	  label = ctr2, position = {0, 0, 0}, rotation = {0, 0, 180}, scale = {2.5, 2.5, 2.5}, width = 180,
	  height = 160, font_size = 160, font_color = ctr2Color, color = {0, 0, 0}, tooltip = counter2})
else
	self.createButton({index = 2, click_function = "nullFunction", function_owner = self,
	  label = ctr2, position = {1, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0,
	  height = 0, font_size = 0, font_color = ctr2Color, color = {0, 0, 0}, tooltip = counter2})
end

--Counter #3 on the back
if createCounter3 then
	self.createButton({index = 3, click_function = "ctr3Button", function_owner = self,
	  label = ctr3, position = {0, 0, 0}, rotation = {0, 0, 180}, scale = {2.5, 2.5, 2.5}, width = 180,
	  height = 160, font_size = 160, font_color = ctr3Color, color = {0, 0, 0}, tooltip = counter3})
	-- original position = {-1, 0, 0}
else
	self.createButton({index = 3, click_function = "nullFunction", function_owner = self,
	  label = ctr3, position = {1, 0, 0}, rotation = {0, 0, 0}, scale = {0, 0, 0}, width = 0,
	  height = 0, font_size = 0, font_color = ctr3Color, color = {0, 0, 0}, tooltip = counter3})
end

--Formation front display
if currentForm == nil then currentForm = 1 end
if currentForm == 1 then
	self.createButton(formLine)
elseif currentForm == 2 then
	self.createButton(formSquare)
elseif currentForm == 3 then
	if direction == 1 then self.createButton(formMarchL) else self.createButton(formMarchR) end
elseif currentForm == 4 then
	if direction == 1 then self.createButton(formAssaultL) else self.createButton(formAssaultR) end
end

----------------------------------------------------------------
-------- creates the buttons to switch formation images --------
----------------------------------------------------------------
self.createButton({index = 5, click_function = "setLine",
	function_owner = self, label = "L", position = {1.45, 0, -0.7}, rotation = {0, 0, 180}, scale = {1.8, 1.8, 1.8}, width = 100, height = 80, font_size = 70, color = btnLine, font_color = {1, 1, 1, 1},
	tooltip = "Form Line"})

self.createButton({index = 6, click_function = "setSquare",
    function_owner = self, label = "S", position = {1.1, 0, -0.7}, rotation = {0, 0, 180}, scale = {1.8, 1.8, 1.8}, width = 100, height = 80, font_size = 70, color = btnSquare, font_color = {1, 1, 1, 1},
    tooltip = "Form Square"})

self.createButton({index = 7, click_function = "setColumn",
    function_owner = self, label = "C", position = {-1.1, 0, -0.7}, rotation = {0, 0, 180}, scale = {1.8, 1.8, 1.8}, width = 100, height = 80, font_size = 70, color = btnColumn, font_color = {1, 1, 1, 1},
    tooltip = "Marching Column"})

self.createButton({index = 8, click_function = "setAssault",
    function_owner = self, label = "A", position = {-1.45, 0, -0.7}, rotation = {0, 0, 180}, scale = {1.8, 1.8, 1.8}, width = 100, height = 80, font_size = 70, color = btnAssault, font_color = {1, 1, 1, 1},
    tooltip = "Assault Column"})

-----------------------------
--- edits the +/- buttons ---
-----------------------------

--- adjusts ctr1 ---
if createCounter1 then
	self.createButton({click_function = "ctr1up", function_owner = self, label = "+",
	  position = {0.8, 0, 0.6}, rotation = {0, 0, 180}, scale = {3, 3, 3},
	  width = 80, height = 80, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = "+"})
	self.createButton({click_function = "ctr1dn", function_owner = self, label = "-",
	  position = {1.2, 0, 0.6}, rotation = {0, 0, 180}, scale = {3, 3, 3},
	  width = 80, height = 80, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = "-"})
end

--- adjusts ctr2 ---
if createCounter2 then
	self.createButton({click_function = "ctr2up", function_owner = self, label = "+",
	  position = {-0.2, 0, 0.6}, rotation = {0, 0, 180}, scale = {3, 3, 3},
	  width = 80, height = 80, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = "+"})
	self.createButton({click_function = "ctr2dn", function_owner = self, label = "-",
	  position = {0.2, 0, 0.6}, rotation = {0, 0, 180}, scale = {3, 3, 3},
	  width = 80, height = 80, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = "-"})
end

--- adjusts ctr3 ---
if createCounter3 then
	self.createButton({click_function = "ctr3up", function_owner = self, label = "+",
	  position = {-0.2, 0, 0.6}, rotation = {0, 0, 180}, scale = {3, 3, 3},
	  width = 80, height = 80, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = "+"})
	-- original position = {-1.2, 0, 0.6}
	self.createButton({click_function = "ctr3dn", function_owner = self, label = "-",
	  position = {0.2, 0, 0.6}, rotation = {0, 0, 180}, scale = {3, 3, 3},
	  width = 80, height = 80, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = "-"})
	-- original position = {-0.8, 0, 0.6}
end
  
--Cohesion display on the front
if createCohesion then
	self.createButton({click_function = "setCohesion", function_owner = self,
	  label = cohesionLabel3, position = {0, 0.26, 0.6}, rotation = {0, 0, 0}, scale = {2.5, 2.5, 2.5}, width = 180,
	  height = 110, font_size = 150, color = {0,0,0,0}, font_color = cohesionColor3, tooltip = cohesionTooltip3})
end

end --end button creation

-----------------
--- functions ---
-----------------

function updateForm()
	--formation
	if currentForm == 1 then
		self.editButton(formLine)
	elseif currentForm == 2 then
		self.editButton(formSquare)
	elseif currentForm == 3 then
		if direction == 1 then self.editButton(formMarchL) else self.editButton(formMarchR) end
	else
		if direction == 1 then self.editButton(formAssaultL) else self.editButton(formAssaultR) end
	end

	--line / smoke check
	if currentForm == 1 then
		self.editButton({index = 5, label = "F", font_color = 'Yellow', tooltip = "Fire!"})
	else
		self.editButton({index = 5, label = "L", font_color = 'White', tooltip = "Form Line"})
	end

	--button colors
	if currentForm == 1 then self.editButton({index = 5, color = formON}) else self.editButton({index = 5, color = formOFF}) end
	if currentForm == 2 then self.editButton({index = 6, color = formON}) else self.editButton({index = 6, color = formOFF}) end
	if currentForm == 3 then self.editButton({index = 7, color = formON}) else self.editButton({index = 7, color = formOFF}) end
	if currentForm == 4 then self.editButton({index = 8, color = formON}) else self.editButton({index = 8, color = formOFF}) end
	
	--cohesion
	if cohesion == 3 then
		self.editButton({index = 11, label = cohesionLabel3, font_color = cohesionColor3, tooltip = cohesionTooltip3})
	elseif cohesion == 2 then
		self.editButton({index = 11, label = cohesionLabel2, font_color = cohesionColor2, tooltip = cohesionTooltip2})
	elseif cohesion == 1 then
		self.editButton({index = 11, label = cohesionLabel1, font_color = cohesionColor1, tooltip = cohesionTooltip1})
	else
		self.editButton({index = 11, label = cohesionLabel0, font_color = cohesionColor0, tooltip = cohesionTooltip0})
	end
end

function setCohesion(obj, color, alt_click)
	if alt_click then
		if cohesion >= cohesionMAX then cohesion=cohesionMIN else cohesion=cohesion+1 end
	else
		if cohesion <= cohesionMIN then cohesion=cohesionMAX else cohesion=cohesion-1 end
	end
	updateForm()
end

function resizeLine()
	-- self.scale({x=2, y=1, z=0.625})
end

function resizeColumn()
	-- self.scale({x=0.5, y=1, z=1.6})
end

function setLine()
	-- print("Form line!")
	if currentForm == 1 then spawnSmoke() end
	currentForm = 1
	updateForm()
end

function setSquare()
	if currentForm == 1 then resizeColumn() end
	-- print("Form square!")
	currentForm = 2
	updateForm()
end

direction = 0 --left = 0, right = 1
function setColumn()
	if currentForm == 3 then direction = 1-direction end
	if currentForm == 1 then resizeColumn() end
	-- print("Form Marching Column!")
	currentForm = 3
	updateForm()
end

function setAssault()
	if currentForm == 4 then direction = 1-direction end
	if currentForm == 1 then resizeColumn() end
	-- print("Form Assault Column!")
	currentForm = 4
	updateForm()
end

function editName(_obj, _string, value)
    name = value,
    self.editButton({index=0, label=name})
end

function spawnSmoke() --spawns smoke token
  if spawnButton1 then
  local myPosition = tokenPosition()
  local myRotation = self.getRotation()
    spawnparams = {
      type = 'Custom_Token',
      position          = myPosition,
      rotation          = myRotation,
      scale             = {x=0.28, y=1, z=0.28},
      snap_to_grid      = false,
    }
    object = spawnObject(spawnparams)
    params = {
      image = "https://steamusercontent-a.akamaihd.net/ugc/1481075842950556808/2DE0FF15A0E6E6BFF9D51A3743309F97A030D5E3/",
      thickness = 0.1,
    }
    object.setCustomObject(params)
    ctr1dn()
  end
end

function ctr3Button() --spawns skirmisher
  if spawnButton3 then
  myPosition = tokenPosition()
  myRotation = self.getRotation()
  myColorTint = self.getColorTint()
    spawnparams = {
      type = 'Custom_Tile',
      position          = myPosition,
      rotation          = myRotation,
      colortint         = myColorTint,
      scale             = {x=0.18, y=1, z=0.26},
      snap_to_grid      = false,
    }
    object = spawnObject(spawnparams)
    params = {
      image= "https://steamusercontent-a.akamaihd.net/ugc/1820019631646942560/64338BB983E9E8FC058284FEF228FD727DFEDCBC/",
      thickness = 0.125,
    }
    object.setName(name)
    object.setColorTint(myColorTint)
    object.setCustomObject(params)
  end
end

function tokenPosition()
  local x = 0
  local y = -0.25
  local z = -1.75
  return self.positionToWorld({x,y,z})
end

------------------------------------------------------------------------------
------ counter buttons below -------------------------------------------------
------------------------------------------------------------------------------
------ change the (+1) value if you wish to adjust steps by more than 1 ------
------ for example: edit ctr3=ctr3+1 to ctr3=ctr3+5 if you want each step   ------
------              to increase the Manpower by 5 with each "+" click   ------
------------------------------------------------------------------------------
------ To set minimum or maximum values on the counters, adjust the     ------
------      MIN_XXX or MAX_XXX values at the top of the script          ------
------------------------------------------------------------------------------
function ctr1up()  if ctr1 == nil then ctr1 = 0 end
  ctr1=ctr1+1
  if ctr1 >= MAX_CTR1 then ctr1 = MAX_CTR1 print("Max ", counter1) end
  print(ctr1, " ", counter1)
--  self.editButton({index=1, label=ctr1})
  self.editButton({index=1, label=ctr1}) end
function ctr1dn()  if ctr1 == nil then ctr1 = 0 end
  ctr1=ctr1-1
  if ctr1 <= MIN_CTR1 then
	ctr1 = MIN_CTR1 print(counter1, " Depleted")
	end
  print(ctr1, " ", counter1)
--  self.editButton({index=1, label=ctr1})
  self.editButton({index=1, label=ctr1}) end
function ctr2up()  if ctr2 == nil then ctr2 = 0 end
  ctr2=ctr2+1
  if ctr1 >= MIN_CTR1 then
	self.editButton({index = 4, function_owner = self, label = "", position = {0, 0.26, 0.25}, rotation = {0, 15, 0}, scale = {3, 3, 3}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}})
    print("Rallied!")
  end
  if ctr2 >= MAX_CTR2 then ctr2 = MAX_CTR2 print("Max ", counter2) end
  print(ctr2, " ", counter2)
--  self.editButton({index=3, label=ctr2})
  self.editButton({index=2, label=ctr2}) end
function ctr2dn()  if ctr2 == nil then ctr2 = 0 end
  ctr2=ctr2-1
  if ctr2 <= MIN_CTR2 then
	self.editButton({index = 4, function_owner = self, label = "Broken", position = {0, 0.26, 0.25}, rotation = {0, 15, 0}, scale = {3, 3, 3}, width = 0, height = 0, font_size = 200, font_color = {1,1,1,1}, color = {0,0,0,1}}) print("Broken!")
	
	ctr2 = MIN_CTR2 print(counter2, " Depleted")
	end
  print(ctr2, " ", counter2)
--  self.editButton({index=3, label=ctr2})
  self.editButton({index=2, label=ctr2}) end
------------------------------------------------------------------------------
------ To turn the piece re-scale OFF, put TWO DASHES (--) in front of  ------
------   the lines of the following code that say self.scale:                             ------
----- if ctr3 == 3 then                                                 ------
-->>>  self.scale(1.25)                                                ------
----- elseif ctr3 == 5 then                                             ------
-->>>  self.scale(1.25)                                                ------
----- end                                                              ------
------                                                                  ------
----- if ctr3 == 4 then                                                 ------
-->>>  self.scale(0.8)                                                 ------
----- elseif ctr3 == 2 then                                             ------
-->>>  self.scale(0.8)                                                 ------
----- end                                                              ------
------------------------------------------------------------------------------
function ctr3up()  if ctr3 == nil then ctr3 = 0 end
  if ctr3 == SMALL_CTR3 then
    ctr3=ctr3+1
    self.scale(1.25)
  elseif ctr3 == MEDIUM_CTR3 then
    ctr3=ctr3+1
    self.scale(1.25)
  elseif ctr3 == BIG_CTR3 then
    ctr3=ctr3+1
    self.scale(1.25)
  elseif ctr3 >= MAX_CTR3 then ctr3 = MAX_CTR3 print("Max ", counter3)
  else ctr3=ctr3+1 end
  print(ctr3, " ", counter3)
  self.editButton({index=3, label=ctr3}) end
function ctr3dn()  if ctr3 == nil then ctr3 = 0 end
  if ctr3-1 == SMALL_CTR3 then
    ctr3=ctr3-1
    self.scale(0.8)
  elseif ctr3-1 == MEDIUM_CTR3 then
    ctr3=ctr3-1
    self.scale(0.8)
  elseif ctr3-1 == BIG_CTR3 then
    ctr3=ctr3-1
	self.scale(0.8)
  elseif ctr3 <= MIN_CTR3 then ctr3 = MIN_CTR3 print(counter3, " Depleted")
  else ctr3=ctr3-1 end
  self.editButton({index=3, label=ctr3}) end