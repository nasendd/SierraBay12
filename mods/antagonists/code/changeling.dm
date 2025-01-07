/obj/item/organ/internal/augment/ling_lenses/Process()
	..()
	if(is_active && (owner.mind.changeling.chem_charges > 0))
		owner.set_sight(owner.sight | SEE_MOBS)
		owner.mind.changeling.chem_charges -= 3
		if(owner.mind.changeling.chem_charges < 3)
			is_active = FALSE
			owner.set_sight(owner.sight &= ~SEE_MOBS)
			to_chat(owner,SPAN_NOTICE("Our lenses retract, causing us to lose our augmented vision."))
