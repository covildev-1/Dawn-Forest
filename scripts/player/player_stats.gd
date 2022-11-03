extends Node
class_name PlayerStats


var shielding: bool = false
# Base stats vars (valores padrões de status).
var base_health: int = 15
var base_mana: int = 10
var base_attack: int = 1
var base_magic_attack: int = 3
var base_defense: int = 1
# Bonus offensive vars (valores adicionais\somativos de ataque e defesa).
var bonus_health: int = 0
var bonus_mana: int = 0
var bonus_attack: int = 0
var bonus_magic_attack: int = 0
var bonus_defense: int = 0
# Base points vars (valores padrões de vida e mana).
var current_health: int
var current_mana: int
# Total points vars (valores da soma dos valores base e bonus de vida e mana).
var max_health: int
var max_mana: int
# Base up vars (valores padrões de xp e lvl).
var current_xp: int = 0
var lvl = 1
# Está var é um dicionário que guarda a quantidade de xp necessária para se passar de level.
var lvl_dict: Dictionary = {'1': 25, '2': 33, '3': 49, '4': 66, '5': 93, '6': 135, '7': 186, '8': 251, '9': 356}


func _ready() -> void:
	# Mana managment.
	current_mana = base_mana + bonus_mana
	max_mana = current_mana
	# Health managment.
	current_health = base_health + bonus_health
	max_health = current_health


func update_xp(value: int) -> void:
	current_xp += value
	
	# Aqui o if verifica se o valor de current_xp é >= ao valor da chave do de lvl_dict e se o valor de level é menor que 9.
	if current_xp >= lvl_dict[str(lvl)] and lvl < 9:
		var leftover: int = current_xp - lvl_dict[str(lvl)]
		current_xp = leftover
		on_lvl_up()
		lvl += 1
	elif current_xp >= lvl_dict[str(lvl)] and lvl == 9:
		current_xp = lvl_dict[str(lvl)]


# Esta funcção serve para que, quando o jogador passar de lvl, tanto o seu hp quanto o seu mp serão preenchidos.
func on_lvl_up() -> void:
	current_mana = base_mana + bonus_mana
	max_mana = current_mana
	current_health = base_health + bonus_health
	max_health = current_health 


# Esta função recebe dois valores, um do tipo string, que serve para dizer se esá sendo acrescentado ou retirado do valor de current_health, e um do tipo integer que serve para dizr a quantidade que será modificada.
func update_health(type: String, value: int) -> void:
	# Este match é o responsável para verificar em qual caso será feita a modificação do valor.
	match type:
		'Increase':
			current_health += value
			
			# Esta condição verifica se current_health é maior ou igual a max_health. Se for o valor de current_health se torna o valor de max_health.
			if current_health >= max_health:
				current_health = max_health
		
		'Decrease':
			verify_shield(value)
			
			if current_health <= 0:
				pass
			else:
				pass


func verify_shield(value: int) -> void:
	if shielding:
		if (base_defense + bonus_defense) >= value:
			return
		
		# Esta var recebe como valor um absoluto porque como o valor será negativo, ele se tonará positivo para evitar problemas com a lógica. OBS.: a tipagem dinâmica de damage foi removida porque estava havendo conflitos em relação ao tipo do valor.
		var damage = abs((base_defense + bonus_defense) - value)
		current_health -= damage
	else:
		current_health -= value


func update_mana(type: String, value: int) -> void:
	match type:
		'Increase':
			current_mana += value
			
			if current_mana >= max_health:
				current_mana = max_health
		
		'Decrease':
			current_mana -= value
