local Env             = {}

Env.maya_devkit_path  = os.getenv("MAYA_DEVKIT_LOCATION")
Env.my_note_path      = os.getenv("MYNOTE")
Env.my_python         = os.getenv("MYPYTHON")
Env.my_tmp            = os.getenv("MYTMP")
Env.my_work           = os.getenv("MYWORK")
Env.mydata            = os.getenv("MYDATA")
Env.open3d_cmake_path = os.getenv("OPEN3D_CMAKE_PATH")
Env.qtlib_path        = os.getenv("QTLIB_PATH")

return Env
