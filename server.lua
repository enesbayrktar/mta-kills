addEvent('kills.request.list', true)

local setElementData = setElementData
local getElementData = getElementData
local addEventHandler = addEventHandler
local setAccountData = setAccountData
local getAccountData = getAccountData

local playerList = setmetatable({}, {
    __newindex = function(storage, thePlayer, theAccount)
      local rw = rawset(storage, thePlayer, theAccount)
      if not rw then
        return false
      end
    end;
  }
)

addEventHandler('onResourceStart', resourceRoot, function(resource)
    if not getResourceRootElement(resource) == resourceRoot then
      return false
    end

    for _, thePlayer in ipairs(getElementsByType('player')) do
      local theAccount = getPlayerAccount(thePlayer)
      if not isGuestAccount(theAccount) then
        playerList[thePlayer] = theAccount
        local accountKills = getAccountData(theAccount, 'kills')
        if accountKills then
          setElementData(thePlayer, 'player.kills', accountKills or 0, false)
        end
      end
    end
  end
)

local dumpKillersTable = {}

addEventHandler('kills.request.list', root, function(sortBy) -- future: sortBy
    if not client then
      return false
    end -- memory leak

    for thePlayer, _ in pairs(playerList) do
      table.insert(dumpKillersTable, { getElementData(thePlayer, 'player.kills') or 0, string.removeHex(getPlayerName(thePlayer)) })
    end

    table.sort(dumpKillersTable, function(a, b)
        return b[1] < a[1]
      end
    )

    triggerLatentClientEvent(client, 'kills.import', 5000, false, client, dumpKillersTable, getElementData(client, 'player.kills'))

    dumpKillersTable = {}
  end
)

local killGoals = {
  aclGroups = get'killGoals'

  --[[ v1 aclGroups
    aclGroups = {
      [int Öldürme sayısı] = 'string Acl grup ismi örnek : Admin'
      [int killScore] = 'string AclGroupName'
      Ex: [1000] = 'ZalimKatil'
    }
  ]]--
}

function killGoals.aclGroupAddObject(aclGroupIndex, accountName)
  if not accountName then
    return false
  end
  aclGroupAddObject(aclGetGroup(killGoals.aclGroups[tostring(aclGroupIndex)]), string.format('user.%s', accountName))
end

killGoals.switch = switch{
  default = killGoals.aclGroupAddObject,
}

addEventHandler('onPlayerWasted', root, function(_, killer)
    if not killer or killer == source then
      return false
    end

    if not playerList[killer] then
      return false
    end

    setElementData(killer, 'player.kills', getElementData(killer, 'player.kills') + 1, false)

    killGoals.switch:case(getElementData(killer, 'player.kills'), getAccountName(getPlayerAccount(killer)))
  end
)

addEventHandler('onPlayerLogin', root, function(_, theCurrentAccount)
    playerList[source] = theCurrentAccount
    setElementData(source, 'player.kills', getAccountData(theCurrentAccount, 'kills') or 0, false)
  end
)

addEventHandler('onPlayerQuit', root, function(_)
    if not playerList[source] then
      return false
    end

    setAccountData(playerList[source], 'kills', getElementData(source, 'player.kills') or 0)
    playerList[source] = nil
  end
)

addEventHandler('onPlayerLogout', root, function(_, _)
    cancelEvent(true)
  end
)
