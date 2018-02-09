MACRO(FIND_PYTORCH_MODULE)
  IF(NOT PYTHONINTERP_FOUND)
    SET(PYTORCH_FOUND OFF)
    SET(PYTORCH_PATH)
    SET(PYTORCH_CUDA)
  ENDIF(NOT PYTHONINTERP_FOUND)
  IF(NOT PYTORCH_FOUND)
    EXECUTE_PROCESS(COMMAND "${PYTHON_EXECUTABLE}" "-c"
      "from __future__ import print_function; import torch; from os.path import dirname; print(dirname(torch.__file__))"
      RESULT_VARIABLE _PYTORCH_STATUS_
      OUTPUT_VARIABLE _PYTORCH_PATH_
      ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
    # Note: Status = 0 -> OK
    IF(NOT _PYTORCH_STATUS_)
      EXECUTE_PROCESS(COMMAND "${PYTHON_EXECUTABLE}" "-c"
        "from __future__ import print_function; import torch; print(torch.__version__)"
        RESULT_VARIABLE _PYTORCH_STATUS_
        OUTPUT_VARIABLE _PYTORCH_VERSION_
        ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
      EXECUTE_PROCESS(COMMAND "${PYTHON_EXECUTABLE}" "-c"
        "from __future__ import print_function; import torch; print('ON' if torch.cuda.is_available() else 'OFF')"
        RESULT_VARIABLE _PYTORCH_STATUS_
        OUTPUT_VARIABLE _PYTORCH_CUDA_
        ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE)
      SET(PYTORCH_PATH ${_PYTORCH_PATH_})
      SET(PYTORCH_VERSION ${_PYTORCH_VERSION_})
      SET(PYTORCH_CUDA ${_PYTORCH_CUDA_})
    ELSE()
      SET(PYTORCH_PATH)
      SET(PYTORCH_VERSION)
      SET(PYTORCH_CUDA)
    ENDIF(NOT _PYTORCH_STATUS_)
  ENDIF(NOT PYTORCH_FOUND)
ENDMACRO(FIND_PYTORCH_MODULE)

FIND_PACKAGE(PythonInterp)
FIND_PYTORCH_MODULE()

FIND_PATH(PYTORCH_INCLUDE_DIR
  NAMES TH/TH.h
  HINTS ${PYTORCH_PATH}/lib/include)

# NOTE: PyTorch library extensions are .so.1 in GNU/Linux
LIST(APPEND CMAKE_FIND_LIBRARY_SUFFIXES ".so.1")

FIND_LIBRARY(PYTORCH_TH_LIBRARY
  NAMES TH
  HINTS ${PYTORCH_PATH}/lib)

# NOTE: This may cause problems when PyTorch is installed without cuda support!
FIND_LIBRARY(PYTORCH_THC_LIBRARY
  NAMES THC
  HINTS ${PYTORCH_PATH}/lib)

FIND_PACKAGE_HANDLE_STANDARD_ARGS(PyTorch
  FOUND_VAR
    PYTORCH_FOUND
  REQUIRED_VARS
    PYTORCH_PATH PYTORCH_INCLUDE_DIR PYTORCH_TH_LIBRARY PYTORCH_THC_LIBRARY
  VERSION_VAR
    PYTORCH_VERSION)
