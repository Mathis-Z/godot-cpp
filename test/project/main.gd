extends "res://test_base.gd"

var custom_signal_emitted = null


func _ready():
	# Signal.
	$Example.emit_custom_signal("Button", 42)
	assert_equal(custom_signal_emitted, ["Button", 42])

	# To string.
	assert_equal($Example.to_string(),'Example:[ GDExtension::Example <--> Instance ID:%s ]' % $Example.get_instance_id())
	# It appears there's a bug with instance ids :-(
	#assert_equal($Example/ExampleMin.to_string(), 'ExampleMin:[Wrapped:%s]' % $Example/ExampleMin.get_instance_id())

	# Call static methods.
	assert_equal($Example.test_static(9, 100), 109);
	# It's void and static, so all we know is that it didn't crash.
	$Example.test_static2()

	# Property list.
	$Example.property_from_list = Vector3(100, 200, 300)
	assert_equal($Example.property_from_list, Vector3(100, 200, 300))

	# Call simple methods.
	$Example.simple_func()
	assert_equal(custom_signal_emitted, ['simple_func', 3])
	($Example as Example).simple_const_func() # Force use of ptrcall
	assert_equal(custom_signal_emitted, ['simple_const_func', 4])

	# Pass custom reference.
	assert_equal($Example.custom_ref_func(null), -1)
	var ref1 = ExampleRef.new()
	ref1.id = 27
	assert_equal($Example.custom_ref_func(ref1), 27)
	ref1.id += 1;
	assert_equal($Example.custom_const_ref_func(ref1), 28)

	# Pass core reference.
	assert_equal($Example.image_ref_func(null), "invalid")
	assert_equal($Example.image_const_ref_func(null), "invalid")
	var image = Image.new()
	assert_equal($Example.image_ref_func(image), "valid")
	assert_equal($Example.image_const_ref_func(image), "valid")

	# Return values.
	assert_equal($Example.return_something("some string"), "some string42")
	assert_equal($Example.return_something_const(), get_viewport())
	var null_ref = $Example.return_empty_ref()
	assert_equal(null_ref, null)
	var ret_ref = $Example.return_extended_ref()
	assert_not_equal(ret_ref.get_instance_id(), 0)
	assert_equal(ret_ref.get_id(), 0)
	assert_equal($Example.get_v4(), Vector4(1.2, 3.4, 5.6, 7.8))
	assert_equal($Example.test_node_argument($Example), $Example)

	# VarArg method calls.
	var var_ref = ExampleRef.new()
	assert_not_equal($Example.extended_ref_checks(var_ref).get_instance_id(), var_ref.get_instance_id())
	assert_equal($Example.varargs_func("some", "arguments", "to", "test"), 4)
	assert_equal($Example.varargs_func_nv("some", "arguments", "to", "test"), 46)
	$Example.varargs_func_void("some", "arguments", "to", "test")
	assert_equal(custom_signal_emitted, ["varargs_func_void", 5])

	# Method calls with default values.
	assert_equal($Example.def_args(), 300)
	assert_equal($Example.def_args(50), 250)
	assert_equal($Example.def_args(50, 100), 150)

	# Array and Dictionary
	assert_equal($Example.test_array(), [1, 2])
	assert_equal($Example.test_tarray(), [ Vector2(1, 2), Vector2(2, 3) ])
	assert_equal($Example.test_dictionary(), {"hello": "world", "foo": "bar"})
	var array: Array[int] = [1, 2, 3]
	assert_equal($Example.test_tarray_arg(array), 6)

	# String += operator
	assert_equal($Example.test_string_ops(), "ABCĎE")

	# UtilityFunctions::str()
	assert_equal(example.test_str_utility(), "Hello, World! The answer is 42")

	# PackedArray iterators
	assert_equal($Example.test_vector_ops(), 105)

	# Properties.
	assert_equal($Example.group_subgroup_custom_position, Vector2(0, 0))
	$Example.group_subgroup_custom_position = Vector2(50, 50)
	assert_equal($Example.group_subgroup_custom_position, Vector2(50, 50))

	# Constants.
	assert_equal($Example.FIRST, 0)
	assert_equal($Example.ANSWER_TO_EVERYTHING, 42)
	assert_equal($Example.CONSTANT_WITHOUT_ENUM, 314)

	# BitFields.
	assert_equal(Example.FLAG_ONE, 1)
	assert_equal(Example.FLAG_TWO, 2)
	assert_equal($Example.test_bitfield(0), 0)
	assert_equal($Example.test_bitfield(Example.FLAG_ONE | Example.FLAG_TWO), 3)

	exit_with_status()

func _on_Example_custom_signal(signal_name, value):
	custom_signal_emitted = [signal_name, value]
