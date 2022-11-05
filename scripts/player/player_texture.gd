extends Sprite
class_name PlayerTexture


# Aqui a colisão de AttackArea etsá sendo pega para que possamos desativá-la quando o personagem estiver no estado de hit.
export(NodePath) onready var attack_collision = get_node(attack_collision) as CollisionShape2D
# Aqui está sendo pego o nó AnimationPlayer e o colocando como valor de animation. Foi feita dessa forma porque AnimationPlayer é irmão de Sprite, e por causa disso a "conversa" entre eles é mais difícil. Assim a var animation tem acesso as propriedades do nó AnimationPlayer.
export(NodePath) onready var animation = get_node(animation) as AnimationPlayer
export(NodePath) onready var player = get_node(player) as KinematicBody2D
# Esta var serve para indicar para qual direção o personagem está atacando.
var suffix: String = "Right"
# Esta var serve para dizer ao código que o personagem está efetuando um ataque normal.
var normal_attack: bool = false
# As vars shield_off e crouching_off servem para prender o personagem no último frame das animações enquantos eles estiverem com o botão pressionado.
var shield_off: bool = false
var crouching_off: bool = false


# Aqui se encontra a função que é chamada para rodar as animações e flipar as sprites.
func animate(direction: Vector2) -> void:
	verify_position(direction)
	
	if player.on_hit or player.dead:
		hit_behavior()
	elif player.attacking or player.defending or player.crouching or player.next_to_wall():
		action_behavior()
	elif direction.y != 0:
		vertical_behavior(direction)
	elif player.land == true:
		animation.play("Land")
		# Aqui foi acessada o _physics_process() de player e o setamos como false para que quando a animação de land estiver rodando, o player não consiga se movimentar.
		player.set_physics_process(false)
	else:
		horizontal_behavior(direction)


# Esta função faz o personagem flipar de acordo com o valor de x em direction.
func verify_position(direction: Vector2) -> void:
	if direction.x > 0:
		flip_h = false
		suffix = "Right"
		# Aqui a var direction de player recebe -1 por causa do pulo na parede. O valor precisa ser negativo para que o pulo ocorra na direção oposta a da parede.
		player.direction = -1
		# Aqui a position recebe um vetor zerado para não ocorrer um bug em relação a posição da sprite com o raycast e as animações.
		position = Vector2.ZERO
		# Aqui a propriedade cast_to de RayCast2D está recebendo este valor para apontar para a direção correta de acordo com a direção que o personagem estiver olhando.
		player.wall_ray.cast_to = Vector2(5.5, 0)
	elif direction.x < 0:
		flip_h = true
		suffix = "Left"
		player.direction = 1
		position = Vector2(-2, 0)
		# Aqui o cast_to recebe -7.5 porque position recebe -2 (-5.5 + -2).
		player.wall_ray.cast_to = Vector2(-7.5, 0)


# Esta função roda as animações do personagem de acordo com o valor de x em direction.
func horizontal_behavior(direction: Vector2) -> void:
	if direction.x != 0:
		animation.play("Run")
	else:
		animation.play("Idle")


func hit_behavior() -> void:
	player.set_physics_process(false)
	# Aqui a colisão de AttackArea está sendo desabilitada.
	attack_collision.set_deferred("disabled", true)
	
	if player.dead:
		animation.play("Dead")
	elif player.on_hit:
		animation.play("Hit")


func action_behavior() -> void:
	if player.next_to_wall():
		animation.play("WallSlide")
	elif player.attacking and normal_attack:
		animation.play("Attack" + suffix)
	elif player.defending and shield_off:
		animation.play("Shield")
		shield_off = false
	elif player.crouching and crouching_off:
		animation.play("Crouch")
		crouching_off = false


func vertical_behavior(direction: Vector2) -> void:
	if direction.y > 0:
		player.land = true
		animation.play("Fall")
	elif direction.y < 0:
		animation.play("Jump")


# Este signal foi chamado no código para que a animação de land possa ser interrompida e não ficar em loop.
func _on_animation_finished(anim_name: String):
	match anim_name:
		"Land":
			player.land = false
			# Aqui o _physics_process() volta a ser true para que as físicas do jogo voltem ao normal quando a animação de land acabar.
			player.set_physics_process(true)
		
		"AttackLeft":
			normal_attack = false
			player.attacking = false
		
		"AttackRight":
			normal_attack = false
			player.attacking = false
			
		"Hit":
			player.on_hit = false
			# Mesma lógica do match landing.
			player.set_physics_process(true)
			
			# Esta condição serve para que, quando o personagem estiver no estado de hit e o jogador estiver pressionando o botão de defesa, assim que o estado de hit acabar, o estado de defesa seja iniciado (isso cabe para o estado de defending porque é um estado que fica true enquanto o jogador estiver pressionando o botão, assim como o crouching).
			if player.defending:
				animation.play("Shield")
			
			if player.crouching:
				animation.play("Couch")
