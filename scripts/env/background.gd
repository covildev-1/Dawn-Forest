extends ParallaxBackground
class_name Background

# A primeira var serve para retornar um valor booleano.
# Já a segunda é uma lista de valores inteiros.
export(bool) var can_process
export(Array, int) var layer_speed


func _ready():
	if can_process == false:
		# Este código basicamente diz que, se can_process for falso, a função
		# physics_process também recebe false e não será chamada.
		set_physics_process(false)
		

func _physics_process(delta):
	# Aqui a var index está pegando como valor a quantidade de filhos que há em Background.
	for index in get_child_count():
		# Aqui o if está verificando se o filho de Background em tal índice é do tipo ParallaxLayer.
		if get_child(index) is ParallaxLayer:
			# Aqui está sendo feita a movimentação do parallax de maneira "manual".
			# O filho de Background, baseado no valor de index, está sendo pega a sua posição no
			# eixo x e decrescendo seu valor com o resultado de delta * layer_speed[index].
			# O valor de layer_speed vai ser definido fora do script.
			get_child(index).motion_offset.x -= delta * layer_speed[index]
