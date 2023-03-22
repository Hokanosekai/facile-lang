cmake_minimum_required(VERSION 3.0)

project(facile VERSION 0.6.0 LANGUAGES C)

find_package(FLEX)

flex_target(
  FACILE_SCANNER
  src/facile.l
  ${CMAKE_CURRENT_BINARY_DIR}/facile.lex.c
)

find_package(BISON)

bison_target(
  FACILE_PARSER
  src/facile.y
  ${CMAKE_CURRENT_BINARY_DIR}/facile.y.c
)

add_executable(
  facile 
  ${FLEX_FACILE_SCANNER_OUTPUTS}
  ${BISON_FACILE_PARSER_OUTPUTS}
)

target_link_libraries(facile fl)

set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_SOURCE_IGNORE_FILES "build;~$;${CPACK_SOURCE_IGNORE_FILES}")

set(CPACK_PACKAGE_VERSION_MAJOR "${facile_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${facile_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${facile_VERSION_PATCH}")

include(CPack)