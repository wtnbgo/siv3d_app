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
  cmake/FetchSiv3D.cmake  OpenSiv3D が見つからないときに取得する処理 (CMakeLists.txt と Makefile が使う)
  src/               アプリのソース (Main.cpp、LicenseView.hpp: ライセンス一覧の表示)
  assets/            アプリのアセット (実行ファイルの隣に assets/ としてコピーされる)
    licenses/        アプリが追加するライセンス (*.txt。起動時に一覧へ追加。形式は assets/licenses/README.md)
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

**見つからなければ自動で取得します** (`git clone --depth 1`。取得先は環境変数 `SIV3D_BASE` が指定されていれば
その場所、無ければ `../OpenSiv3D`)。取得する版は `siv3d-app.json` の `siv3d` で指定します。

```json
"siv3d": {
  "repository": "https://github.com/wtnbgo/OpenSiv3D.git",
  "ref": "develop_sdl3"
}
```

- `ref` はブランチ名・タグ名・コミット (40 桁の SHA)。ブランチ名は取得した時期で中身が変わるので、
  再現性が要るならタグかコミットで固定する
- 取得するのは OpenSiv3D が無いときだけです。すでにある OpenSiv3D は更新しません (手元の作業コピーには触らない)。
  版を変えたいときは、その OpenSiv3D を `git fetch` / `git checkout` するか、消してから取り直す
- 浅い clone なので履歴はありません。必要なら取得後に `git fetch --unshallow`
- 取得には git が要ります。取得しない場合は 環境変数 `SIV3D_NO_FETCH=1` (CMake では `-DSIV3D_FETCH=OFF`)
- OpenSiv3D ではない中身のあるフォルダがその場所にあるときは、上書きせずにエラーにします

```bash
git clone https://github.com/wtnbgo/siv3d_app.git MyApp
cd MyApp
make            # 隣に OpenSiv3D が無ければ ../OpenSiv3D に取得してからビルド
```

手元の OpenSiv3D を使う場合は、先に隣に置くか `SIV3D_BASE` で指定します。

```bash
git clone -b develop_sdl3 https://github.com/wtnbgo/OpenSiv3D.git
git clone https://github.com/wtnbgo/siv3d_app.git MyApp
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
make ios             # iOS 版 (macOS で。シミュレータ向け。Xcode が必要)
make ios-run         # iOS シミュレータにインストールして起動
make ios-device      # iOS 実機 (arm64) 向け。ipa を作る (署名に Team ID が必要。下の「iOS 実機で動かす」)
make ios-device-run  # iOS 実機にインストールして起動 (DEVICE=<UDID または名前> で端末を選べる)
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
| macOS | macos、ios (シミュレータ / 実機)、web、android、linux (docker のコンテナ) |

- Web: 環境変数 `EMSDK` (emsdk のフォルダ)。出力は `<exeName>.html` / `.js` / `.wasm` / `.data`。配信には COOP/COEP ヘッダが必要
  (`make run TARGET=web` で確認用サーバを起動。詳しくは OpenSiv3D の `SDL3/BUILD-Web.md`)
  セーブデータは `FileSystem::GetFolderPath(SpecialFolder::Documents)` などホームフォルダの下に書くと、ブラウザの IndexedDB に
  自動で保存され、次に開いたときに読み込まれる (`web.persist` を `false` にすると無効。カレントディレクトリ直下は保存されない)
- Android: 外枠 [siv3d_and](https://github.com/wtnbgo/siv3d_and) を OpenSiv3D の隣に clone する (または環境変数 `SIV3D_ANDROID`)。
  `ANDROID_HOME` / `JAVA_HOME` / `VCPKG_ROOT` が必要。出力は `<exeName>.apk`
- iOS: Xcode (iOS SDK とシミュレータのランタイム) が必要。CMake の Xcode ジェネレータでビルドし、出力は `build/ios/<simulator|device>-<arch>/`。
  シミュレータはホストの CPU 向け (Intel Mac は x86_64)、実機は arm64。WebM (movie-player) は iOS では使えません。
  詳しくは OpenSiv3D の `SDL3/BUILD-iOS.md`

## パッケージ定義 (`siv3d-app.json`)

| キー | 意味 |
|---|---|
| `name` | 表示名 (ウィンドウのタイトルではなく、バージョン情報や .app のバンドル名) |
| `exeName` | 実行ファイル名 (`.exe` / `.app` の名前、配布物のファイル名にも使う) |
| `version` | バージョン (`1.2.3`)。Windows のバージョン情報、macOS の CFBundleVersion、配布物のファイル名 |
| `bundleId` | macOS / iOS のバンドル ID (テンプレートは `jp.wamsoft.sample.siv3d`。コピーしたアプリでは自分の ID に変える) |
| `company` / `copyright` | Windows のバージョン情報、macOS の著作権表示 |
| `siv3d.repository` / `siv3d.ref` | OpenSiv3D が見つからないときに取得するリポジトリと版 (既定 `https://github.com/wtnbgo/OpenSiv3D.git` / `develop_sdl3`) |
| `assets` | 実行ファイルの隣にコピーするフォルダ。`[{ "from": "assets", "to": "assets" }]` (`from` はこのフォルダからの相対パス) |
| `cmake.options` | CMake に渡すオプション (`SIV3D_WITH_MOVIEPLAYER` / `SIV3D_WITH_FFMPEG` など)。機種別の `<機種>.cmake.options` で上書きできる |
| `windows.console` | `true` でコンソールウィンドウを出す (既定 `false`) |
| `windows.icon` / `macos.icon` | アイコンファイル (`.ico` / `.icns`) |
| `linux.container` | Linux 版のビルドに使うコンテナイメージ (既定 `deckbuild-sniper`) |
| `linux.engine` | コンテナの実行に使うコマンド `auto` / `docker` / `wslc` / `podman` (既定 `auto`: docker のデーモンが動いていれば docker、Windows で動いていなければ wslc) |
| `ios.displayName` / `ios.version` / `ios.build` | ホーム画面の名前、CFBundleShortVersionString / CFBundleVersion (省略時は `name` / `version` / `1`) |
| `ios.bundleId` | iOS のバンドル ID (省略時はトップレベルの `bundleId`) |
| `ios.deploymentTarget` | 対応する iOS の最低バージョン (既定 `15.0`) |
| `ios.orientations` | 画面の向き: `"landscape"` (既定) / `"portrait"` / `"all"`、または `UIInterfaceOrientation*` の配列 |
| `ios.deviceFamily` | `"1,2"` (iPhone と iPad、既定) / `"1"` / `"2"` |
| `ios.team` | 実機の署名に使う Apple Developer の Team ID (シミュレータは不要)。コミットしたくない場合は `siv3d-app.local.json` に書く |
| `ios.device` | `make ios-device-run` でインストールする実機 (UDID または名前)。普通は `siv3d-app.local.json` に書く |
| `macos.sign` | 署名に使う ID。既定 `"-"` (ad-hoc 署名。Apple Silicon では署名が無いと起動できない)。配布用は `"Developer ID Application: ..."`、`false` で署名しない |
| `<機種>.package` | 配布物の形式の配列: `zip` / `tar.gz` / `dir` |

アセットはカレントディレクトリ (実行ファイルのフォルダ。macOS は `.app/Contents/MacOS`) からの相対パスで読み込みます。

```cpp
const Texture texture{ U"assets/windmill.png" };
```

## iOS 実機で動かす

実機で動かすには、Apple Developer の **Team ID** による署名が必要です (無料の Apple ID の Personal Team でも、7 日間有効な署名で動かせます)。

1. **Xcode にサインインする**: Xcode > Settings > Accounts で、Team に入っている Apple ID を追加します。
2. **Team ID を調べる**: Accounts の Team の一覧 (Personal Team は「(Personal Team)」の行)、または
   [Apple Developer のメンバーシップ](https://developer.apple.com/account) の「Team ID」(英数字 10 文字)。
3. **Team ID を設定する**: アプリのフォルダに `siv3d-app.local.json` を作ります (`.gitignore` 済みでコミットされません)。
   `siv3d-app.local.json.example` をコピーして書き換えてください。中身は `siv3d-app.json` に重ねて読まれます。

   ```json
   {
     "ios": {
       "team": "ABCDE12345"
     }
   }
   ```

   - バンドル ID は `siv3d-app.json` の `bundleId` (テンプレートは `jp.wamsoft.sample.siv3d`) です。ほかのアプリと重ならない ID にします
     (Personal Team では `com.example.*` は使えません)。開発者ごとに変えたい場合だけ、`siv3d-app.local.json` の `ios.bundleId` で上書きします。
   - 環境変数 `SIV3D_IOS_TEAM=ABCDE12345` でも設定できます (CI など)。
4. **iPhone / iPad を準備する**: USB (または同じネットワーク) で Mac に接続し、「このコンピュータを信頼」を選びます。
   iOS 16 以降は 設定 > プライバシーとセキュリティ > **デベロッパモード** をオンにします (オフだとインストールできません)。
5. **ビルドしてインストールする**:

   ```bash
   make ios-device       # build/ios/device-arm64/ に署名済みの .app と .ipa を作る (初回は Team への端末登録とプロファイル作成も行う)
   make ios-device-run   # 接続中の端末にインストールして起動 (DEVICE=<UDID または名前> で端末を選べる)
   ```

   接続中の端末の一覧は `xcrun devicectl list devices` で見られます。
6. **初回だけ**: Personal Team や Development 署名のアプリは、端末の 設定 > 一般 > VPN とデバイス管理 で
   デベロッパ App を「信頼」するまで起動できません。

うまくいかないとき:

- `No Account for Team` / `No profiles for ...`: Xcode にその Team の Apple ID でサインインしているか確認する
- `Failed Registering Bundle Identifier`: `bundleId` がほかで使われている。別の ID にする
- `Developer Mode disabled`: 端末のデベロッパモードをオンにする (オンにすると端末が再起動する)

App Store / TestFlight への提出 (Archive と App Store Connect 用の書き出し) は、まだドライバでは行いません。
`build/ios/device-arm64/cmake/*.xcodeproj` を Xcode で開いて Product > Archive を使ってください。

## 配布物の中身

- Windows: `MyApp.exe`、`SDL3.dll`、`resources/engine/`、アセット
- Linux: `MyApp` (RPATH = `$ORIGIN`)、`libSDL3.so.0*`、`resources/engine/`、アセット、
  (`SIV3D_WITH_FFMPEG=ON` のとき) FFmpeg の `.so` と `licenses/`
- macOS: `MyApp.app` (ANGLE の dylib を `Contents/Frameworks` に、リソースとアセットを `Contents/MacOS` に同梱)
- iOS: `MyApp.app` (平らな構成。実行ファイル・`siv3d_resources/engine/`・アセットを直下に置く。SDL3 は静的リンク)。
  シミュレータは `.app` の zip、実機は `.ipa`。`.app` の直下に `Resources` という名前のフォルダは置かないでください

macOS は stage のときに `.app` を署名します (既定は ad-hoc 署名)。ad-hoc 署名や未公証の `.app` は、
ダウンロードした zip から展開すると Gatekeeper に止められるので、一般に配布するには Developer ID での署名と公証が必要です
(公証はまだドライバで行いません)。Windows の Authenticode 署名も未対応です。
各機種の配布用の署名 (Windows の signtool、macOS の Developer ID と公証、iOS の App Store Connect 向けの書き出し、
Android の配布用の鍵と AAB) の手順は、OpenSiv3D の [`SDL3/SIGNING.md`](https://github.com/wtnbgo/OpenSiv3D/blob/develop_sdl3/SDL3/SIGNING.md) にまとめています。

ライセンス表記 (エンジンに内蔵のライセンス一覧、F1 キーでの表示、Android / iOS ではアプリ内のライセンス画面が必要なこと、
Linux の FFmpeg の同梱物) は、OpenSiv3D の [`SDL3/LICENSES.md`](https://github.com/wtnbgo/OpenSiv3D/blob/develop_sdl3/SDL3/LICENSES.md) を参照してください。
テンプレートの右下の [Licenses] ボタンは、Android / iOS ではアプリ内にライセンス一覧を表示し (`src/LicenseView.hpp`)、
それ以外の機種ではブラウザで開きます (F1 キーと同じ)。アプリに合わせて置き場所や見た目を変えてください。
アプリが同梱するフォントや素材のライセンスは、`assets/licenses/` に 1 件 1 ファイル (`Title:` / `Copyright:` と本文) で置くと、
起動時の `LicenseManager::AddLicenseFiles(U"assets/licenses")` で一覧に追加されます。エンジン同梱のフォント (Noto Sans CJK、
M+、Font Awesome) のライセンスを最初から置いてあります。

テンプレートのビルドは OpenSiv3D 一式をアプリのビルドツリー (`build/<機種>/cmake`) でビルドするため、
1 機種あたり数 GB のディスクを使います。
