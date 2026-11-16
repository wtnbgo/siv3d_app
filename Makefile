# -----------------------------------------------------------------------------
# Siv3D (SDL3 版) アプリのビルド (tools/siv3d_app.py の薄いラッパ)
#
#   make                 実行中の OS 向けに build + stage + package
#   make windows|linux|macos|web|android   指定した機種向けに build + stage + package
#   make ios / ios-run / ios-device   iOS シミュレータ (ビルド / 起動) / 実機 (arm64)
#   make build|stage|package|run|clean|info [TARGET=windows|linux|macos|web|android] [CONFIG=Release|Debug]
#   make linux NATIVE=1  Linux ホストでコンテナを使わずにビルド
# -----------------------------------------------------------------------------

# OpenSiv3D の場所: 環境変数 SIV3D_BASE → 隣の ../OpenSiv3D
ifeq ($(SIV3D_BASE),)
  SIV3D_BASE := $(abspath ../OpenSiv3D)
endif

ifeq ($(OS),Windows_NT)
  PYTHON ?= python
else
  PYTHON ?= python3
endif

CONFIG ?= Release
DRIVER := $(PYTHON) $(SIV3D_BASE)/tools/siv3d_app.py --project . --config $(CONFIG) $(if $(NATIVE),--native,)
TARGET_OPT := $(if $(TARGET),--target $(TARGET),)

.PHONY: default windows linux macos web android ios ios-run ios-device build stage package run clean info

default:
	$(DRIVER) $(TARGET_OPT) all

windows linux macos web android:
	$(DRIVER) --target $@ all

# iOS: シミュレータ (ホストの CPU 向け) で build + stage + package し、起動する場合は make ios-run
ios:
	$(DRIVER) --target ios --sdk simulator all

ios-run:
	$(DRIVER) --target ios --sdk simulator run

# iOS 実機 (arm64)。インストールには siv3d-app.json の ios.team (DEVELOPMENT_TEAM) による署名が要る
ios-device:
	$(DRIVER) --target ios --sdk device all

build stage package run clean info:
	$(DRIVER) $(TARGET_OPT) $@
