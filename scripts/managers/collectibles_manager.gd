extends Node

static var total_award_amount : int

signal on_collectible_award_recieved

func give_pickup_award(collectible_amount : int):
	total_award_amount += collectible_amount
	
	on_collectible_award_recieved.emit(total_award_amount)
