include(FetchContent)

# Turn off noisy deprecation warnings from Microsoft.
add_compile_definitions(_CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_WARNINGS)

# Set libxml2 build options.
set(LIBXML2_WITH_ICONV OFF)
set(LIBXML2_WITH_PYTHON OFF)
set(BUILD_SHARED_LIBS OFF)

# Fetch and build libxml2.
FetchContent_Declare(LibXml2
  GIT_REPOSITORY "https://github.com/GNOME/libxml2.git"
  GIT_TAG "v2.13.3")
FetchContent_MakeAvailable(LibXml2)

# libxml2 needs a modulemap to be usable from Swift. Glob the headers
# and write one to their headers directory.
file(GLOB LIBXML2_HEADERS "${libxml2_SOURCE_DIR}/include/libxml/*.h")
set(MODULE_CONTENT "module libxml2 {\n")
foreach(HEADER ${LIBXML2_HEADERS})
  get_filename_component(HEADER_NAME ${HEADER} NAME)
  string(APPEND MODULE_CONTENT "  header \"${HEADER_NAME}\"\n")
endforeach()
string(APPEND MODULE_CONTENT "  export *\n}")
file(CONFIGURE OUTPUT ${libxml2_SOURCE_DIR}/include/libxml/module.modulemap
  CONTENT "${MODULE_CONTENT}")

# Make libxml2 available in the proper case.
add_library(libxml2 ALIAS LibXml2)
