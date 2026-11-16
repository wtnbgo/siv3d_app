# -----------------------------------------------------------------------------
# Siv3D (SDL3 版) アプリのビルド (tools/siv3d_app.py の薄いラッパ)
#
#   make                 実行中の OS 向けに build + stage + package
#   make windows|linux|macos|web|android   指定した機種向けに build + stage + package
#   make ios / ios-run / ios-device / ios-device-run   iOS シミュレータ (ビルド / 起動) / 実機 (ビルド / 起動)
#   make build|stage|package|run|clean|info [TARGET=windows|linux|macos|web|android] [CONFIG=Release|Debug]
#   make linux NATIVE=1  Linux ホストでコンテナを使わずにビルド
# -----------------------------------------------------------------------------

# OpenSiv3D の場所: 環境変数 SIV3D_BASE → 隣の ../OpenSiv3D
# 見つからなければ siv3d-app.json の "siv3d" の版を git で取得する (cmake/FetchSiv3D.cmake、SIV3D_NO_FETCH=1 で無効)
ifeq ($(SIV3D_BASE),)
  SIV3D_BASE := $(abspath ../OpenSiv3D)
endif
CMAKE ?= cmake

ifeq ($(OS),Windows_NT)
  PYTHON ?= python
else
  PYTHON ?= python3
endif

CONFIG ?= Release
DRIVER := $(PYTHON) $(SIV3D_BASE)/tools/siv3d_app.py --project . --config $(CONFIG) $(if $(NATIVE),--native,)
TARGET_OPT := $(if $(TARGET),--target $(TARGET),)

.PHONY: default windows linux macos web android ios ios-run ios-device ios-device-run build stage package run clean info siv3d-base

default: siv3d-base
	$(DRIVER) $(TARGET_OPT) all

windows linux macos web android: siv3d-base
	$(DRIVER) --target $@ all

# iOS: シミュレータ (ホストの CPU 向け) で build + stage + package し、起動する場合は make ios-run
ios: siv3d-base
	$(DRIVER) --target ios --sdk simulator all

ios-run: siv3d-base
	$(DRIVER) --target ios --sdk simulator run

# iOS 実機 (arm64)。署名に Team ID が要る (siv3d-app.local.json の ios.team または環境変数 SIV3D_IOS_TEAM)
ios-device: siv3d-base
	$(DRIVER) --target ios --sdk device all

# iOS 実機にインストールして起動する (DEVICE=<UDID または名前> で指定。省略時は接続中の 1 台)
ios-device-run: siv3d-base
	$(DRIVER) --target ios --sdk device $(if $(DEVICE),--device "$(DEVICE)",) run

build stage package run clean info: siv3d-base
	$(DRIVER) $(TARGET_OPT) $@

# OpenSiv3D が無ければ取得する (あれば何もしない)
siv3d-base:
	@$(CMAKE) "-DSIV3D_BASE=$(SIV3D_BASE)" -P cmake/FetchSiv3D.cmake
