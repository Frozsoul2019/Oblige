# the name of the target operating system
set(CMAKE_SYSTEM_NAME Windows)

# which tools to use
set(CMAKE_C_COMPILER   /usr/bin/i686-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER /usr/bin/i686-w64-mingw32-g++)
set(CMAKE_RC_COMPILER /usr/bin/i686-w64-mingw32-windres)

# here is where the target environment located
set(CMAKE_FIND_ROOT_PATH  /usr/i686-w64-mingw32)

# adjust the default behaviour of the FIND_XXX() commands:
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# search headers and libraries in the target environment,
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(CMAKE_INSTALL_PREFIX ${CMAKE_FIND_ROOT_PATH}/usr CACHE FILEPATH
   "install path prefix")
