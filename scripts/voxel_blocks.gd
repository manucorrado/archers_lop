@tool
extends RefCounted
## Bake colored boxes into one draw batch per moving assembly.

var poses: Array[Transform3D] = []
var tones: Array[Color] = []

func box(center: Vector3, size: Vector3, tone: Color, angles := Vector3.ZERO) -> void:
	var orientation := Basis.from_euler(angles)
	poses.append(Transform3D(orientation.scaled_local(size), center))
	tones.append(tone)

func beam(a: Vector3, b: Vector3, width: float, depth: float, tone: Color) -> void:
	var direction := b - a
	var orientation := Basis(Quaternion(Vector3.UP, direction.normalized()))
	poses.append(Transform3D(orientation.scaled_local(Vector3(width, direction.length(), depth)), (a + b) * 0.5))
	tones.append(tone)

func bake(parent: Node3D, unit_cube: BoxMesh, label: String, shadows := true) -> MultiMeshInstance3D:
	var multi := MultiMesh.new()
	multi.transform_format = MultiMesh.TRANSFORM_3D
	multi.use_colors = true
	multi.mesh = unit_cube
	multi.instance_count = poses.size()
	for index in poses.size():
		multi.set_instance_transform(index, poses[index])
		multi.set_instance_color(index, tones[index])
	var result := MultiMeshInstance3D.new()
	result.name = label
	result.multimesh = multi
	if not shadows:
		result.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(result)
	return result
