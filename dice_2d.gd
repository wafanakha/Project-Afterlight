extends Label

var is_rolling = false
var roll_timer = 0.0
var final_result = 1

func _process(delta: float) -> void:
	# Mengacak angka dengan cepat selama animasi berjalan
	if is_rolling:
		roll_timer += delta
		# Ganti angka setiap 0.05 detik
		if roll_timer > 0.05:
			roll_timer = 0.0
			text = str(randi_range(1, 20))

# Fungsi yang akan dipanggil oleh Main UI Anda
func roll_dice(result: int):
	if is_rolling:
		return
		
	final_result = result
	is_rolling = true
	
	# Membuat animasi dengan Tween (Godot 4)
	var tween = create_tween()
	tween.set_parallel(true) # Jalankan semua efek secara bersamaan
	
	# Efek 1: Putar sebanyak 3 putaran (3 * 360 derajat)
	rotation_degrees = 0
	tween.tween_property(self, "rotation_degrees", 360 * 3, 1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# Efek 2: Melompat sedikit ke atas lalu kembali
	var original_y = position.y
	tween.tween_property(self, "position:y", original_y - 30, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "position:y", original_y, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Efek 3: Membesar lalu kembali ke ukuran normal
	var original_scale = scale
	tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(self, "scale", original_scale, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Setelah animasi 1 detik selesai, jalankan fungsi stop_rolling
	await tween.finished
	stop_rolling()

func stop_rolling():
	is_rolling = false
	# Tetapkan ke angka hasil akhir dari AI / sistem RNG
	text = str(final_result)
	
	# Tambahkan warna hijau jika 20 (Critical Success), merah jika 1
	if final_result == 20:
		modulate = Color("green")
	elif final_result == 1:
		modulate = Color("red")
	else:
		modulate = Color("#4A443F") # Kembali ke warna asli UI
