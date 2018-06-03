ThrowBack::
	ld hl, wd736
	set 6, [hl] ; jumping down ledge
	ld a, 1
	ld [wPlayerKeepDirection], a
	call StartSimulatingJoypadStates
	call InvertDirection
	ld [wSimulatedJoypadStatesEnd], a
	ld [wSimulatedJoypadStatesEnd + 1], a
	ld a, $2
	ld [wSimulatedJoypadStatesIndex], a
	call LoadHoppingShadowOAM
	ld a, SFX_LEDGE
	call PlaySound
	ret

InvertDirection::
	ld a, [wPlayerDirection]
	ld c, a
	and $C;We don't need to shift with up or down
	jr nz, .DoStuff
	ld a, c
	xor 3
	ld c, a
.DoStuff
	sla c
	sla c
	sla c
	sla c
	ld a, c
	ret
	
	
GetXCoords::
	;GetXCoordAfterWarp
	ld a, [wXCoord]
	ld c, a
	ret
	
GetYCoords::
	;GetXCoordAfterWarp
	ld a, [wYCoord]
	ld c, a
	ret
	
CheckCoordsAfterWarp::
	ld a,[wPlayerKeepDirection]
	xor 1
	jr z, .AlreadyThrownBack
	ld a,[wPlayerDirection]
	ld c, a
	xor 4 ;Are we going south?
	jr z, .LoadCoordDataSouth
	ld a, c
	xor 8 ;Are we going north?
	jr z, .LoadCoordDataNorth
	ld a, c
	xor 1 ;Are we going east?
	jr z, .LoadCoordDataEast
	ld a, c
	xor 2 ;Are we going west?
	jr z, .LoadCoordDataWest
.Continue
	add a
	sub 1
	cp c
	jp nc,.ReturnToRoutine
	call ThrowBack
.AlreadyThrownBack
	ld hl, wd730
	set 7, [hl] ; simulating key presses
	pop de
	call GotoBankSwitchReturnToOWLoop
	
.ReturnToRoutine
	ret
.LoadCoordDataWest
	call GetYCoords
	ld a, [wWestConnectedMapYAlignment] ; Y adjustment upon entering west map
	add c
	ld c, a
	ld a,[wWestConnectionStripHeight]
	jr .Continue
.LoadCoordDataEast
	call GetYCoords
	ld a, [wEastConnectedMapYAlignment] ; Y adjustment upon entering east map
	add c
	ld c, a
	ld a,[wEastConnectionStripHeight]
	jr .Continue
.LoadCoordDataNorth
	call GetXCoords
	ld a, [wNorthConnectedMapXAlignment] ; X adjustment upon entering north map
	add c
	ld c, a
	ld a,[wNorthConnectedMapWidth]
	jr .Continue
.LoadCoordDataSouth
	call GetXCoords
	ld a, [wSouthConnectedMapXAlignment] ; X adjustment upon entering south map
	add c
	ld c, a
	ld a,[wSouthConnectedMapWidth]
	jr .Continue
	
ResetStuff::
	ld hl, wd730
	res 7, [hl] ; not simulating joypad states any more
	xor a
	ld [wPlayerKeepDirection], a
	ld [wJoyIgnore], a
	ret
	
MovementDir::
	ld a, [wPlayerDirection] ; current direction
	ld c, a
	ld a, [wPlayerKeepDirection]
	and a
	jr nz, .DontTurn
	ld a, c
	ld [wPlayerMovingDirection], a ; save direction
.DontTurn
	call UpdateSprites
	ret
	
CheckValidWarp::
	ld a,[wLastMapPointer]
	cp $ff
	;ret nz
	jr nz, .CheckXAfterWarp
    ld hl, wd730
	set 7, [hl] ; simulating key presses
	ld a, [wWalkCounter]
	and a
	jr nz, .AlreadyThrownBack
	callba ThrowBack
.AlreadyThrownBack
	call GotoBankSwitchReturnToOWLoop
.CheckXAfterWarp
	call CheckCoordsAfterWarp
	ld a,[wLastMapPointer]
	ret

GotoBankSwitchReturnToOWLoop::
	pop de
	pop de
	pop de
	pop de
	pop de
	ld de, OverworldLoop
	push de
	call GotoBankSwitchReturn
	
GotoBankSwitchReturnToCollisionCheckLandNoColl::
	pop de
	pop de
	pop de
	pop de
	ld de, CollisionCheckOnLand.noCollision
	push de
	call GotoBankSwitchReturn
	
GotoBankSwitchReturn::
	pop de
	ld a, [H_LOADEDROMBANK]
	push af
	ld de, Bankswitch.Return
	push de
	ret
	
doLoadSouthData::
	ld a, [wLastMapPointer]
	ld [wCurMap], a
	ld a, [wSouthConnectedMapYAlignment] ; new Y coordinate upon entering south map
	ld [wYCoord], a
	ld a, [wXCoord]
	ld c, a
	ld a, [wSouthConnectedMapXAlignment] ; X adjustment upon entering south map
	add c
	ld c, a
	ld [wXCoord], a
	ld a, [wSouthConnectedMapViewPointer] ; pointer to upper left corner of map without adjustment for X position
	ld l, a
	ld a, [wSouthConnectedMapViewPointer + 1]
	ld h, a
	ld b, 0
	srl c
	add hl, bc
	ld a, l
	ld [wCurrentTileBlockMapViewPointer], a ; pointer to upper left corner of current tile block map section
	ld a, h
	ld [wCurrentTileBlockMapViewPointer + 1], a
	ret
	
doSomeTest::
	ld a, [hSpriteIndexOrTextID]
	and a ; was there a sprite collision?
	ret nz
; if no sprite collision
	ld hl, TilePairCollisionsLand
	call CheckForJumpingAndTilePairCollisions
	ret c
	call CheckTilePassable
	ret c
	call GotoBankSwitchReturnToCollisionCheckLandNoColl