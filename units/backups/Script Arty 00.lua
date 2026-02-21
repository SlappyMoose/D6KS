    -- JENA -- Red Artillery Section -- v0.2 -- 11/09/24
    -- Damon A. Mosier -- International Kriegsspiel Society
    visible = false

    function onSave()
        --We make a table of data we want to save. WE CAN ONLY SAVE 1 TABLE.
        local data_to_save = {
          visible=visible,
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
            visible = loaded_data.visible
        end
        --now we will add the context menu items
        self.addContextMenuItem("SPAWN", nullFunction)
        self.addContextMenuItem("   Gun Smoke", spawnSmoke)
        self.addContextMenuItem("FORMATION", nullFunction)
        self.addContextMenuItem("   Unlimbered", formationUnlimbered)
        self.addContextMenuItem("   Limbered", formationLimbered)
        self.addContextMenuItem("   Defeated!", formationDefeated)
        self.addContextMenuItem("RANGE FINDER", nullFunction)
        self.addContextMenuItem("   Toggle", toggleRange)
        CreateButtons()
    end

    function CreateButtons()
      local data = {click_function = "nullFunction", index = 0, function_owner = self,
        label = casualties, position = {0, -0.03, 0.15}, rotation = {0, 0, 0}, scale = {1, 1, 1}, width = 0,
        height = 0, font_size = 100, font_color = {1, 0, 0, 1}, tooltip = ""}
      self.createButton(data)
    end

    function spawnSmoke() --spawns smoke token
      local myPosition = tokenPosition()
      local myRotation = self.getRotation()
        spawnparams = {
          type = 'Custom_Token',
          position          = myPosition,
          rotation          = myRotation,
          scale             = {x=0.13, y=1, z=0.13},
          snap_to_grid      = false,
        }
        object = spawnObject(spawnparams)
        params = {
          image = "https://steamusercontent-a.akamaihd.net/ugc/2458494928525602813/A3F95BBF84FA2EB974D86AEEC015BAF04EA2875F/",
          thickness = 0.1,
        }
        object.setCustomObject(params)
        object.setDescription("smoke")
    end

    function tokenPosition() --positions token in front of the unit
      local x = 0
      local y = 0.1
      local z = -.65
      return self.positionToWorld({x,y,z})
    end

    function formationLimbered()
        params = {
          mesh = "https://steamusercontent-a.akamaihd.net/ugc/2458494928524556985/8BF5DA41F8BCCBE121EE33FC73F187A93AD25F8E/",
        }
        setFormation()
    end

    function formationUnlimbered()
        params = {
          mesh = "https://steamusercontent-a.akamaihd.net/ugc/2458494928524557226/2DEA1DEA81B2888FB3018EB1B1CE83AB27A6BC57/",
        }
        setFormation()
    end

    function formationDefeated()
        params = {
          mesh = "https://steamusercontent-a.akamaihd.net/ugc/2458494928524555366/B831637B713DE74870220D2EACD8CEBE99E540ED/",
        }
        setFormation()
        print("Unit Defeated!")
        broadcastToAll("Unit Defeated!")
    end

    function setFormation()
      self.setCustomObject(params)
      self.reload()
    end

    function nullFunction()
     --does nothing
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
  