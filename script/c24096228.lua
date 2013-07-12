--二重魔法
function c24096228.initial_effect(c)
	--copy spell
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c24096228.cost)
	e1:SetTarget(c24096228.target)
	e1:SetOperation(c24096228.operation)
	c:RegisterEffect(e1)
end
function c24096228.cfilter(c)
	return c:IsDiscardable() and c:IsType(TYPE_SPELL)
end
function c24096228.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c24096228.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,c24096228.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
function c24096228.filter1(c)
	return c:IsType(TYPE_SPELL) and c:CheckActivateEffect(false,false,false)~=nil
end
function c24096228.filter2(c)
	return c:IsType(TYPE_SPELL) and not c:IsType(TYPE_EQUIP+TYPE_CONTINUOUS) and c:CheckActivateEffect(false,false,false)~=nil
end
function c24096228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local b=e:GetHandler():IsLocation(LOCATION_HAND)
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if (b and ft>1) or (not b and ft>0) then
			return Duel.IsExistingTarget(c24096228.filter1,tp,0,LOCATION_GRAVE,1,nil)
		else
			return Duel.IsExistingTarget(c24096228.filter2,tp,0,LOCATION_GRAVE,1,nil)
		end
	end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e:SetCategory(0)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.SelectTarget(tp,c24096228.filter1,tp,0,LOCATION_GRAVE,1,1,nil)
	else
		Duel.SelectTarget(tp,c24096228.filter2,tp,0,LOCATION_GRAVE,1,1,nil)
	end
end
function c24096228.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	Duel.ClearTargetCard()
	if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS)~=0 then
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		tc:CreateEffectRelation(te)
		if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
		if tg then tg(te,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local etc=g:GetFirst()
		while etc do
			etc:CreateEffectRelation(te)
			etc=g:GetNext()
		end
		if op then op(te,tp,eg,ep,ev,re,r,rp) end
		tc:ReleaseEffectRelation(te)
		etc=g:GetFirst()
		while etc do
			etc:ReleaseEffectRelation(te)
			etc=g:GetNext()
		end
	else
		if bit.band(tpe,TYPE_FIELD)~=0 then
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
		if co then co(e,tp,eg,ep,ev,re,r,rp,1) end
		if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
		Duel.BreakEffect()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
		if bit.band(tpe,TYPE_FIELD)~=0 then
			local of=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
			if of then Duel.Destroy(of,REASON_RULE) end
		end
	end
end