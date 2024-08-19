-- 玩游戏就好好玩游戏
local _G = GLOBAL
local TUNING = _G.TUNING
local Ingredient = _G.Ingredient
local AddClassPostConstruct = env.AddClassPostConstruct
local Vector3 = _G.Vector3
local SendModRPCToServer = _G.SendModRPCToServer
local GetModRPC = _G.GetModRPC
local AddModRPCHandler = _G.AddModRPCHandler
local SpawnPrefab = _G.SpawnPrefab
local AllRecipes = _G.AllRecipes
local BUTTONFONT = _G.BUTTONFONT
local ANCHOR_MIDDLE = _G.ANCHOR_MIDDLE
local TheWorld = _G.TheWorld
local TheInput = _G.TheInput
function DefaultValue(value, default_Value)
    if value == nil then return default_Value end
    return value
end
local BossjtRigorous = DefaultValue(TUNING.BOSSJT_RIGOROUS, true) -- 困难
local BossjtConsumeAllMaterials = DefaultValue(
                                         TUNING.BOSSJT_CONSUME_ALL_MATERIALS,
                                         false) -- 噩梦
local BossjtByMenus = DefaultValue(TUNING.BOSSJT_BY_MENUS, false) -- 查找
local BossjtAcceptsstacks = DefaultValue(TUNING.BOSSJT_ACCEPTSSTACKS,
                                            false) -- 叠堆
local BossjtRecipes = DefaultValue(TUNING.BOSSJT_RECIPES, {
    {
        name = 'kemomimi_boss_dragon_bai',
        numtogive = 1,
        builder_tag = nil,
        ingredients = {
          Ingredient("kemomimi_boss_dragon_bai_zh", 1), nil, nil,
          nil, nil, nil,
          nil, nil, nil
        }
    },
    {
      name = 'kemomimi_boss_ds',
      numtogive = 1,
      builder_tag = nil,
      ingredients = {
          Ingredient("kemomimi_boss_ds_zh", 1), nil, nil,
          nil, nil, nil,
          nil, nil, nil

      }
    },
    {
      name = 'kemomimi_boss_fs',
      numtogive = 1,
      builder_tag = nil,
      ingredients = {
          Ingredient("kemomimi_boss_fs_zh", 1), nil, nil,
          nil, nil, nil,
          nil, nil, nil

      }
    },
         {
        name = 'kemomimi_boss_hmz',
        numtogive = 1,
        builder_tag = nil,
        ingredients = {
          Ingredient("kemomimi_boss_hmz_zh", 1), nil, nil,
          nil, nil, nil,
          nil, nil, nil
        }
    }, 











})
-- ================================================================================

-- 注入容器（使其可以挂载按钮）
local function InjectContainerWidgetMountButton()
    local Image = require 'widgets/image'
    local ImageButton = require 'widgets/imagebutton'
    AddClassPostConstruct('widgets/containerwidget', function(self)
        local old_fn = self.Open
        self.Open = function(self, container, doer, ...)
            self:Close()
            local widget = container.replica.container:GetWidget()
            if widget.button_info ~= nil then
                if doer ~= nil and doer.components.playeractionpicker ~= nil then
                    doer.components.playeractionpicker:RegisterContainer(
                        container)
                end

                self.button = self:AddChild(Image())
                for i = 1, #widget.button_info, 1 do
                    self.button[i] = self.button:AddChild(ImageButton(
                                                              'images/ui.xml',
                                                              'button_small.tex',
                                                              'button_small_over.tex',
                                                              'button_small_disabled.tex',
                                                              nil, nil, {1, 1},
                                                              {0, 0}))
                    self.button[i].image:SetScale(1.07)
                    self.button[i].text:SetPosition(2, -2, 0)
                    self.button[i]:SetPosition(widget.button_info[i].position)
                    self.button[i]:SetText(widget.button_info[i].text)
                    if widget.button_info[i].fn ~= nil then
                        self.button[i]:SetOnClick(function()
                            if doer ~= nil then
                                if doer:HasTag('busy') then
                                    -- Ignore button click when doer is busy
                                    return
                                elseif doer.components.playercontroller ~= nil then
                                    local iscontrolsenabled, ishudblocking =
                                        doer.components.playercontroller:IsEnabled()
                                    if not (iscontrolsenabled or ishudblocking) then
                                        -- Ignore button click when controls are disabled
                                        -- but not just because of the HUD blocking input
                                        return
                                    end
                                end
                            end
                            widget.button_info[i].fn(container, doer)
                        end)
                    end
                    self.button[i]:SetFont(BUTTONFONT)
                    self.button[i]:SetDisabledFont(BUTTONFONT)
                    self.button[i]:SetTextSize(33)
                    self.button[i].text:SetVAlign(ANCHOR_MIDDLE)
                    self.button[i].text:SetColour(0, 0, 0, 1)

                    if TheInput:ControllerAttached() then
                        self.button[i]:Hide()
                    end

                    self.button[i].inst:ListenForEvent('continuefrompause',
                                                       function()
                        if TheInput:ControllerAttached() then
                            self.button[i]:Hide()
                        else
                            self.button[i]:Show()
                        end
                    end, TheWorld)
                end
            end
            old_fn(self, container, doer, ...)
        end
    end)
end

-- 创建容器
local function CreateChest(chest_name, widget, param)
    local params = {}
    params[chest_name] = {
        widget = {
            slotpos = {},
            slotbg = { -- 设置格子样式
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                },
                {
                    atlas = "images/ui/boss_slot.xml",
                    image = "boss_slot.tex"
                }
            },
            animbank = 'ui_chest_3x3',
            animbuild = 'ui_boss',
            pos = Vector3(0, 200, 0),
            side_align_tip = 160,
            button_info = {}
        },
        type = 'chest'
    }

    if widget ~= nil then
        for key, value in pairs(widget) do
            params[chest_name].widget[key] = value
        end
    end

    if param ~= nil then
        for key, value in pairs(param) do params[chest_name][key] = value end
    end

    for y = 2, 0, -1 do
        for x = 0, 2 do
            table.insert(params[chest_name].widget.slotpos,
                         Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        end
    end

    local containers = require('containers')
    for k, v in pairs(params) do
        containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget
                                               .slotpos ~= nil and
                                               #v.widget.slotpos or 0)
    end

    local containers_widgetsetup = containers.widgetsetup or
                                       function() return true end
    function containers.widgetsetup(container, prefab, ...)
        local t = prefab or container.inst.prefab
        if t == chest_name then -- 添加自己的容器
            local param = params[t]
            for k, v in pairs(param) do container[k] = v end
            container:SetNumSlots(container.widget.slotpos ~= nil and
                                      #container.widget.slotpos or 0)
        else
            return containers_widgetsetup(container, prefab, ...)
        end
    end
end

InjectContainerWidgetMountButton()
CreateChest('kochosei_altar', {
    button_info = {
        {
            text = '献祭',
            position = Vector3(0, -180, 0),
            fn = function(inst, doer)
                if inst.replica.container ~= nil and
                    not inst.replica.container:IsBusy() then
                    SendModRPCToServer(GetModRPC('kochosei_altar', 'synthesis'),
                                       inst)
                end
            end
        }
    }
}, {
    acceptsstacks = BossjtAcceptsstacks, -- 禁止叠堆
    itemtestfn = function(inst, item, slot)
        -- return item:IsValid() and item.components.leader == nil and not (item:HasTag('irreplaceable') or item:HasTag('bundle'))
        return item:IsValid() and item.components.leader == nil and
                   not (item:HasTag('bundle'))
    end
})

-- ================================================================================

local function Find(list, fn, length)
    length = length or #list
    for i = 1, length, 1 do if fn(list[i], i) == true then return list[i] end end
    return nil
end

local function FindItem(object, fn)
    for key, item in pairs(object) do
        if fn(item, key) == true then return item end
    end
    return nil
end

local function Every(list, fn, length)
    length = length or #list
    for i = 1, length, 1 do if fn(list[i], i) ~= true then return false end end
    return true
end

AddModRPCHandler('kochosei_altar', 'synthesis', function(player, kochosei_altar)
    if kochosei_altar.components.container ~= nil and
        kochosei_altar.components.container:IsOpenedBy(player) then

        local container = kochosei_altar.components.container

        if container:IsEmpty() then
            return player.components.talker:Say(
                       '我是不是要准备一些材料呢？')
        end

        local find_fn = function(recipe)
            if #recipe.ingredients <= 0 then return false end -- 无材料 不可以
            -- if not GetValidRecipe(recipe.name) then return false end -- 失效的不可以制作（傻不拉几的，不知道判断了啥）
            if recipe.placer ~= nil then return false end -- 建筑 不可以
            if recipe.builder_tag and not player:HasTag(recipe.builder_tag) then
                return false
            end -- 无标签 不可以
            if recipe.character_ingredients and #recipe.character_ingredients >
                0 then return false end -- 需要玩家属性的不可以制作
            if recipe.tech_ingredients and #recipe.tech_ingredients > 0 then
                return false
            end -- 需要科技的不可以制作（雕像啥的）
            if recipe.level and recipe.level.ORPHANAGE > 0 then
                return false
            end -- 宠物不可以制作

            local amount = 0
            local hasIngredient = Every(recipe.ingredients,
                                        function(ingredient, index)

                -- 严谨模式一比一位置
                if BossjtRigorous then
                    local item = container:GetItemInSlot(index)
                    local item_prefab = (item and item.prefab) or nil
                    local item_stacksize =
                        (item and item.components.stackable and
                            item.components.stackable.stacksize) or 1
                    local ingredient_type =
                        (ingredient and ingredient.type) or nil
                    local ingredient_amount =
                        (ingredient and ingredient.amount) or 1
                    if item_prefab == ingredient_type and item_stacksize ==
                        ingredient_amount then return true end
                    return false
                end

                if ingredient == nil then return true end
                if ingredient.amount <= 0 then return false end
                local result =
                    container:Has(ingredient.type, ingredient.amount) == true
                if result == true then
                    amount = amount + ingredient.amount
                end
                return result
            end, container:GetNumSlots())

            return hasIngredient
        end

        -- 获取当前可以制作的菜单
        local recipe = Find(BossjtRecipes, find_fn)
        if recipe == nil and BossjtAcceptsstacks == true and BossjtByMenus ==
            true then recipe = FindItem(AllRecipes, find_fn) end

        -- 没有找到可以制作的物品
        if recipe == nil then
            if BossjtConsumeAllMaterials then
                container:RemoveAllItems()
            end
            return player.components.talker:Say(
                       '材料似乎不太对，到底哪里出了问题？')
        end

        -- 删除需要的材料
        for i = 1, container:GetNumSlots(), 1 do
            local ingredient = recipe.ingredients[i]
            if ingredient then
                container:ConsumeByName(ingredient.type, ingredient.amount)
            end
        end

        -- 经过层层筛选，终于拿到将要制作的武器
        local prefab = SpawnPrefab(recipe.product or recipe.name) -- recipe.product 不知道是哪个~

        -- 这也不对？是bug吧？
        if prefab == nil then
            return player.components.talker:Say(
                       '咦？应该成功才对哇，奇奇怪怪的？')
        end

        -- 可以制作，但是发现不可以放入背包的~
        local x, y, z = player.Transform:GetWorldPosition()
        prefab.Transform:SetPosition(x, y, z)
        if prefab.components.inventoryitem == nil then
           -- prefab:Remove()
            return player.components.talker:Say(
                       '摇摆吧，命运的摇摆；刻画既来之时，穿梭于未来与过去！上级召唤：现身吧！ ')--我他妈太中二了哈哈哈哈哈哈
        end

        -- 尽情的放入背包的吧！
        for i = 1, recipe.numtogive or 1, 1 do
            player.components.inventory:GiveItem(prefab)
            return player.components.talker:Say('好耶！制作成功！')
        end

    end
end)

-- ================================================================================
