-- @Author: ZhuL
-- @Date:   2017-08-06 11:47:12
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-08-22 12:00:12

local M = class("QuadTree")

local clsQTreeNode = require("core.QTreeNode")

--[[一个矩形区域的象限划分：: 
         UL(1)   |    UR(2) 
       ----------|----------- 
         LL(3)   |    LR(4) 
  以下对该象限类型的枚举 ]]  

local function getSubRect(rect , index)
	local halfWidth = rect.width / 2
	local halfHeight = rect.height / 2
	if index == 1 then
		return cc.rect(rect.x , rect.y + halfHeight , halfWidth , halfHeight)
	elseif index == 2 then
		return cc.rect(rect.x + halfWidth , rect.y + halfHeight , halfWidth , halfHeight)
	elseif index == 3 then
		return cc.rect(rect.x , rect.y , halfWidth , halfHeight)
	else
		return cc.rect(rect.x + halfWidth , rect.y , halfWidth , halfHeight)
	end
end


local function isIn(r1 , r2)
	local ret = r1.x <= r2.x 
			and r1.y <= r2.y
			and r1.width + r1.x >= r2.width + r2.x
			and r1.height + r1.y >= r2.height + r2.y

	return ret 
end

cc.exports.getSubRect = getSubRect
cc.exports.isIn = isIn

function M:ctor(entityLst)
	self.__root = clsQTreeNode.new(cc.rect(0 , 0 , display.width , display.height) , nil , 0)

	self.__entityLst = __entityLst or {}

	self.__depth = 4

	self:build(self.__root , 0)
end

function M:tryAddEntity(entity)
	self.__root:tryAddEntity(entity)
end

function M:checkCollision(entityLst)
	for i , entity in ipairs(entityLst) do
		self.__root:checkCollision(entity)
	end
end

function M:build(parent , depth)
	self:createBranch(parent , depth)
end

function M:createBranch(parent , depth)
	local rect = parent:getRect()
	if depth == self.__depth then
		return
	end
	local nextDepth = depth + 1

	for i = 1 , 4 do
		local r = getSubRect(rect , i)
		local child = clsQTreeNode.new(r , parent , nextDepth)
		self:createBranch(child , nextDepth)
	end
end

return M