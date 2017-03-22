--[[

Ranking System For Garrys Mod made by jubjub and Snell

]]--

-- Round wins until a player is no longer Unranked
RANK.Promotion = 3

-- Do we reward people for winning the round
RANK.RewardWin = true

-- Do we reward people for kills
RANK.RewardKill = true

-- Do players get punished for RDM
RANK.PunishRDM = false

-- List of ranks highest percentile first besides {<rankname>, <percentile>, <colour object>}
RANK.Ranks = {
    {"Unranked", nil, nil}, -- DO NOT REMOVE
    {"The Global Elite", 98, rainbow},
    {"Supreme Master First Class", 95, Color(50, 129, 255)},
    {"Legendary Eagle Master", 90, Color(255, 210, 49)},
    {"Legendary Eagle", 85, Color(255, 223, 112)},
    {"Disiguished Master Guardian", 80, Color(112, 247, 255)},
    {"Master Guardian II", 70, Color(101, 63, 255)},
    {"Master Guardian I", 65, Color(140, 112, 255)},
    {"Gold Nova Master", 55, Color(208, 219, 8)},
    {"Gold Nova III", 50, Color(231, 242, 33)},
    {"Gold Nova II", 45, Color(244, 255, 63)},
    {"Gold Nova I", 40, Color(246, 255, 102)},
    {"Silver Elite Master", 30, Color(119, 119, 119)},
    {"Silver Elite", 25, Color(142, 142, 142)},
    {"Silver IV", 20, Color(160, 160, 160)},
    {"Silver III", 15, Color(181, 181, 181)},
    {"Silver II", 10, Color(198, 198, 198)},
    {"Silver I", 5, Color(216, 216, 216)}
}