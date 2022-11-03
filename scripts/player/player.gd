extends KinematicBody2D
class_name Player


# Aqui estamos referenciando o nó Texture como valor da var player_sprite.
onready var player_sprite: Sprite = get_node("Texture")
onready var wall_ray: RayCast2D = get_node("WallRay")


# Vector2 mexe com valores em dois eixos, o eixo x e o eixo y.
var velocity: Vector2
# Esta var começa com o valor de 1 porque a animação de wall slide tem a sprite olhando para a esquerda.
var direction: int = 1
var jump_count: int = 0
# Estas vars servem como flags (isso significa que elas vão retornar apenas um de dois valores).
var land: bool = false
var on_wall: bool = false
var attacking: bool = false
var defending: bool = false
var crouching: bool = false
# Esta var can_track_input serve para impedir que o jogador faça outras ações enquanto alguma das vars acima forem true.
var can_track_input: bool = true
# Esta var serve para impedir que a animação de wall slide rode em momentos indevidos.
var not_on_wall: bool = true


# Estas export vars servem para que seja possível manipular o valor das vars sem ter que editar diretamente no script (estes valores são manipulados na workspace).
export(int) var speed
export(int) var jump_speed
export(int) var player_gravity
export(int) var wall_jump_speed
export(int) var wall_gravity
# Esta var serve para que, quando o jogador pressionar o botão de pular no estado de wall slide, o personagem pule na direção oposta a da parede para que assim ele não pule para cima e fique preso na animação de wall slide.
export(int) var wall_impulse_speed


func _physics_process(delta: float):
	horizontal_moviment_env()
	vertical_moviment_env()
	actions_env()
	gravity(delta)
	
	# Aqui a movimentação está sendo efetuada na cena com o move_and_slide(). O move_and_slide() faz com que o personagem não rode a animação de run quando der de cara com uma parede. Vector2, em velocity, acessa a sua propriedade UP para que o move_and_slide() possa verificar interações não só com o chão/teto mas também interações com a parede. Com isso o problema do jump é resolvido, pois o mesmo pulava algumas vezes e depois não pulava mais porque o valor de jump_count era zerado e não atualizado por causa que o is_on_floor() não verificava parede como chão.
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Aqui está sendo chamada a var player_sprite para rodar as animações.
	player_sprite.animate(velocity)


# O sinal -> indica que a função está ou não retornando um valor. Se o que vier depois do sinal for um valor do tipo void, então significa que a função não retorna nada.
func horizontal_moviment_env() -> void:
	# Esta função trata de toda a movimentação horizontal do personagem.
	var input_direction: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	# Esta condição impede o jogador de se movimentar na horizontal caso ele esteja agachado, defendendo ou atacando.
	if can_track_input == false or attacking:
		velocity.x = 0
		
		return
	
	velocity.x = input_direction * speed


func vertical_moviment_env() -> void:
	# is_on_floor() é uma função da própria godot que verifica se o personagem está interagindo com algum objeto do tipo floor.
	if is_on_floor() or is_on_wall():
		jump_count = 0
	
	# Esta var serve apenas para diminuir a linha da condição if abaixo.
	var jump_condition: bool = can_track_input and not attacking
	
	# O is_action_just_pressed() verifica se um botão foi pressionado uma única vez.
	if Input.is_action_just_pressed("ui_select") and jump_count < 2 and jump_condition:
		# Aqui a condição verifica se o botão foi pressiona e se o valor da var jump_count é menor que 2.
		jump_count += 1
		
		# Esta condição faz com que o estado de wall slide seja executado.
		if next_to_wall() and not is_on_floor():
			velocity.y = wall_jump_speed
			velocity.x += wall_impulse_speed * direction
		else:
			velocity.y = jump_speed


func actions_env() -> void:
	attack()
	defense()
	crouch()


# Esta função faz o personagem atacar.
func attack() -> void:
	# Esta var verifica se o personagem está agachado, defendendo ou atacando. Se o personagem estiver fazendo alguma dessas ações, a var vai ficar com o valor de false e a animação de attack não será efetuada.
	var attack_condition: bool = not attacking and not defending and not crouching
	
	if Input.is_action_just_pressed("attack") and attack_condition and is_on_floor():
		attacking = true
		player_sprite.normal_attack = true


# Esta função faz o personagem defender.
func defense() -> void:
	if Input.is_action_pressed("defense") and is_on_floor() and not crouching:
		defending = true
		can_track_input = false
	elif not crouching:
		defending = false
		can_track_input = true
		player_sprite.shield_off = true


# Esta função faz o personagem agachar.	
func crouch() -> void:
	if Input.is_action_pressed("crouch") and is_on_floor() and not defending:
		crouching = true
		can_track_input = false
	elif not defending:
		crouching = false
		can_track_input = true
		player_sprite.crouching_off = true


func next_to_wall():
	# Esta condição chama uma propriedade do nó RayCast2D para verificar a colisão e retornar um valor booleano.
	if wall_ray.is_colliding() and not is_on_floor():
		# Esta condição será chamada toda vez que o personagem estiver colidindo com uma parede. A velocidade em y é definida para 0 para evitar que, ao rodar a animação de wall slide, o personagem não deslize para cima por causa da força do pulo estar maior que a força da gravidade. Logo após, a var not_on_wall recebe false para que a condição seja ignorada e não ocorra bugs no código.
		if not_on_wall:
			velocity.y = 0
			not_on_wall = false
			
		return true
	else:
		# Aqui a var not_on_wall recebe true quando o personagem não estiver mais colidindo com uma parede.
		not_on_wall = true
		
		# O else retorna false para que a animação de wall slide não rode caso o personagem esteja colidindo com um chão.
		return false


func gravity(delta: float) -> void:
	# Esta condição segue a mesma lógica do else logo abaixo, porém é aplicada apenas se a função chamada retornar true.
	if next_to_wall():
		velocity.y += wall_gravity * delta
		
		# Esta condição segue a mesma lógica da condição que se encontra dentro do else.
		if velocity.y >= wall_gravity:
			velocity.y = wall_gravity
	else:
		# Aqui está sendo setada a movimentação no eixo y do personagem.
		velocity.y += delta * player_gravity
		
		# Essa condição é feita para evitar que o personagem acabe ficando muito rápido quando estiver caindo, se movendo positivamente no eixo y. 
		if velocity.y >= player_gravity:
			velocity.y = player_gravity
