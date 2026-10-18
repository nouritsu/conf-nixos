-- 3-way merge of profile slot 1, base = last save written to both sides
-- usage: luajit merge.lua <run dir> <game source>
-- reads decoded/{base,pc,phone}, writes out/{pc,phone} + summary.csv, prints the sides that need a write
local W, SRC = arg[1], arg[2]
dofile(SRC.."/engine/string_packer.lua")
local function load(p) local f = assert(io.open(p, "rb")); local s = f:read("*a"); f:close(); return assert(loadstring(s))() end
local function rd(side, f) return load(W.."/decoded/"..side.."/"..f..".lua") end
local function write(path, s) local f = assert(io.open(path, "wb")); f:write(s); f:close() end

-- steamodded convert_usage_entry: vanilla stake keys fold into wins/losses by max, then drop
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

local STREAKS = {c_round_interest_cap_streak = true, c_single_hand_round_streak = true}
local MAX = {stake = true, challenges_unlocked = true}

local function merge(b, pc, ph, path)
  if type(pc) == "table" or type(ph) == "table" then
    b = type(b) == "table" and b or {}
    pc = type(pc) == "table" and pc or {}
    ph = type(ph) == "table" and ph or {}
    local r, keys = {}, {}
    for k in pairs(pc) do keys[k] = true end
    for k in pairs(ph) do keys[k] = true end
    for k in pairs(keys) do r[k] = merge(b[k], pc[k], ph[k], path.."."..tostring(k)) end
    return r
  end
  if type(pc) == "number" or type(ph) == "number" then
    local leaf = path:match("[^.]+$")
    if leaf == "order" or path:match("^%.MEMORY") or path:match("^%.progress") or STREAKS[leaf] then
      if ph ~= nil then return ph end return pc
    end
    if path:match("^%.high_scores%.current_streak") then return ph or pc end
    if path:match("^%.high_scores") or MAX[leaf] then return math.max(pc or 0, ph or 0) end
    local d = (pc or 0) - (b or 0)
    assert(d >= 0, "pc went backwards at "..path)
    assert((ph or 0) >= (b or 0), "phone went backwards at "..path)
    return (ph or 0) + d
  end
  if ph ~= nil and (ph ~= b or pc == nil) then return ph end
  if pc ~= nil then return pc end
  return ph
end

local function same(a, b)
  if type(a) ~= "table" or type(b) ~= "table" then return a == b end
  for k, v in pairs(a) do if not same(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end

local S = {
  base = {p = norm(rd("base", "1/profile")), m = rd("base", "1/meta")},
  pc = {p = norm(rd("pc", "1/profile")), m = rd("pc", "1/meta"), s = rd("pc", "settings")},
  phone = {p = norm(rd("phone", "1/profile")), m = rd("phone", "1/meta"), s = rd("phone", "settings")},
}
local M = {p = merge(S.base.p, S.pc.p, S.phone.p, ""), m = {}}

for _, side in ipairs{"base", "pc", "phone"} do
  for sec, set in pairs(S[side].m) do
    M.m[sec] = M.m[sec] or {}
    for k, v in pairs(set) do M.m[sec][k] = M.m[sec][k] or v end
  end
end

-- settings: each side keeps its own, plus the union of recorded achievements
local ach = {}
for _, side in ipairs{"pc", "phone"} do for k, v in pairs(S[side].s.ACHIEVEMENTS_EARNED or {}) do ach[k] = ach[k] or v end end
M.s = {ACHIEVEMENTS_EARNED = ach}

local function n(t) local c = 0 for _ in pairs(t or {}) do c = c + 1 end return c end
local rows = {"stat,base,pc,phone,merged"}
local function row(name, f)
  local r = {name}
  for _, t in ipairs{S.base, S.pc, S.phone, M} do
    local ok, v = pcall(f, t)
    r[#r+1] = ok and type(v) == "number" and ("%.0f"):format(v) or "-"
  end
  rows[#rows+1] = table.concat(r, ",")
end
for _, c in ipairs{{"rounds", "c_rounds"}, {"wins", "c_wins"}, {"losses", "c_losses"}, {"hands played", "c_hands_played"}, {"cards played", "c_cards_played"}, {"cards discarded", "c_cards_discarded"}, {"dollars earned", "c_dollars_earned"}} do
  row(c[1], function(t) return t.p.career_stats[c[2]] end)
end
for _, h in ipairs{{"best hand", "hand"}, {"furthest ante", "furthest_ante"}, {"most money", "most_money"}, {"win streak", "win_streak"}} do
  row(h[1], function(t) return t.p.high_scores[h[2]].amt end)
end
row("unlocked", function(t) return n(t.m.unlocked) end)
row("discovered", function(t) return n(t.m.discovered) end)
row("achievements", function(t) return n(t.s.ACHIEVEMENTS_EARNED) end)
write(W.."/summary.csv", table.concat(rows, "\n").."\n")

for _, side in ipairs{"pc", "phone"} do
  local t = S[side]
  if not (same(M.p, t.p) and same(M.m, t.m) and same(ach, t.s.ACHIEVEMENTS_EARNED or {})) then print(side) end
  t.s.ACHIEVEMENTS_EARNED = {} for k, v in pairs(ach) do t.s.ACHIEVEMENTS_EARNED[k] = v end
  write(W.."/out/"..side.."/1/profile.lua", STR_PACK(M.p))
  write(W.."/out/"..side.."/1/meta.lua", STR_PACK(M.m))
  write(W.."/out/"..side.."/settings.lua", STR_PACK(t.s))
end
