cmake_minimum_required(VERSION 3.21)

# -----------------------------------------------------------------------------
# OpenSiv3D (SDL3 版) の場所 (SIV3D_BASE = OpenSiv3D リポジトリのルート)
#   1. -DSIV3D_BASE=<path>
#   2. 環境変数 SIV3D_BASE
#   3. 隣にある ../OpenSiv3D
# -----------------------------------------------------------------------------
if(NOT SIV3D_BASE)
  if(DEFINED ENV{SIV3D_BASE})
    set(SIV3D_BASE "$ENV{SIV3D_BASE}")
  else()
    set(SIV3D_BASE "${CMAKE_CURRENT_LIST_DIR}/../OpenSiv3D")
  endif()
endif()
file(TO_CMAKE_PATH "${SIV3D_BASE}" SIV3D_BASE)
if(NOT EXISTS "${SIV3D_BASE}/cmake/Siv3DAppPrelude.cmake")
  message(FATAL_ERROR "OpenSiv3D not found: SIV3D_BASE=${SIV3D_BASE}")
endif()

include("${SIV3D_BASE}/cmake/Siv3DAppPrelude.cmake")

# アプリ名 (= 実行ファイル名)。表示名・バージョンなどは siv3d-app.json に書く
project(MyApp LANGUAGES C CXX)

include("${SIV3D_BASE}/cmake/Siv3DApp.cmake")

siv3d_add_app(MyApp
  SOURCES
    src/Main.cpp
  CONFIG siv3d-app.json
)
