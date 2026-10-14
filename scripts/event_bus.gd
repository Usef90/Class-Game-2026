extends Node

# battle_logic

signal card_selected(id)
signal in_attack_area
signal out_attack_area

signal update_id

signal check_victory_conditions

signal damaged_enemy(damage, name)
signal damaged_player(damage, animation, enemy_name)

signal reduce_energy_by(cost)
signal total_energy(total)

signal give_side_effects(effect)
signal give_side_effects_to_enemies(effect)

signal dialogue

signal players_turn
signal enemies_turn(attacking_enemy)

signal id_chosen(id, damage)
signal id_effect_chosen(id, effect)

signal update_display(sentence)

signal show_status_text(text)
signal hide_status_text
