cmake_minimum_required(VERSION 3.21)

# -----------------------------------------------------------------------------
# OpenSiv3D (SDL3 版) の場所 (SIV3D_BASE = OpenSiv3D リポジトリのルート)
#   1. -DSIV3D_BASE=<path>
#   2. 環境変数 SIV3D_BASE
#   3. 隣にある ../OpenSiv3D
# 見つからなければ、siv3d-app.json の "siv3d" (repository / ref) の版を SIV3D_BASE に git で取得する
# (cmake/FetchSiv3D.cmake。取得しない場合は -DSIV3D_FETCH=OFF か 環境変数 SIV3D_NO_FETCH=1)
# -----------------------------------------------------------------------------
if(NOT SIV3D_BASE)
  if(DEFINED ENV{SIV3D_BASE})
    set(SIV3D_BASE "$ENV{SIV3D_BASE}")
  else()
    get_filename_component(SIV3D_BASE "${CMAKE_CURRENT_LIST_DIR}/../OpenSiv3D" ABSOLUTE)
  endif()
endif()
include("${CMAKE_CURRENT_LIST_DIR}/cmake/FetchSiv3D.cmake")

include("${SIV3D_BASE}/cmake/Siv3DAppPrelude.cmake")

# アプリ名 (= 実行ファイル名)。表示名・バージョンなどは siv3d-app.json に書く
project(MyApp LANGUAGES C CXX)

include("${SIV3D_BASE}/cmake/Siv3DApp.cmake")

siv3d_add_app(MyApp
  SOURCES
    src/Main.cpp
  CONFIG siv3d-app.json
)
