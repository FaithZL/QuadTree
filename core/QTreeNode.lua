-- @Author: ZhuL
-- @Date:   2017-08-06 10:36:50
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-08-11 18:39:28

local M = class("QTreeNode")

function M:ctor(rect , parent , depth)
	self.__rect = rect

	self.__entityLst = {}

	self.__children = {}

	self.__parent = parent

	self.__depth = depth

	self:init()
end

function M:init()
	if self.__parent then
		self.__parent:pushChild(self)
	end
end

function M:getRect()
	return self.__rect
end

function M:getParent()
	return self.__parent
end

function M:setParent(val)
	self.__parent = val
end

function M:checkCollision(entity)
	local rect = entity:getRect()
	for i , child in ipairs(self.__children) do
		local childRect = child:getRect()
		if isIn(childRect , rect) then
			child:checkCollision(entity)
			break
		end
	end
	for i , val in ipairs(self.__entityLst) do
		local r1 = val:getRect()
		if cc.rectIntersectsRect(r1 , rect) then
			local t = 0.2
			local a1 = cc.FadeOut:create(t)
			local a2 = cc.FadeIn:create(t)
			local seq = cc.Sequence:create(a1 , a2)
			entity:runAction(seq)	
		end		
	end
end

function M:pushChild(child)
	table.insert(self.__children , child)
end

function M:getChildren()
	return self.__children
end

function M:tryAddEntity(entity)
	local entityRect = entity:getRect()
	for i , child in ipairs(self.__children) do
		local rect = child:getRect()
		if isIn(rect , entityRect) then
			child:tryAddEntity(entity)
			return
		end
	end
	self:AddEntity(entity)
end

function M:AddEntity(entity)
	table.insert(self.__entityLst , entity)
	entity:setQTNode(self)
end

function M:delEntity(entity)
	for i , val in ipairs(self.__entityLst) do
		if val == entity then
			table.remove(self.__entityLst , i)
			entity:setQTNode(nil)
			return
		end
	end
end

return M