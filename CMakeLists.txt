cmake_minimum_required(VERSION 3.0)

project(facile VERSION 0.1.0 LANGUAGES C)

find_package(FLEX)

flex_target(
  FACILE_SCANNER
  src/facile.lex
  ${CMAKE_CURRENT_BINARY_DIR}/facile.lex.c
)

add_executable(facile facile.lex.c ${FLEX_FACILE_SCANNER_OUTPUTS})

target_link_libraries(facile fl)

set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_SOURCE_IGNORE_FILES "build;~$;${CPACK_SOURCE_IGNORE_FILES}")

set(CPACK_PACKAGE_VERSION_MAJOR "${facile_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${facile_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${facile_VERSION_PATCH}")

include(CPack)