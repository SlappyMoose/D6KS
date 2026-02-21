
-- JENA -- Blue Infantry -- v0.32 -- 12/10/24
-- Damon A. Mosier -- International Kriegsspiel Society

steps = 6
max_steps = 6
min_steps = 0

function onSave()
    --We make a table of data we want to save. WE CAN ONLY SAVE 1 TABLE.
    local data_to_save = {
      steps=steps
        }
    --We use this command to convert the table into a string
    saved_data = JSON.encode(data_to_save)
    --And this inserts the string into the save information for this script.
    return saved_data
    --Data is now saved.
end

--Runs when the map is first loaded
function onLoad(saved_data)
    --First we check if there was information saved in this script yet
    if saved_data ~= "" then
        --If there is save data, first we convert the string back to a table
        local loaded_data = JSON.decode(saved_data)
        --Then we pull out data out of the table
        steps = loaded_data.steps
    end
    --now we will add the context menu items
    self.addContextMenuItem("SPAWN", nullFunction)
    self.addContextMenuItem("   Gun Smoke", spawnSmoke)
    self.addContextMenuItem("   Skirmishers", spawnSkirmishers)
    self.addContextMenuItem("FRONTAGE *", printStep)
    self.addContextMenuItem("   Increase +", addSteps)
    self.addContextMenuItem("   Reduce -", reduceSteps)
    self.addContextMenuItem("FORMATIONS", nullFunction)
    self.addContextMenuItem("   Battle Line", setLine)
    self.addContextMenuItem("   Assault Column", setColumn)
    self.addContextMenuItem("   Form Square", setSquare)
end

function spawnSmoke()
  spawnSmokeLeft()
  spawnSmokeRight()
end

function spawnSmokeLeft() --spawns smoke token
  local myPosition = leftPosition()
  local myRotation = self.getRotation()
    spawnparams = {
      type = 'Custom_Token',
      position          = myPosition,
      rotation          = myRotation,
      scale             = {x=0.16, y=1, z=0.16},
      snap_to_grid      = false,
    }
    object = spawnObject(spawnparams)
    params = {
      image = "https://steamusercontent-a.akamaihd.net/ugc/11917605554478693/BDF98D8B4A04C15D33095DEF10303A221FEF1FDD/",
      thickness = 0.1,
    }
    object.setCustomObject(params)
    object.setDescription("smoke")
end

function leftPosition()
  local x = 0.78
  local y = 0.1
  local z = -.13
  return self.positionToWorld({x,y,z})
end

function spawnSmokeRight() --spawns smoke token
  local myPosition = rightPosition()
  local myRotation = self.getRotation()
    spawnparams = {
      type = 'Custom_Token',
      position          = myPosition,
      rotation          = myRotation,
      scale             = {x=0.16, y=1, z=0.16},
      snap_to_grid      = false,
    }
    object = spawnObject(spawnparams)
    params = {
      image = "https://steamusercontent-a.akamaihd.net/ugc/11917605554478693/BDF98D8B4A04C15D33095DEF10303A221FEF1FDD/",
      thickness = 0.1,
    }
    object.setCustomObject(params)
    object.setDescription("smoke")
end

function rightPosition()
  local x = -0.78
  local y = 0.1
  local z = -.13
  return self.positionToWorld({x,y,z})
end

function spawnSkirmishers()
	local rot = self.getRotation()
	myPosition = spawnPosition()
	local spawnparams = {
		type = 'Custom_Model',
		position          = myPosition,
		rotation          = {rot.x,rot.y,rot.z},
		scale             = {x=1.3, y=1, z=1.3},
		snap_to_grid      = false,
    }
    object = spawnObject(spawnparams)
    params = {
      mesh = "https://steamusercontent-a.akamaihd.net/ugc/11918420978341380/CD5B3972295FF47DC14A66D1AD15A4DB88F90841/",
      diffuse = "https://steamusercontent-a.akamaihd.net/ugc/11917605550997869/3282C19C94A8F3493EC085F7F03A8E1C528505F6/",
      material = 3,
    }
    object.setCustomObject(params)
    name = self.getName()
    object.setName(name)
    myColorTint = self.getColorTint()
    object.setColorTint(myColorTint)
end

function spawnPosition()
  local x = 0
  local y = 0.1
  local z = -1.25
  return self.positionToWorld({x,y,z})
end

function printStep(player_color)
     local message = "Steps remaining: " .. tostring(steps)
     broadcastToColor(message, player_color, {0, 1, 1})  -- Cyan text
end

function scaleUp()
  self.Scale({x=1.11,y=1,z=1})
end

function scaleDown()
  self.Scale({x=0.9,y=1,z=1})
end

function addSteps()  if steps == nil then steps = 6 end
  steps=steps+1
  if steps > max_steps then steps = max_steps
  elseif steps <= max_steps then scaleUp()
  end
end

function reduceSteps()  if steps == nil then steps = 6 end
  steps=steps-1
  if steps < min_steps then steps = min_steps
  elseif steps >= min_steps then scaleDown()
  end
end

function setLine()
    params = {
      mesh = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693391/0943345DA6F3BD247B7073EF24B54579EA3126F0/",
    }
    setFormation()
    print("Line")
end

function setColumn()
    params = {
      mesh = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693331/C0DEFCF73A79541D4756A93BBF4B8E922982F429/",
    }
    setFormation()
    print("Column")
end

function setSquare()
    params = {
      mesh = "https://steamusercontent-a.akamaihd.net/ugc/11916971567693356/0D82CF6ED5B1B76EEF16C340F01B6838BC5BECB3/",
    }
    setFormation()
    print("Square")
end

function setFormation()
  self.setCustomObject(params)
  self.reload()
end

function clickUp()
  SkDistance = SkDistance-2
  skirmisherProjection()
end

function clickDown()
  SkDistance = SkDistance+2
  skirmisherProjection()
end

function nullFunction()
 --does nothing
end

  