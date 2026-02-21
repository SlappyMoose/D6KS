-----------------------------------------------------------------------------------
---adjust these values to set labels, and minimum/maximum values on the counters---
-----------------------------------------------------------------------------------
nameColor = 'White' --what color do you want the piece Name to be?

counter1 = "Ammo" --what you want to track on Counter #1
MIN_CTR1 = 0 --minimum amount allowed for Counter #1
MAX_CTR1 = 10 --maximum amount allowed for Counter #1
ctr1Color = 'White' --what color do you want the counter text to be?
spawnButton1 = true --do you want to spawn smoke token when pressed? true/false

counter2 = "Morale" --what you want to track on Counter #2
MIN_CTR2 = 0 --minimum amount allowed for Counter #2
MAX_CTR2 = 10 --maximum amount allowed for Counter #2
ctr2Color = 'White' --what color do you want the counter text to be?

counter3 = "Manpower" --what you want to track on Counter #3
MIN_CTR3 = 0 --minimum amount allowed for Counter #3
MAX_CTR3 = 10 --maximum amount allowed for Counter #3
ctr3Color = 'White' --what color do you want the counter text to be?
SMALL_CTR3 = 3 --maximum value for a small block
MEDIUM_CTR3 = 6 --maximum value for a medium block
BIG_CTR3 = 10 --maximum value for an oversized block
spawnButton3 = true --do you want to spawn VEDETTE token when pressed? true/false
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
      currentForm=currentForm,
      currentState=currentState,}
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
        name = loaded_data.name
        currentForm = loaded_data.currentForm
        currentState = loaded_data.currentState
    end

--function onLoad()
  CheckButtons()
  CreateButtons()
end
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
function CheckButtons()
  btnLine = formOFF
  btnColumn = formOFF
  btnFresh = formOFF
  btnSpent = formOFF
  if currentForm == nil then currentForm = 1 end
    if currentForm == 1 then btnLine = 'Red'
    elseif currentForm == 2 then btnColumn = 'Red'
  end
  if currentState == nil then currentState = 1 end
    if currentState == 1 then btnFresh = 'Red'
    elseif currentState == 2 then btnSpent = 'Red'
  end
end

function CreateButtons()
----------------------------------
----- front/counter displays -----
----------------------------------

--Unit Name front display
local data = {click_function = "nullFunction", index = 0, function_owner = self,
  label = name, position = {0, 0.26, -0.7}, scale = {1, 1, 1}, width = 0,
  height = 0, font_size = 200, font_color = {1, 1, 1, 1}}
self.createButton(data)

--Counter #1 on the back
local data = {click_function = "ctr1Button", index = 1, function_owner = self,
  label = ctr1, position = {0.65, 0, -0.1}, rotation = {0, 0, 180}, scale = {2.5, 2.5, 2.5}, width = 130,
  height = 130, font_size = 150, font_color = {1, 1, 1, 1}, color = {0, 0, 0, 1}, tooltip = counter1}
self.createButton(data)

--Counter #2 on the back
local data = {click_function = "nullFunction", index = 2, function_owner = self,
  label = ctr2, position = {0, 0, -0.1}, rotation = {0, 0, 180}, scale = {2.5, 2.5, 2.5}, width = 130,
  height = 130, font_size = 150, font_color = {1, 1, 1, 1}, color = {0, 0, 0, 1}, tooltip = counter2}
self.createButton(data)

--Counter #3 on the back
local data = {click_function = "ctr3Button", index = 3, function_owner = self,
  label = ctr3, position = {-0.65, 0, -0.1}, rotation = {0, 0, 180}, scale = {2.5, 2.5, 2.5}, width = 130,
  height = 130, font_size = 150, font_color = {1, 1, 1, 1}, color = {0, 0, 0, 1}, tooltip = counter3}
self.createButton(data)

--Formation front display
if currentForm == nil then currentForm = 1 end
  if currentForm == 1 then
    self.createButton({click_function = "nullFunction", index = 4, function_owner = self, label = "", position = {0.82, 0, -0.73},
     rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 0, height = 0, font_size = 70, font_color = {1, 1, 1, 1}})
  elseif currentForm == 2 then
    self.createButton({click_function = "nullFunction", index = 4, function_owner = self, label = "◄      ◄◄", position = {-0.12, 0.23, 0.7},
     rotation = {0, 90, 0}, scale = {4, 4, 4}, width = 0, height = 0, font_size = 160, font_color = {1,1,1,1}, color = {0,0,0,1}})
  end

--Cohesion front display
if currentState == nil then currentState = 1 end
  if currentState == 1 then
    self.createButton({click_function = "nullFunction", index = 5, function_owner = self, label = "", position = {0.82, 0, -0.73},
    rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 0, height = 0, font_size = 70, font_color = {1, 1, 1, 1}, color = {0,0,0,1}})
  elseif currentState == 2 then
    self.createButton({click_function = "nullFunction", index = 5, function_owner = self, label = "S", alignment = 3, position = {0.5, 0.25, 0.5},
    rotation = {0, 0, 0}, scale = {4, 4, 4}, width = 100, height = 100, font_size = 100, font_color = {0,0,0,1}, color = {1,1,1,1}})
  end

----------------------------------------------------------------
-------- creates the buttons to switch formation images --------
----------------------------------------------------------------
local data = {click_function = "setLine", index = 6,
    function_owner = self, label = "L", position = {0.82, 0, -0.85},
    rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 100, height = 100,
    font_size = 70, color = btnLine, font_color = {1, 1, 1, 1},
    tooltip = "Line"}
self.createButton(data)

local data = {click_function = "setColumn", index = 7,
    function_owner = self, label = "C", position = {0.82, 0, -0.60},
    rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 100, height = 100,
    font_size = 70, color = btnColumn, font_color = {1, 1, 1, 1},
    tooltip = "Column March"}
self.createButton(data)

local data = {click_function = "setFresh", index = 8,
    function_owner = self, label = "F", position = {-0.82, 0, -0.85},
    rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 100, height = 100,
    font_size = 70, color = btnFresh, font_color = {1, 1, 1, 1},
    tooltip = "Fresh"}
self.createButton(data)

local data = {click_function = "setSpent", index = 9,
    function_owner = self, label = "S", position = {-0.82, 0, -0.60},
    rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 100, height = 100,
    font_size = 70, color = btnSpent, font_color = {1, 1, 1, 1},
    tooltip = "Spent"}
self.createButton(data)


-----------------------------
--- edits the +/- buttons ---
-----------------------------

--- adjusts ctr1 ---
local data = {click_function = "ctr1up", function_owner = self, label = "+",
  position = {0.65, 0, 0.4}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  width = 70, height = 70, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = counter1}
self.createButton(data)
local data = {click_function = "ctr1dn", function_owner = self, label = "-",
  position = {0.65, 0, 0.75}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  width = 70, height = 70, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = counter1}
self.createButton(data)

--- adjusts ctr2 ---
local data = {click_function = "ctr2up", function_owner = self, label = "+",
  position = {0, 0, 0.4}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  width = 70, height = 70, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = counter2}
self.createButton(data)
local data = {click_function = "ctr2dn", function_owner = self, label = "-",
  position = {0, 0, 0.75}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  width = 70, height = 70, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = counter2}
self.createButton(data)

--- adjusts ctr3 ---
local data = {click_function = "ctr3up", function_owner = self, label = "+",
  position = {-0.65, 0, 0.4}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  width = 70, height = 70, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = counter3}
self.createButton(data)
local data = {click_function = "ctr3dn", function_owner = self, label = "-",
position = {-0.65, 0, 0.75}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  position = {-0.65, 0, 0.75}, rotation = {0, 0, 180}, scale = {3, 3, 3},
  width = 70, height = 70, font_size = 70, color = {0, 0, 0, 1}, font_color = {1, 1, 1, 1}, tooltip = counter3}
self.createButton(data)

--- adjusts the Unit Name input box ---
self.createInput({value = name, input_function = "editName", label = "Unit", function_owner = self,
    alignment = 3, position = {0,0,-0.73}, rotation = {0, 0, 180}, width = 450, height = 110,
    font_size = 85, scale={x=1.5, y=1.5, z=1.5}, font_color= {1,1,1,1}, color = {0,0,0,1}})

end --end button creation

-----------------
--- functions ---
-----------------
function setLine()
  currentForm = 1
  self.editButton({index = 4, function_owner = self, label = "", position = {0.82, 0, -0.73},
  rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 0, height = 0, font_size = 70, font_color = {1, 1, 1, 1}})
  print("Form Line!")
  self.editButton({index = 6, color = formON})
  self.editButton({index = 7, color = formOFF})
end

function setColumn()
  currentForm = 2
  self.editButton({index = 4, function_owner = self, label = "◄      ◄◄", position = {-0.12, 0.23, 0.7},
  rotation = {0, 90, 0}, scale = {4, 4, 4}, width = 0, height = 0, font_size = 160, font_color = {1,1,1,1}, color = {0,0,0,1}})
print("Column march!")
self.editButton({index = 6, color = formOFF})
self.editButton({index = 7, color = formON})
end

function setFresh()
  currentState = 1
  self.editButton({index = 5, function_owner = self, label = "", position = {0.82, 0, -0.73},
  rotation = {0, 0, 180}, scale = {1.5, 1.5, 1.5}, width = 0, height = 0, font_size = 70, font_color = {1, 1, 1, 1}, color = {0,0,0,1}})
  print("Re-form!")
  self.editButton({index = 8, color = formON})
  self.editButton({index = 9, color = formOFF})
end

function setSpent()
  currentState = 2
  self.editButton({index = 5, function_owner = self, label = "S", alignment = 3, position = {0.5, 0.25, 0.5},
  rotation = {0, 0, 0}, scale = {4, 4, 4}, width = 100, height = 100, font_size = 100, font_color = {0,0,0,1}, color = {1,1,1,1}})
print("Unit is spent")
self.editButton({index = 8, color = formOFF})
self.editButton({index = 9, color = formON})
end



function editName(_obj, _string, value)
    name = value,
    self.editButton({index=0, label=name})
end

function ctr1Button() --spawn gun smoke
  if spawnButton1 then
    local myPosition = tokenPosition()
    local myRotation = self.getRotation()
    spawnparams = {
      type = 'Custom_Token',
      position          = myPosition,
      rotation          = myRotation,
      scale             = {x=0.2, y=1, z=0.2},
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

function ctr3Button() --spawn vedette
  if spawnButton3 then
    local myPosition = tokenPosition()
    local myRotation = self.getRotation()
    local myColorTint = self.getColorTint()
    spawnparams = {
      type = 'Custom_Tile',
      position          = myPosition,
      rotation          = myRotation,
      colortint         = myColorTint,
      scale             = {x=0.35, y=1, z=0.35},
      snap_to_grid      = false,
    }
    object = spawnObject(spawnparams)
    params = {
      image = "https://steamusercontent-a.akamaihd.net/ugc/1820019631647070682/C15BC217C7E7024F004CDF458EF7DBB8A7564A5D/",
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
  local z = -1.6
  return self.positionToWorld({x,y,z})
end
------------------------------------------------------------------------------
------------------------------------------------------------------------------




------------------------------------------------------------------------------
------ counter buttons below -------------------------------------------------
------------------------------------------------------------------------------
------ change the (+1) value if you wish to adjust steps by more than 1 ------
------ for example: edit ctr3=ctr3+1 to ctr3=ctr3+5 if you want each step   ------
------              to increase Counter # 3 by 5 with each "+" click   ------
------------------------------------------------------------------------------
------ To set minimum or maximum values on the counters, adjust the     ------
------      MIN_XXX or MAX_XXX values at the top of the script          ------
------------------------------------------------------------------------------
function ctr1up()  if ctr1 == nil then ctr1 = 0 end
  ctr1=ctr1+1
  if ctr1 >= MAX_CTR1 then ctr1 = MAX_CTR1 print("Max ", counter1) end
  print(ctr1, " ", counter1)
  self.editButton({index=1, label=ctr1}) end
function ctr1dn()  if ctr1 == nil then ctr1 = 0 end
  ctr1=ctr1-1
  if ctr1 <= MIN_CTR1 then ctr1 = MIN_CTR1 print(counter1, " Depleted") end
  print(ctr1, " ", counter1)
  self.editButton({index=1, label=ctr1}) end
function ctr2up()  if ctr2 == nil then ctr2 = 0 end
  ctr2=ctr2+1
  if ctr2 >= MAX_CTR2 then ctr2 = MAX_CTR2 print("Max ", counter2) end
  print(ctr2, " ", counter2)
  self.editButton({index=2, label=ctr2}) end
function ctr2dn()  if ctr2 == nil then ctr2 = 0 end
  ctr2=ctr2-1
  if ctr2 <= MIN_CTR2 then ctr2 = MIN_CTR2 print(counter2, " Depleted") end
  print(ctr2, " ", counter2)
  self.editButton({index=2, label=ctr2}) end
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