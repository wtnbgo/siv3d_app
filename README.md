# Siv3D (SDL3 版) アプリのテンプレート

OpenSiv3D (SDL3 版) を使うアプリのひな形です。このリポジトリをコピー (または GitHub の「Use this template」/ clone して履歴を消す) して、自分のアプリのリポジトリにします。

アプリ側に置くのは **ソース・アセット・パッケージ定義 (`siv3d-app.json`)・最小限の `CMakeLists.txt` と `Makefile`** だけです。
エンジン本体 (OpenSiv3D) はコピーせず、`SIV3D_BASE` で参照します。ビルドの共通処理は OpenSiv3D 側の
`cmake/Siv3DApp*.cmake` (`siv3d_add_app()`) と `tools/siv3d_app.py` (ビルドドライバ) にあります。

## 構成

```
MyApp/
  CMakeLists.txt     OpenSiv3D を参照して siv3d_add_app() を呼ぶだけ
  siv3d-app.json     パッケージ定義 (表示名・実行ファイル名・バージョン・アセット・機種別の設定)
  Makefile           tools/siv3d_app.py の薄いラッパ
  src/               アプリのソース
  assets/            アプリのアセット (実行ファイルの隣に assets/ としてコピーされる)
  icon/              アイコン (Windows: .ico / macOS: .icns)
  build/<機種>/       出力 (git 管理外)
    cmake/           CMake のビルドツリー
    dist/            配布用の構成 (実行ファイル + SDL3 + resources/engine + アセット)
    package/         配布物 (<exeName>-<version>-<機種>.zip / .tar.gz)
```

## OpenSiv3D の場所 (`SIV3D_BASE`)

OpenSiv3D (SDL3 版) は [wtnbgo/OpenSiv3D](https://github.com/wtnbgo/OpenSiv3D) の `develop_sdl3` ブランチです。
次の順に探します (CMake・Makefile とも同じ)。

1. 環境変数 `SIV3D_BASE` (OpenSiv3D リポジトリのルート)
2. 隣にある `../OpenSiv3D`

```bash
git clone -b develop_sdl3 https://github.com/wtnbgo/OpenSiv3D.git
git clone https://github.com/wtnbgo/siv3d_app.git MyApp
cd MyApp
make
```

```
work/
  OpenSiv3D/      ← SIV3D_BASE
  MyApp/          ← このテンプレートをコピーしたもの
```

## 必要なもの

- 各機種の OpenSiv3D のビルド環境 (`SDL3/BUILD-Windows.md` / `SDL3/BUILD_LINUX.md` / `SDL3/BUILD-macOS.md`)
- 環境変数 `VCPKG_ROOT`
- Python 3.9 以上と CMake 3.21 以上、Ninja
- Linux 版をビルドする場合: コンテナ (Windows は docker または WSL の `wslc`、macOS / Linux は docker) と
  sniper SDK のイメージ `deckbuild-sniper` ([steamdev](https://github.com/wamsoft/steamdev) の `deckbuild/` で作る。
  docker なら `deckbuild.sh image`、wslc なら `wslc build -t deckbuild-sniper <steamdev>/deckbuild`)
- Linux 版をホストで直接ビルドする場合 (`NATIVE=1`): `uuid-dev` が必須 (sniper SDK には入っている)。
  加えて、無くてもビルドは通るが SDL3 の機能が欠けるもの: `libpulse-dev` / `libpipewire-0.3-dev` (無いと音声が
  ALSA / JACK だけになる)、`libdecor-0-dev` (無いと GNOME の Wayland でウィンドウの枠が出ない)、`libibus-1.0-dev` (IME)。
  ほかに `libwayland-dev` / `libx11-dev` 系 / `libegl-dev` / `libdbus-1-dev` / `libudev-dev` / `libasound2-dev`

## ビルド

```bash
make                 # 実行中の OS 向けに build + stage + package
make windows         # Windows 版 (Windows で)
make macos           # macOS 版 (macOS で)
make linux           # Linux 版 (sniper SDK のコンテナでビルド)
make linux NATIVE=1  # Linux 版をホストで直接ビルド (Linux で。出力は build/linux-native。配布物は *-linux-native.tar.gz で、配布用ではない)
make web             # Web 版 (どのホストでも。emsdk が必要)
make android         # Android 版 (どのホストでも。Android SDK / NDK と外枠 siv3d_and が必要)
make run             # stage した実行ファイルを起動
make build CONFIG=Debug
make clean TARGET=windows
```

`make` を使わずに直接呼ぶこともできます。

```bash
python <SIV3D_BASE>/tools/siv3d_app.py --project . --target windows all
```

CMake を直接使うこともできます (IDE で開く場合など)。

```bash
cmake -S . -B build/dev -G "Ninja Multi-Config"
cmake --build build/dev --config Release
```

| ホスト | 作れる機種 |
|---|---|
| Windows | windows、web、android、linux (docker または wslc のコンテナ) |
| Linux | linux (コンテナ、または `NATIVE=1` でホストのコンパイラ)、web、android |
| macOS | macos、web、android、linux (docker のコンテナ)、ios (対応中) |

- Web: 環境変数 `EMSDK` (emsdk のフォルダ)。出力は `<exeName>.html` / `.js` / `.wasm` / `.data`。配信には COOP/COEP ヘッダが必要
  (`make run TARGET=web` で確認用サーバを起動。詳しくは OpenSiv3D の `SDL3/BUILD-Web.md`)
  セーブデータは `FileSystem::GetFolderPath(SpecialFolder::Documents)` などホームフォルダの下に書くと、ブラウザの IndexedDB に
  自動で保存され、次に開いたときに読み込まれる (`web.persist` を `false` にすると無効。カレントディレクトリ直下は保存されない)
- Android: 外枠 [siv3d_and](https://github.com/wtnbgo/siv3d_and) を OpenSiv3D の隣に clone する (または環境変数 `SIV3D_ANDROID`)。
  `ANDROID_HOME` / `JAVA_HOME` / `VCPKG_ROOT` が必要。出力は `<exeName>.apk`

## パッケージ定義 (`siv3d-app.json`)

| キー | 意味 |
|---|---|
| `name` | 表示名 (ウィンドウのタイトルではなく、バージョン情報や .app のバンドル名) |
| `exeName` | 実行ファイル名 (`.exe` / `.app` の名前、配布物のファイル名にも使う) |
| `version` | バージョン (`1.2.3`)。Windows のバージョン情報、macOS の CFBundleVersion、配布物のファイル名 |
| `bundleId` | macOS のバンドル ID |
| `company` / `copyright` | Windows のバージョン情報、macOS の著作権表示 |
| `assets` | 実行ファイルの隣にコピーするフォルダ。`[{ "from": "assets", "to": "assets" }]` (`from` はこのフォルダからの相対パス) |
| `cmake.options` | CMake に渡すオプション (`SIV3D_WITH_MOVIEPLAYER` / `SIV3D_WITH_FFMPEG` など)。機種別の `<機種>.cmake.options` で上書きできる |
| `windows.console` | `true` でコンソールウィンドウを出す (既定 `false`) |
| `windows.icon` / `macos.icon` | アイコンファイル (`.ico` / `.icns`) |
| `linux.container` | Linux 版のビルドに使うコンテナイメージ (既定 `deckbuild-sniper`) |
| `linux.engine` | コンテナの実行に使うコマンド `auto` / `docker` / `wslc` / `podman` (既定 `auto`: docker のデーモンが動いていれば docker、Windows で動いていなければ wslc) |
| `macos.sign` | 署名に使う ID。既定 `"-"` (ad-hoc 署名。Apple Silicon では署名が無いと起動できない)。配布用は `"Developer ID Application: ..."`、`false` で署名しない |
| `<機種>.package` | 配布物の形式の配列: `zip` / `tar.gz` / `dir` |

アセットはカレントディレクトリ (実行ファイルのフォルダ。macOS は `.app/Contents/MacOS`) からの相対パスで読み込みます。

```cpp
const Texture texture{ U"assets/windmill.png" };
```

## 配布物の中身

- Windows: `MyApp.exe`、`SDL3.dll`、`resources/engine/`、アセット
- Linux: `MyApp` (RPATH = `$ORIGIN`)、`libSDL3.so.0*`、`resources/engine/`、アセット、
  (`SIV3D_WITH_FFMPEG=ON` のとき) FFmpeg の `.so` と `licenses/`
- macOS: `MyApp.app` (ANGLE の dylib を `Contents/Frameworks` に、リソースとアセットを `Contents/MacOS` に同梱)

macOS は stage のときに `.app` を署名します (既定は ad-hoc 署名)。ad-hoc 署名や未公証の `.app` は、
ダウンロードした zip から展開すると Gatekeeper に止められるので、一般に配布するには Developer ID での署名と公証が必要です
(公証はまだドライバで行いません)。Windows の Authenticode 署名も未対応です。

テンプレートのビルドは OpenSiv3D 一式をアプリのビルドツリー (`build/<機種>/cmake`) でビルドするため、
1 機種あたり数 GB のディスクを使います。
