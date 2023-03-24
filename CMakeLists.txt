cmake_minimum_required(VERSION 3.10)

project(facile VERSION 0.6.0 LANGUAGES C)

# Find the Flex and Bison packages
find_package(FLEX)
find_package(BISON)

# Find the GLib package
find_package(PkgConfig REQUIRED)
pkg_check_modules(GLIB REQUIRED glib-2.0)

flex_target(
  FACILE_SCANNER
  src/facile.l
  ${CMAKE_CURRENT_BINARY_DIR}/facile.lex.c
)
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

target_link_libraries(
  facile
  PRIVATE
  ${GLIB_LIBRARIES}
)

target_include_directories(
  facile
  PRIVATE
  ${GLIB_INCLUDE_DIRS}
)

set(CPACK_SOURCE_GENERATOR "ZIP")
set(CPACK_SOURCE_IGNORE_FILES "build;~$;${CPACK_SOURCE_IGNORE_FILES}")

set(CPACK_PACKAGE_VERSION_MAJOR "${facile_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${facile_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${facile_VERSION_PATCH}")

include(CPack)