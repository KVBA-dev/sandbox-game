package main

ItemSlot :: struct {
	count: int,
	item: ItemType,
}

InventoryRenderer :: #type proc(player_inv: []ItemSlot, target_inv: []ItemSlot)
