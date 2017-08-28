-- @Author: ZhuL
-- @Date:   2017-08-07 22:39:13
-- @Last Modified by:   ZhuL
-- @Last Modified time: 2017-08-14 15:44:53

local M = class("Entity" , cc.Sprite)

function M:ctor(res)
	self:initWithFile(res)

	-- 实体对象所在的四叉树节点
	self.__QTNode = nil
end

function M:setQTNode(val)
	self.__QTNode = val
end

function M:getQTNode()
	return self.__QTNode
end

-- 向上检查，检查entity对象是否完全处在当前矩形内
function M:checkAndMoveUp(tNode)
	local node = tNode
	local nodeRect = node:getRect()
	local rect = self:getRect()

	while (not isIn(nodeRect , rect)) do
		node = node:getParent()
		nodeRect = node:getRect()
	end

	tNode:delEntity(self)
	node:AddEntity(self)
end

function M:checkAndMoveDown(tNode)
	local rect = self:getRect()
	for i , child in ipairs(tNode:getChildren()) do
		local childRect = child:getRect()
		if isIn(childRect , rect) then
			-- 如果找到合适的子节点，则继续递归查找子节点
			self:checkAndMoveDown(child)
			return
		end
	end
	-- 直到没有子节点或不在任何一个子节点的矩形内，则把此entity对象安插在当前四叉树节点上
	if tNode ~= self.__QTNode then
		self.__QTNode:delEntity(self)
		tNode:AddEntity(self)
	end
end

function M:getRect()
	return self:getBoundingBox()
end

function M:update(dt)
	local tNode = self.__QTNode
	local rect = self:getRect()
	if tNode == nil then
		return
	end
	local nodeRect = tNode:getRect()
	if isIn(nodeRect , rect) then
		-- 如果实体对象在当前节点的矩形中，则往下检查(检查是否在子节点的矩形内)并移动
		self:checkAndMoveDown(tNode)
	else
		-- 如果实体对象不完全在当前节点的矩形，则向上检查(检查是否在父节点的矩形内)并移动
		self:checkAndMoveUp(tNode)
	end
end

return M