	ds 800
	
spriteVisibilityDetour::
	ld l, a
	ld b, [hl]      ; c2x4: Y pos (+4)
;Check if we should use the override. Needed when getting bounced back!
	ld a, [wDoSpriteOverride]
	or a
	ld a, [wYCoord]
	jr z, .doNotUseOverrideY
	ld a, [wLastYBeforeLeftMap]
.doNotUseOverrideY
	cp b
	jr z, .skipYVisibilityTest
	jp nc, CheckSpriteAvailability.spriteInvisible ; above screen region
	add $8                  ; screen is 9 tiles high
	cp b
	jp c, CheckSpriteAvailability.spriteInvisible  ; below screen region
.skipYVisibilityTest
	inc l
	ld b, [hl]      ; c2x5: X pos (+4)
	;Check if we should use the override. Needed when getting bounced back!
	ld a, [wDoSpriteOverride]
	and a
	ld a, [wXCoord]
	jr z, .doNotUseOverrideX
	ld a, [wLastXBeforeLeftMap]
.doNotUseOverrideX
	cp b
	jp z, CheckSpriteAvailability.skipXVisibilityTest
	jp nc, CheckSpriteAvailability.spriteInvisible ; left of screen region
	add $9                  ; screen is 10 tiles wide
	cp b
	jp c, CheckSpriteAvailability.spriteInvisible  ; right of screen region
	jp CheckSpriteAvailability.skipXVisibilityTest