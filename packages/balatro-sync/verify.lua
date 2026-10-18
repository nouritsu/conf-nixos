-- checks merge.lua's output, one line per passed check; any failed assert exits non-zero
-- usage: luajit verify.lua <run dir> <game source>
local W, SRC = arg[1], arg[2]
local function load(p) local f = assert(io.open(p, "rb")); local s = f:read("*a"); f:close(); return assert(loadstring(s))() end
local function eq(a, b, p)
  assert(type(a) == type(b), "type differs at "..p)
  if type(a) ~= "table" then assert(a == b, "value differs at "..p) return end
  for k, v in pairs(a) do eq(v, b[k], p.."."..tostring(k)) end
  for k in pairs(b) do assert(a[k] ~= nil, "extra key "..p.."."..tostring(k)) end
end

local M, MM, S = load(W.."/out/pc/1/profile.lua"), load(W.."/out/pc/1/meta.lua"), load(W.."/out/pc/settings.lua")
local STAKE = {stake_white = 1, stake_red = 2, stake_green = 3, stake_black = 4, stake_blue = 5, stake_purple = 6, stake_orange = 7, stake_gold = 8}
local function norm(p)
  for _, sec in ipairs{"deck_usage", "joker_usage"} do
    for _, e in pairs(p[sec] or {}) do
      for _, ks in ipairs{{"wins", "wins_by_key"}, {"losses", "losses_by_key"}} do
        e[ks[1]] = e[ks[1]] or {}; e[ks[2]] = e[ks[2]] or {}
        for k, w in pairs(e[ks[2]]) do
          local i = STAKE[k]
          if i then e[ks[1]][i] = math.max(e[ks[1]][i] or 0, w); e[ks[2]][k] = nil end
        end
      end
    end
  end
  return p
end
local B, PC, PH = {}, {}, {}
for side, t in pairs{base = B, pc = PC, phone = PH} do t.p = norm(load(W.."/decoded/"..side.."/1/profile.lua")); t.m = load(W.."/decoded/"..side.."/1/meta.lua") end

for _, sec in ipairs{"unlocked", "discovered", "alerted"} do
  local u = {} for _, t in ipairs{B, PC, PH} do for k in pairs(t.m[sec] or {}) do u[k] = true end end
  for k in pairs(u) do assert(MM[sec][k], "missing "..sec.." "..k) end
  for k in pairs(MM[sec] or {}) do assert(u[k], "extra "..sec.." "..k) end
end
print("meta is the exact union of base, pc and phone")

local checked = 0
local function walk(m, b, pc, ph, path)
  for k, v in pairs(m) do
    local p = path.."."..tostring(k)
    if type(v) == "table" then walk(v, type(b[k]) == "table" and b[k] or {}, type(pc[k]) == "table" and pc[k] or {}, type(ph[k]) == "table" and ph[k] or {}, p)
    elseif type(v) == "number" and k ~= "order" then
      local e = (ph[k] or 0) + (pc[k] or 0) - (b[k] or 0)
      assert(v == e, p.." = "..v.." expected "..e)
      assert(v >= (pc[k] or 0) and v >= (ph[k] or 0), p.." below a side")
      checked = checked + 1
    end
  end
end
for _, sec in ipairs{"joker_usage", "deck_usage", "consumeable_usage", "voucher_usage", "hand_usage"} do walk(M[sec] or {}, B.p[sec] or {}, PC.p[sec] or {}, PH.p[sec] or {}, sec) end
local cs = {} for k, v in pairs(M.career_stats) do if not k:match("streak") then cs[k] = v end end
walk(cs, B.p.career_stats or {}, PC.p.career_stats or {}, PH.p.career_stats or {}, "career_stats")
print(checked.." additive counters = phone + pc - base")

for k, h in pairs(M.high_scores) do
  if k ~= "current_streak" then assert(h.amt >= PC.p.high_scores[k].amt and h.amt >= PH.p.high_scores[k].amt, "high score "..k.." below a side") end
end
print("high scores >= both sides")

for _, side in ipairs{"pc", "phone"} do
  local own, out = load(W.."/decoded/"..side.."/settings.lua"), load(W.."/out/"..side.."/settings.lua")
  for k in pairs(own.ACHIEVEMENTS_EARNED or {}) do assert(out.ACHIEVEMENTS_EARNED[k], side.." lost achievement "..k) end
  own.ACHIEVEMENTS_EARNED, out.ACHIEVEMENTS_EARNED = nil, nil
  eq(own, out, side.." settings")
  print(side.." settings unchanged apart from achievements")
end
for _, f in ipairs{"1/profile", "1/meta"} do eq(load(W.."/out/pc/"..f..".lua"), load(W.."/out/phone/"..f..".lua"), f) end
print("pc and phone get the same profile and meta")

-- achievements by the game's rules, from persistent progress
local sets = {}
for line in io.lines(SRC.."/game.lua") do
  local key, body = line:match("^%s*([%w_]+)%s*=%s*(%b{})")
  if key and body:match('set%s*=%s*"') and not body:match("omit%s*=%s*true") then
    sets[key] = body:match('set%s*=%s*"(%w+)"')
  end
end
local T = {}
local function tally(name, pred) local t, o = 0, 0 for k, s in pairs(sets) do if pred(s) then o = o + 1; if MM.discovered[k] then t = t + 1 end end end T[name] = {t, o} end
tally("vouchers", function(s) return s == "Voucher" end)
tally("spectrals", function(s) return s == "Spectral" end)
tally("tarots", function(s) return s == "Tarot" end)
tally("planets", function(s) return s == "Planet" end)
tally("total", function(s) return s == "Joker" or s == "Tarot" or s == "Planet" or s == "Spectral" or s == "Edition" or s == "Voucher" or s == "Back" or s == "Booster" end)
local hi = 0 for _, d in pairs(M.deck_usage) do for st in pairs(d.wins or {}) do hi = math.max(hi, st) end end
local done = 0 for _ in pairs((M.challenge_progress or {}).completed or {}) do done = done + 1 end
local H = M.high_scores
local rule = {
  ante_up = H.furthest_ante.amt >= 4, ante_upper = H.furthest_ante.amt >= 8,
  heads_up = M.career_stats.c_wins > 0,
  low_stakes = hi >= 2, mid_stakes = hi >= 4, high_stakes = hi >= 8,
  card_player = M.career_stats.c_cards_played >= 2500, card_discarder = M.career_stats.c_cards_discarded >= 2500,
  nest_egg = H.most_money.amt >= 400,
  _10k = H.hand.amt >= 10000, _1000k = H.hand.amt >= 1000000, _100000k = H.hand.amt >= 100000000,
  extreme_couponer = T.vouchers[1] >= T.vouchers[2], clairvoyance = T.spectrals[1] >= T.spectrals[2],
  cartomancy = T.tarots[1] >= T.tarots[2], astronomy = T.planets[1] >= T.planets[2], completionist = T.total[1] >= T.total[2],
  legendary = MM.discovered.j_caino or MM.discovered.j_triboulet or MM.discovered.j_yorick or MM.discovered.j_chicot or MM.discovered.j_perkeo or false,
  rule_bender = done > 0,
}
local extra = {}
for k, ok in pairs(rule) do if ok and not (S.ACHIEVEMENTS_EARNED or {})[k] then extra[#extra+1] = k end end
table.sort(extra)
if #extra > 0 then print("met by progress but not recorded: "..table.concat(extra, " ")) end
