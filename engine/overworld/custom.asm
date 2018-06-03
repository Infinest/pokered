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
	pop de
	pop de
	pop de
	ld de, OverworldLoop
	push de
	ld a, [H_LOADEDROMBANK]
	push af
	ld de, Bankswitch.Return
	push de
	ret
.ReturnToRoutine
	ret
.LoadCoordDataWest
	ld a,[wMapConn3Ptr];Map pointer of west Map
	ld [wLastMapPointer],a
	call GetYCoords
	ld a, [wWestConnectedMapYAlignment] ; Y adjustment upon entering west map
	add c
	ld c, a
	ld a,[wWestConnectionStripHeight]
	jr .Continue
.LoadCoordDataEast
	ld a,[wMapConn4Ptr];Map pointer of east Map
	ld [wLastMapPointer],a
	call GetYCoords
	ld a, [wEastConnectedMapYAlignment] ; Y adjustment upon entering east map
	add c
	ld c, a
	ld a,[wEastConnectionStripHeight]
	jr .Continue
.LoadCoordDataNorth
	ld a,[wMapConn1Ptr];Map pointer of north Map
	ld [wLastMapPointer],a
	call GetXCoords
	ld a, [wNorthConnectedMapXAlignment] ; X adjustment upon entering north map
	add c
	ld c, a
	ld a,[wNorthConnectedMapWidth]
	jr .Continue
.LoadCoordDataSouth
	ld a,[wMapConn2Ptr];Map pointer of south Map
	ld [wLastMapPointer],a
	call GetXCoords
	ld a, [wSouthConnectedMapXAlignment] ; X adjustment upon entering south map
	add c
	ld c, a
	ld a,[wSouthConnectedMapWidth]
	jr .Continue
	