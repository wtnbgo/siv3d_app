# assets/licenses — アプリが追加するライセンス

このフォルダの `*.txt` は、起動時に `LicenseManager::AddLicenseFiles(U"assets/licenses")` (`src/Main.cpp`) で読み込まれ、
ライセンス一覧 (F1 キー / [Licenses] ボタン) に **ファイル名の順** で追加されます。`.txt` 以外 (この README など) は読みません。

アプリが同梱するフォント・画像・音声などの素材のライセンスを、1 件 1 ファイルで置いてください。

## 形式 (UTF-8)

```
Title: 名前
Copyright: 著作権表示 (複数行は Copyright: を繰り返す)

許諾条件の本文 (空行の後から最後まで)
```

- `Title:` が無い場合はファイル名 (拡張子なし) を名前にします。
- 本文は HTML としてエスケープされるので、`<` や `&` もそのまま書けます。

## 最初から置いてあるもの

Siv3D のエンジンが同梱するフォント (`resources/engine/font/`) のうち、エンジンの内蔵の一覧に無いものです。
文面は、エンジンが同梱する各フォントの LICENSE を元にしています。

| ファイル | 内容 |
|---|---|
| `font-awesome.txt` | Font Awesome Free (アイコンフォント。フォントは SIL OFL 1.1、アイコンは CC BY 4.0) |
| `mplus.txt` | M+ FONTS |
| `noto-sans-cjk.txt` | Noto Sans CJK / Noto Sans JP (SIL OFL 1.1。同梱の LICENSE に無い著作権表示は元のリポジトリの表記を補った) |

- Noto Emoji と Material Design Icons は、エンジンの内蔵の一覧に入っています。
- 日本語のフォールバック用の `resources/engine/font/min/siv3d-min.woff` は、同梱の LICENSE が SIL OFL 1.1 ですが、
  元のフォントと著作権者の記載がないため、ここには置いていません。
- 使わないフォントを `resources/engine/font/` から外した場合は、対応するファイルも消してかまいません。
