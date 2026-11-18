# Inputs real-world exporters produce that used to fail or read garbage:
# a binary STL whose header starts with "solid", a binary STL whose triangle
# count promises more than the file holds, and an output path that cannot be
# written (must fail instead of reporting success).
#
# Usage: cmake -DEXE=<stltostp> -DDIR=<test dir> -P check_robust_input.cmake

cmake_minimum_required(VERSION 3.12)

execute_process(COMMAND "${EXE}" "${DIR}/solid_header_bin.stl" "${DIR}/solid_header_bin.stp"
	RESULT_VARIABLE res OUTPUT_VARIABLE out)
if(NOT res EQUAL 0 OR NOT out MATCHES "Read 12 triangles")
	message(FATAL_ERROR "binary stl with a 'solid' header was not read as binary (${res}): ${out}")
endif()

execute_process(COMMAND "${EXE}" "${DIR}/truncated_bin.stl" "${DIR}/truncated_bin.stp"
	RESULT_VARIABLE res OUTPUT_VARIABLE out ERROR_VARIABLE err)
if(NOT res EQUAL 0 OR NOT out MATCHES "Read 6 triangles" OR NOT err MATCHES "announces 12")
	message(FATAL_ERROR "truncated binary stl not clamped to its real size (${res}): ${out} ${err}")
endif()

execute_process(COMMAND "${EXE}" "${DIR}/cube.stl" "${DIR}/no/such/dir/cube.stp"
	RESULT_VARIABLE res OUTPUT_QUIET ERROR_QUIET)
if(res EQUAL 0)
	message(FATAL_ERROR "writing to a missing directory reported success")
endif()

execute_process(COMMAND "${EXE}" "${DIR}/cube.stl" "${DIR}/cube_bad.stp" schema 999
	RESULT_VARIABLE res OUTPUT_QUIET ERROR_QUIET)
if(res EQUAL 0)
	message(FATAL_ERROR "an unsupported schema was accepted")
endif()

execute_process(COMMAND "${EXE}" --version RESULT_VARIABLE res OUTPUT_VARIABLE out)
if(NOT res EQUAL 0 OR NOT out MATCHES "^stltostp [0-9]+\\.[0-9]+\\.[0-9]+")
	message(FATAL_ERROR "--version did not print a version: ${out}")
endif()
