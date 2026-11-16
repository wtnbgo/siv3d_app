# -----------------------------------------------------------------------------
# OpenSiv3D (SDL3 版) が SIV3D_BASE に無ければ git で取得する
#
#   CMakeLists.txt から (project() より前):  include(cmake/FetchSiv3D.cmake)   ← SIV3D_BASE を設定しておく
#   Makefile などから:                        cmake -DSIV3D_BASE=<path> -P cmake/FetchSiv3D.cmake
#
# 取得する版は siv3d-app.json の "siv3d" で指定する (省略時は下の既定値):
#   "siv3d": { "repository": "https://github.com/wtnbgo/OpenSiv3D.git", "ref": "develop_sdl3" }
#   ref はブランチ名・タグ名・コミット (40 桁の SHA)。再現性が要るならタグかコミットで固定する。
#
# - すでに SIV3D_BASE に OpenSiv3D があれば何もしない (更新もしない。手元の作業コピーには触らない)
# - 浅い clone (--depth 1)。履歴が要るなら取得後に git fetch --unshallow
# - 取得しない: -DSIV3D_FETCH=OFF または 環境変数 SIV3D_NO_FETCH=1
# -----------------------------------------------------------------------------

set(_siv3d_default_repository "https://github.com/wtnbgo/OpenSiv3D.git")
set(_siv3d_default_ref "develop_sdl3")

if(NOT SIV3D_BASE)
  message(FATAL_ERROR "FetchSiv3D: SIV3D_BASE is not set")
endif()
file(TO_CMAKE_PATH "${SIV3D_BASE}" SIV3D_BASE)

# すでにある
if(EXISTS "${SIV3D_BASE}/cmake/Siv3DAppPrelude.cmake")
  return()
endif()

if((DEFINED SIV3D_FETCH AND NOT SIV3D_FETCH) OR "$ENV{SIV3D_NO_FETCH}")
  message(FATAL_ERROR "OpenSiv3D not found: SIV3D_BASE=${SIV3D_BASE} (automatic fetch is disabled)")
endif()

# 取得する版 (siv3d-app.json の "siv3d")
set(_siv3d_repository "${_siv3d_default_repository}")
set(_siv3d_ref "${_siv3d_default_ref}")
if(NOT SIV3D_APP_CONFIG)
  get_filename_component(SIV3D_APP_CONFIG "${CMAKE_CURRENT_LIST_DIR}/../siv3d-app.json" ABSOLUTE)
endif()
if(EXISTS "${SIV3D_APP_CONFIG}")
  file(READ "${SIV3D_APP_CONFIG}" _siv3d_json)
  string(JSON _value ERROR_VARIABLE _error GET "${_siv3d_json}" siv3d repository)
  if(NOT _error AND _value)
    set(_siv3d_repository "${_value}")
  endif()
  string(JSON _value ERROR_VARIABLE _error GET "${_siv3d_json}" siv3d ref)
  if(NOT _error AND _value)
    set(_siv3d_ref "${_value}")
  endif()
endif()

# 中身のあるフォルダ (OpenSiv3D ではないもの) を上書きしない
if(EXISTS "${SIV3D_BASE}")
  file(GLOB _siv3d_existing "${SIV3D_BASE}/*")
  if(_siv3d_existing)
    message(FATAL_ERROR "SIV3D_BASE=${SIV3D_BASE} exists but is not OpenSiv3D (cmake/Siv3DAppPrelude.cmake not found). "
      "Remove it or set SIV3D_BASE to another location.")
  endif()
endif()

find_program(_siv3d_git NAMES git)
if(NOT _siv3d_git)
  message(FATAL_ERROR "OpenSiv3D not found: SIV3D_BASE=${SIV3D_BASE}, and git is not available to fetch it")
endif()

message(STATUS "OpenSiv3D not found: fetching ${_siv3d_repository} (${_siv3d_ref}) into ${SIV3D_BASE}")

# 途中で止まっても半端なフォルダが残らないよう、一時フォルダに取ってから名前を変える
get_filename_component(_siv3d_parent "${SIV3D_BASE}" DIRECTORY)
get_filename_component(_siv3d_name "${SIV3D_BASE}" NAME)
set(_siv3d_tmp "${_siv3d_parent}/${_siv3d_name}.fetching")
file(REMOVE_RECURSE "${_siv3d_tmp}")
file(MAKE_DIRECTORY "${_siv3d_parent}")

function(_siv3d_git_run)
  execute_process(COMMAND "${_siv3d_git}" ${ARGN} RESULT_VARIABLE _result)
  if(NOT _result EQUAL 0)
    message(FATAL_ERROR "FetchSiv3D: git ${ARGN} failed (${_result})")
  endif()
endfunction()

string(LENGTH "${_siv3d_ref}" _siv3d_ref_length)
if(_siv3d_ref MATCHES "^[0-9a-fA-F]+$" AND _siv3d_ref_length EQUAL 40)
  # コミット (40 桁の SHA): 指定したコミットだけを取得して、その状態にする
  _siv3d_git_run(init --quiet "${_siv3d_tmp}")
  _siv3d_git_run(-C "${_siv3d_tmp}" remote add origin "${_siv3d_repository}")
  _siv3d_git_run(-C "${_siv3d_tmp}" fetch --depth 1 origin "${_siv3d_ref}")
  _siv3d_git_run(-C "${_siv3d_tmp}" -c advice.detachedHead=false checkout --quiet FETCH_HEAD)
else()
  # ブランチ / タグ
  _siv3d_git_run(clone --depth 1 --branch "${_siv3d_ref}" "${_siv3d_repository}" "${_siv3d_tmp}")
endif()

if(NOT EXISTS "${_siv3d_tmp}/cmake/Siv3DAppPrelude.cmake")
  message(FATAL_ERROR "FetchSiv3D: ${_siv3d_repository} (${_siv3d_ref}) does not contain cmake/Siv3DAppPrelude.cmake")
endif()

file(REMOVE_RECURSE "${SIV3D_BASE}")   # 空のフォルダがあった場合
file(RENAME "${_siv3d_tmp}" "${SIV3D_BASE}")
message(STATUS "OpenSiv3D fetched: ${SIV3D_BASE}")
